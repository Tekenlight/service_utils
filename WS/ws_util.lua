local ffi = require("ffi");
local cu = require('lua_schema.core_utils');
local utils = require('service_utils.common.utils');
local ws_const = require('service_utils.WS.ws_const');
local pool = (require('service_utils.common.pool_repos')).new('WEBSOCKETS', true)
local constants = require('service_utils.common.constants');

ffi.cdef[[
char * strncpy(char * dst, const char * src, size_t len);
void * memcpy(void *restrict dst, const void *restrict src, size_t n);
uint64_t network_to_host_byte_order_64(uint64_t h_ll, uint64_t * o_h_ll);
uint16_t network_to_host_byte_order_16(uint16_t h_s, uint16_t * o_h_s);
uint64_t host_to_network_byte_order_64(uint64_t h_ll, uint64_t * o_h_ll);
uint16_t host_to_network_byte_order_16(uint16_t h_s, uint16_t * o_h_s);
]]

local function net_to_host_uint64(inp)
	assert(inp ~= nil);
	return ffi.C.network_to_host_byte_order_64(inp, ffi.NULL);
end

local function net_to_host_uint16(inp)
	assert(inp ~= nil);
	return ffi.C.network_to_host_byte_order_16(inp, ffi.NULL);
end

local function host_to_net_uint64(inp)
	assert(inp ~= nil);
	return ffi.C.host_to_network_byte_order_64(inp, ffi.NULL);
end

local function host_to_net_uint16(inp)
	assert(inp ~= nil);
	return ffi.C.host_to_network_byte_order_16(inp, ffi.NULL);
end


local ws_util = {};

ws_util.recv_bytes = function(ss, n, mode, conn)
	assert(type(mode) == 'number');
	assert(n ~= nil and type(n) == 'number' and n > 0);
	if (not platform.socket_active(ss)) then
        print(ss);
        print(debug.traceback());
		error("SOCKET INACTIVE");
	end

    local recv_timeout = (conn ~= nil and conn._recv_timeout ~= nil) and  conn._recv_timeout or constants.RECV_TIMEOUT_EXTERNAL_SOCKETS;
    local send_timeout = (conn ~= nil and conn._send_timeout ~= nil) and  conn._send_timeout or constants.SEND_TIMEOUT_EXTERNAL_SOCKETS;

	local buf = ffi.new("unsigned char[?]", n);
	local buf1 = buf;
	local status, ret = false, 0;
	while (ret < n) do
		local buf1 = buf + ret;
		local ret1 = 0;
		local n1 = n - ret;
		local NEVER = false;
		if (NEVER) then
			n1 = n1 - 1;
			print(debug.getinfo(1).source, debug.getinfo(1).currentline, buf1);
			print(debug.getinfo(1).source, debug.getinfo(1).currentline, n1);
			if (n1 == 0) then
				n1 = n1 + 1;
			end
		end
		status, ret1 = pcall(platform.recv_data_from_socket, ss, ffi.getptr(buf1), n1, recv_timeout);
		if (not status) then
			if (mode == 0) then
				platform.shutdown_websocket(ss, 3);
			else
				platform.set_acc_sock_to_be_closed();
			end
			error(ret1);
		end
		if (ret1 <=0) then
			if (mode == 0) then
				platform.shutdown_websocket(ss, 3);
			else
				platform.set_acc_sock_to_be_closed();
			end
			error("Receving data from websocket failed");
		end
		ret = ret + ret1;
	end

	return buf, n

end

ws_util.send_bytes = function(ss, buf, n, acc_sock, conn)
	assert(n ~= nil and type(n) == 'number' and n > 0);
	assert(buf ~= nil and type(buf) == 'cdata');
    assert(acc_sock ~= nil and type(acc_sock) == 'boolean');

	if (not platform.socket_active(ss)) then
		error("SOCKET INACTIVE");
	end

    local recv_timeout = (conn ~= nil and conn._recv_timeout ~= nil) and  conn._recv_timeout or constants.RECV_TIMEOUT_EXTERNAL_SOCKETS;
    local send_timeout = (conn ~= nil and conn._send_timeout ~= nil) and  conn._send_timeout or constants.SEND_TIMEOUT_EXTERNAL_SOCKETS;

	local status, ret;
    if (acc_sock) then
        status, ret = pcall(platform.send_data_on_acc_socket, ss, ffi.getptr(buf), n);
    else
        status, ret = pcall(platform.send_data_on_socket, ss, ffi.getptr(buf), n, send_timeout);
    end
	if (not status) then
		error(ret);
	end
	if (ret <=0) then
		error("Receving data from websocket failed");
	end

	return ret;
end

ws_util.recv_header = function(ss, mode, conn)
	local payload_len, use_mask, buf, mask = 0, false;

	buf = ws_util.recv_bytes(ss, 2, mode, conn);

	local flags = tonumber(buf[0]);
	local len_byte = tonumber(buf[1]);

	use_mask = ((len_byte & ws_const.FRAME_FLAG_MASK) ~= 0);
	len_byte = len_byte & 0X7F;

	if (len_byte == 127) then
		buf = ws_util.recv_bytes(ss, 8, mode, conn);
		local be_len = ffi.new("uint64_t [?]", 1);
		ffi.C.memcpy(be_len, buf, 8);
		payload_len = net_to_host_uint64(be_len[0]);
	elseif (len_byte == 126) then
		buf = ws_util.recv_bytes(ss, 2, mode, conn);
		local be_len = ffi.new("uint16_t [?]", 1);
		ffi.C.memcpy(be_len, buf, 2);
		payload_len = net_to_host_uint16(be_len[0]);
	else
		payload_len = len_byte;
	end

	if (use_mask) then
		mask = ws_util.recv_bytes(ss, 4, mode, conn);
	end

	local op_code = flags & 0X0F

	return { payload_len=payload_len, use_mask=use_mask, mask=mask, flags = flags, op_code = op_code};
end

ws_util.recv_payload = function(ss, inps, mode, conn)
	local buf = ws_util.recv_bytes(ss, inps.payload_len, mode, conn);
	if (inps.use_mask) then
		for i = 1, inps.payload_len, 1 do
			local m = tonumber(inps.mask[(i-1)%4]);
			local n = m ~ tonumber(buf[i-1]);
			buf[i-1] = ffi.cast("unsigned char", n);
		end
	end
	return buf;
end

ws_util.__recv_frame = function(ss, mode, conn)
	do
		if (mode == nil) then mode = 0; end
		assert(ss ~= nil);
		local s = (require("pl.stringx")).split(tostring(ss), ":");
		assert(s[1] ~= nil and s[1] == 'streamsocket');
	end
	local msg_meta = ws_util.recv_header(ss, mode, conn)
	msg_meta.buf = ws_util.recv_payload(ss, msg_meta, mode, conn);

	return msg_meta;
end

ws_util.recv_frame = function(conn)
	local ss;
	do
		assert(conn ~= nil and type(conn) == 'table');
	end
	if (conn.msg_handler ~= nil) then
		error("Cannot invoke ws_util.recv_frame when message_handler is set for the websocket");
	end
	ss = conn._ss
	return ws_util.__recv_frame(ss, nil, conn);
end

ws_util.form_header = function(inp, buf)
	local hdr_len = 0;
	if (inp.flags == 0) then
		inp.flags = ws_const.FRAME_BINARY;
	end

	inp.flags = inp.flags & 0xFF;
	buf[hdr_len] = inp.flags;
	hdr_len = hdr_len + 1;

	local len_byte = 0;
	if (inp.use_mask) then
		len_byte = len_byte | ws_const.FRAME_FLAG_MASK;
	end

	if (inp.size < 126) then
		len_byte = len_byte | inp.size
		buf[hdr_len] = ffi.cast("uint8_t", len_byte);
		hdr_len = hdr_len + 1;
	elseif (inp.size < 0X10000) then
		len_byte = len_byte | 0X7E; -- 126
		buf[hdr_len] = ffi.cast("uint8_t", len_byte);
		hdr_len = hdr_len + 1;
		local be_len_a = ffi.new("uint16_t [?]", 1);
		be_len_a[0] = ffi.cast("uint16_t", host_to_net_uint16(ffi.cast("uint16_t", inp.size)));
		ffi.C.memcpy((buf+hdr_len), be_len_a, 2);
		hdr_len = hdr_len + 2;
	else
		len_byte = len_byte | 0X7F; -- 127
		buf[hdr_len] = ffi.cast("uint8_t", len_byte);
		hdr_len = hdr_len + 1;
		local be_len_a = ffi.new("uint64_t [?]", 1);
		be_len_a[0] = ffi.cast("uint64_t", host_to_net_uint64(ffi.cast("uint64_t", inp.size)));
		ffi.C.memcpy((buf+hdr_len), be_len_a, 8);
		hdr_len = hdr_len + 8;
	end

	if (inp.use_mask) then
		inp.mask = utils.get_rand_bytes(4);
		ffi.C.memcpy((buf+hdr_len), inp.mask.value, 4);
		hdr_len = hdr_len + 4;
	end

	inp.hdr_len = hdr_len;
	return;
end

ws_util.form_payload = function(inp, buf)
	if (inp.use_mask) then
		local mask = inp.mask;
		local hdr_len = inp.hdr_len;
		for i = 1, inp.size, 1 do
			local m = tonumber(mask.value[(i-1)%4]);
			local n = m ~ tonumber(inp.buf[i-1]);
			buf[hdr_len+(i-1)] = ffi.cast("unsigned char", n);
		end
	else
		ffi.C.memcpy((buf + inp.hdr_len), inp.buf, inp.size);
	end
	inp.total_len = inp.hdr_len + inp.size;

	return;
end

ws_util.send_frame = function(inp)
	do
		assert(inp ~= nil and type(inp) == 'table');
		assert(inp.ss ~= nil);
		local s = (require("pl.stringx")).split(tostring(inp.ss), ":");
		assert(s[1] ~= nil and s[1] == 'streamsocket');
		assert(inp.size ~= nil and math.type(inp.size) == 'integer');
		assert(inp.flags ~= nil and math.type(inp.flags) == 'integer');
		assert(inp.buf ~= nil and type(inp.buf) == 'cdata');
		--local typnam = "uint8_t ["..inp.size.."]";
		--assert(inp.buf ~= nil and ffi.istype(typnam, inp.buf));
		assert(inp.use_mask ~= nil and type(inp.use_mask) == 'boolean');
	end
	--[[inp.flags = inp.flags | ws_const.FRAME_OP_SETRAW;
	--This is done in Poco library,
	--have not realized the need for it.
	--]]

	local buf = ffi.new("unsigned char [?]", (inp.size + ws_const.MAX_HEADER_LENGTH));
	ws_util.form_header(inp, buf);
	ws_util.form_payload(inp, buf);
	ws_util.send_bytes(inp.ss, buf, inp.total_len, inp.acc_sock, inp.conn);

	return inp;
end

ws_util.send_msg = function(conn, msg, options)
	local ss;
	do
		assert(conn ~= nil and type(conn) == 'table');
		ss = conn._ss;
		assert(ss ~= nil and type(ss) == 'userdata');
		local s = (require("pl.stringx")).split(tostring(ss), ":");
		assert(s[1] ~= nil and s[1] == 'streamsocket');
		assert(msg ~= nil and type(msg) == 'string');
        if (options == nil) then
            options = {
                msg_type = "BINARY";
            };
        end
        assert(type(options) == 'table');
	end
	local buf = ffi.new("unsigned char[?]", string.len(msg));
	ffi.C.strncpy(buf, msg, string.len(msg));

	return ws_util.send_frame({
        ss = ss,
        size = string.len(msg),
        flags = (options.msg_type == "TEXT") and ws_const.FRAME_TEXT or ws_const.FRAME_BINARY,
        buf = buf,
        use_mask = true,
        acc_sock = (conn.msg_handler ~= nil),
        conn = conn
    });
end

ws_util.close = function(conn)
	do
		assert(conn ~= nil and type(conn) == 'table');
	end
	local lbuf = "CLOSING WEBSOCKET";
	local buf = ffi.cast("unsigned char *", lbuf);
	local send_meta =  ws_util.send_frame({
        ss = conn._ss,
        size = string.len(lbuf),
        flags = ws_const.FRAME_OP_CLOSE,
        buf = buf, use_mask = true,
        acc_sock = (conn.msg_handler ~= nil),
    });
    if (conn.msg_handler ~= nil) then
        platform.shutdown_websocket(conn._ss, 1);
    else
        platform.close_tcp_connection(conn._ss);
    end
	return send_meta;
end

ws_util.ping = function(conn, payload)
	do
		assert(conn ~= nil and type(conn) == 'table');
		assert(payload == nil or (type(payload) == 'string' and string.len(payload) <=125));
	end
	if (payload == nil) then
		payload = 'PING';
	end
	local buf = ffi.cast("unsigned char *", payload);
	return ws_util.send_frame({
        ss = conn._ss,
        size = string.len(payload),
        flags = ws_const.FRAME_OP_PING,
        buf = buf, use_mask = true,
        acc_sock = (conn.msg_handler ~= nil),
    });
end

ws_util.get_ws_from_pool = function(wsname)
	local ss = pool:share_from_pool(wsname);
	if (ss ~= nil) then
		while (ss ~= nil and (not platform.websocket_active(ss))) do
			ss = pool:share_from_pool(wsname);
		end
	end
	if (ss == nil) then
		return nil;
	else
		return { _ss = ss, shared = true;};
	end
end

ws_util.add_ws_to_pool = function(conn, name)
	assert(conn ~= nil and type(conn) == 'table');
	assert(name ~= nil and type(name) == 'string');
	assert(conn._ss ~= nil and type(conn._ss) == 'userdata');
	if (conn.shared == nil or conn.shared == false) then
		--print(debug.getinfo(1).source, debug.getinfo(1).currentline, "NOT SHARED CONNECTION");
		pool:add_to_pool(name, conn._ss);
	else
		--print(debug.getinfo(1).source, debug.getinfo(1).currentline, "SHARED CONNECTION");
	end
end

return ws_util;
