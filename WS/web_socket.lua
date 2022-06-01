local stringx = require("pl.stringx");
local json_parser = (require('cjson.safe')).new();
local URI_CLASS = require("uri");
local evl_crypto = (package.loadlib('libevlcrypto.so','luaopen_libevlcrypto'))();
local core_utils = require("lua_schema.core_utils");
local properties_funcs = platform.properties_funcs();
local utils = require('service_utils.common.utils');
local client_factory = require('service_utils.REST.client');

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

	return core_utils.base64_encode(core_utils.hex_decode(evl_crypto.s_sha1_hash(accept)));
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
	local rnd = utils.get_rand_bytes(4);
	return core_utils.base64_encode(rnd);
end

ws.accept = function(request, response)
	assert(request ~= nil and tostring(request) == 'httpsreq');
	assert(response ~= nil and tostring(response) == 'httpsresp');

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
		local app_base_path = properties_funcs.get_string_property("service_utils.REST.controller.appBasePath");
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
		platform.set_ws_recvd_msg_handler(ws_recvd_msg_handler);
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
		local flg, msg = handler.init(request, response);
		if (not flg) then
			gen_err_resp(request, response, msg);
			return false;
		end
	end

	response:set_status(101);
	response:set_hdr_field("Upgrade", "websocket");
	response:set_hdr_field("Connection", "Upgrade");
	response:set_hdr_field("Sec-WebSocket-Accept", compute_accept(key));
	response:set_content_length(0);
	response:send();

	return true;
end

ws.connect = function(url, credentials)
	assert(url ~= nil and type(url) == 'string');
	assert(credentials == nil or type(credentials) == 'table');
	local nonce = create_key();
	local uri = client_factory.deduce_details(url);
	local conn = client_factory.new(uri._host, uri._port);
	local hdrs = {};
	hdrs.method = "GET";
	hdrs.Connection = "Upgrade";
	hdrs.Upgrade = "websocket";
	hdrs["Sec-WebSocket-Key"] = "ALKJSKLAJFKLDJFKLJDSFKJD";
	hdrs["Sec-WebSocket-Version"] = 13
	conn:send_request(uri._path, hdrs);
	local status, msg, resp_status, resp_hdrs = conn:recv_response();
    if (not status) then
		print(status, "["..msg.."]");
    end

	return conn, resp_status, resp_hdrs
end


return ws;
