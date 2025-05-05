local stringx = require("pl.stringx");
local json_parser = (require('cjson.safe')).new();
local URI_CLASS = require("uri");
local evl_crypto = (require('service_utils.common.utils')).load_library('libevlcrypto');
local core_utils = require("lua_schema.core_utils");
local properties_funcs = platform.properties_funcs();
local utils = require('service_utils.common.utils');
local client_factory = require('service_utils.REST.client');
local ffi = require("ffi");
local ws_util = require("service_utils.WS.ws_util");
local ws_const = require('service_utils.WS.ws_const');
local constants = require('service_utils.common.constants');

ffi.cdef[[
void * memset(void *b, int c, size_t len);
]]

local ws = {};

ws.WEBSOCKET_GUID = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11";
ws.WEBSOCKET_VERSION = "13";

local gen_err_resp = function(request, response, msg)
	response:set_status(400);
	response:set_chunked_trfencoding(true);
	response:set_content_type("application/json");
	local out = {};
	out.error_message = msg
	local flg, json_output, out = pcall(json_parser.encode, out);
	response:set_hdr_field("X-msg", json_output);
	response:send();
	response:write(json_output);
end

local compute_accept = function(key)
	assert(key ~= nil and type(key) == 'string');
	local accept = key .. ws.WEBSOCKET_GUID;

    local sha1_of_accept = core_utils.hex_decode(evl_crypto.s_sha1_hash(accept));
	return core_utils.base64_encode(sha1_of_accept);
end

local function split_path(uri_obj)
	local url_parts = {};
	local i = 0;

	for i,v in ipairs((require "pl.stringx".split(uri_obj:path(), '/'))) do
		if (i ~= 1) then
			url_parts[i-1] = v;
		end
	end
	return url_parts;
end

local create_key = function()
	local rnd = utils.get_rand_bytes(16);
	return core_utils.base64_encode(rnd);
end

ws.accept = function(request, response, uc)
	assert(request ~= nil and tostring(request) == 'httpsreq');
	assert(response ~= nil and tostring(response) == 'httpsresp');
	assert(uc ~= nil and type(uc) == 'table');

	local hdr_flds = request:get_hdr_fields();
	if (hdr_flds["Sec-WebSocket-Version"] == nil) then
		gen_err_resp(request, response, "Missing Sec-WebSocket-Version in handshake request");
		return false;
	end

	if (stringx.strip(hdr_flds["Sec-WebSocket-Version"]) ~= ws.WEBSOCKET_VERSION) then
		gen_err_resp(request, response, "Unsupported WebSocket version requested");
		return false;
	end

	local key = hdr_flds["Sec-WebSocket-Key"];
	if (key == nil or stringx.strip(key) == '') then
		gen_err_resp(request, response, "Missing Sec-WebSocket-Key in handshake request");
		return false;
	end

	local uri = URI_CLASS:new(request:get_uri());
	local url_parts = split_path(uri);

	local ws_recvd_msg_handler;
	if (#url_parts > 0) then
		--local app_base_path = properties_funcs.get_string_property("service_utils.REST.controller.appBasePath");
		local app_base_path = nil;
		if (app_base_path == nil) then
			app_base_path = '';
		else
			app_base_path = app_base_path.."."
		end

		ws_recvd_msg_handler = app_base_path .. url_parts[1];
		local i = 2;
		while (i <= #url_parts) do
			ws_recvd_msg_handler = ws_recvd_msg_handler .. "." .. url_parts[i];
			i = i + 1;
		end
	else
		gen_err_resp(request, response, "Path empty: Unable to deduce message handler");
		return false;
	end

	do
		local handler = require(ws_recvd_msg_handler);
		if (handler == nil) then
			gen_err_resp(request, response, "WS Handler ".. ws_recvd_msg_handler .. "not present");
			return false;
		end
		local flg, msg = handler.init(request, response, uc);
		if (not flg) then
			gen_err_resp(request, response, msg);
			return false;
		end
	end

	platform.set_ws_recvd_msg_handler(ws_recvd_msg_handler);
	platform.set_socket_upgrade_to(1);

	response:set_status(101);
	response:set_hdr_field("Upgrade", "websocket");
	response:set_hdr_field("Connection", "Upgrade");
	response:set_hdr_field("Sec-WebSocket-Accept", compute_accept(key));
	response:set_content_length(0);
	response:send();

	return true;
end

ws.connect = function(inp)
	assert(inp.url ~= nil and type(inp.url) == 'string');
	assert(inp.credentials == nil or type(inp.credentials) == 'table');
	assert(inp.msg_handler == nil or type(inp.msg_handler) == 'string');
	assert(inp.hdrs ~= nil and type(inp.hdrs) == 'table');
	assert(type(inp.external) == 'boolean');
	assert(inp.secure == nil or type(inp.secure) == 'boolean');
	if (inp.secure == nil) then
		inp.secure = false;
	end
	assert(inp.timeout == nil or type(inp.timeout) == 'number');
	if (inp.timeout == nil) then
		inp.timeout = constants.RECV_TIMEOUT_EXTERNAL_SOCKETS;
	end
	local url = inp.url;
	local msg_handler = inp.msg_handler;
	local credentials = inp.credentials;
	local hdrs = inp.hdrs;

	local uri = client_factory.deduce_details(url);
	local conn = inp.conn;
    if (conn == nil) then
        conn = client_factory.new(uri._host, uri._port, inp.secure, inp.external, inp.timeout);
    end

	hdrs.method = "GET";
	hdrs.Connection = "Upgrade";
	hdrs.Upgrade = "websocket";
	local nonce = create_key();
	hdrs["Sec-WebSocket-Key"] = nonce;
	hdrs["Sec-WebSocket-Version"] = 13;

	conn:send_request(uri._path, hdrs);

	local status, msg, resp_status, resp_hdrs = conn:recv_response();
    if (not status) then
		return nil, resp_hdrs["X-msg"];
    end

	do
		local connection =  resp_hdrs["Connection"]
		if (connection == nil or string.lower(stringx.strip(connection)) ~= "upgrade") then
			return nil, "No Connection: Upgrade header in handshake response"
		end
		local upgrade = resp_hdrs["Upgrade"];
		if (upgrade == nil or string.lower(stringx.strip(upgrade)) ~= "websocket") then
			return nil, "No Upgrade: websocket header in handshake response";
		end
		local accept = resp_hdrs["Sec-WebSocket-Accept"];
		if (accept == nil or (stringx.strip(accept)) ~= (compute_accept(nonce))) then
            print(debug.getinfo(1).source, debug.getinfo(1).currentline);
            print(stringx.strip(accept), compute_accept(nonce));
            print(debug.getinfo(1).source, debug.getinfo(1).currentline);
			return nil, "Invalid or missing Sec-WebSocket-Accept header in handshake response";
		end
	end

    if (msg_handler ~= nil) then
        platform.track_ss_as_websocket(conn._ss, msg_handler);
        conn.msg_handler = inp.msg_handler;
    end

	return conn, resp_status, resp_hdrs;
end

ws.handle_msg = function(request, response)
	local ss = platform.get_accepted_stream_socket();
	local msg = ws_util.__recv_frame(ss, 1);
	msg._ss = ss;

	if (msg.op_code == ws_const.FRAME_OP_PING) then
		if (msg.payload_len > 125) then
			platform.set_acc_sock_to_be_closed();
			error("Control frames must not have messages longer than 125 bytes");
		end
		local handler;
		local ws_msg_handler = platform.get_ws_recvd_msg_handler();
		if (ws_msg_handler ~= nil) then handler = require(ws_msg_handler); end
		if (handler and handler.handle_ping ~= nil) then
			handler.handle_ping(msg);
		else
			print(ffi.string(msg.buf));
		end
		ws_util.send_frame({
            ss = ss,
            size = msg.payload_len,
            flags = ws_const.FRAME_OP_PONG,
            buf = msg.buf,
            use_mask = true,
            acc_sock = true,
        });
	elseif (msg.op_code == ws_const.FRAME_OP_PONG) then
		local ws_msg_handler = platform.get_ws_recvd_msg_handler();
		local handler;
		if (ws_msg_handler ~= nil) then handler = require(ws_msg_handler); end
		if (handler and handler.handle_pong ~= nil) then
			return handler.handle_pong(msg);
		else
			print(ffi.string(msg.buf));
			return;
		end
	elseif (msg.op_code == ws_const.FRAME_OP_TEXT or msg.op_code == ws_const.FRAME_OP_BINARY) then
		local ws_msg_handler = platform.get_ws_recvd_msg_handler();
		local handler = require(ws_msg_handler);
		return handler.handle_message(msg);
	elseif (msg.op_code == ws_const.FRAME_OP_CLOSE) then
		platform.set_acc_sock_to_be_closed();
		--platform.shutdown_websocket(ss, 1);
	else
		error("Invalid OP_CODE ".. string.format("%0X", msg.op_code));
	end
	return;
end


return ws;
