local ffi = require("ffi");
local cu = require('lua_schema.core_utils');

ffi.cdef[[
void * memcpy(void *restrict dst, const void *restrict src, size_t n);
uint64_t network_to_host_byte_order_64(uint64_t h_ll, uint64_t * o_h_ll);
uint16_t network_to_host_byte_order_16(uint16_t h_s, uint16_t * o_h_s);
]]

local function net_to_host_uint64(inp)
	assert(inp ~= nil and ffi.istype("uint64_t", inp))
	return ffi.C.network_to_host_byte_order(inp, ffi.NULL);
end

local function net_to_host_uint16(inp)
	assert(inp ~= nil and ffi.istype("uint16_t", inp))
	return ffi.C.network_to_host_byte_order(inp, ffi.NULL);
end


local ws_util = {};

ws_util.recv_bytes = function(ss, n)
	assert(n ~= nil and type(n) == 'number' and n > 0);

	local buf = ffi.new("unsigned char[?]", n);
	local status, ret = false, 0;
	while (ret < n) do
		status, ret = pcall(platform.recv_data_from_socket, ss, ffi.getptr(buffer.buf), n);
		if (not status) then
			error(ret);
		end
		if (ret <=0) then
			error("Receving data from websocket failed");
		end
	end

	return buf, n

end

ws_util.recv_header = function(ss)
	local payload_len, use_mask, buf, mask = 0, false;

	buf = ws_util.recv_bytes(ss, 2);

	local flgs = tonumber(buf[0]);
	local len_byte = tonumber(buf[1]);

	use_mask = ((len_byte & ws_const.FRAME_FLAG_MASK) ~= 0);
	len_byte = len_byte & 0X7F;

	if (len_byte == 127) then
		buf = ws_util.recv_bytes(ss, 8);
		local be_len = ffi.new("uint64_t [?]", 1);
		ffi.C.memcpy(be_len, buf, 8);
		payload_len = net_to_host_uint64(be_len[0]);
	elseif (len_byte == 126) then
		buf = ws_util.recv_bytes(ss, 2);
		local be_len = ffi.new("uint16_t [?]", 1);
		ffi.C.memcpy(be_len, buf, 2);
		payload_len = net_to_host_uint16(be_len[0]);
	else
		payload_len = len_byte;
	end

	if (use_mask) then
		mask = ws_util.recv_bytes(ss, 4);
	end

	return { payload_len=payload_len, use_mask=use_mask, mask=mask, flgs = flgs};
end

ws_util.recv_payload = function(ss, inps)
	local buf = ws_util.recv_bytes(ss, inps.payload_len);
	if (inps.use_mask) then
		for i = 1, inps.payload_len, 1 do
			local m = tonumber(mask[(i-1)%4]);
			local n = m ~ tonumber(b[i-1]);
			buf[i-1] = ffi.cast("unsigned char", n);
		end
	end
	return buf;
end

ws_util.recv_bytes = function(ss)
	do
		assert(ss ~= nil);
		local s = (require("pl.stringx")).split(tostring(ss), ":");
		assert(s[1] ~= nil and s[1] == 'streamsocket');
	end
	local msg_meta = ws_util.recv_header(ss)
	msg_meta.buf = ws_util.recv_payload(ss, msg_meta);

	return msg_meta;
end




return ws_util;
