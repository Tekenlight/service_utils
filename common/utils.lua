local ffi = require("ffi");
local core_utils = require('lua_schema.core_utils');
local utils = {}

ffi.cdef[[
int getentropy(void *buf, size_t buflen);
]]

function utils.get_rand_int()
	local ip = ffi.new("unsigned int [?]", 1);
	ffi.C.getentropy(ip, 4);
	return tonumber(ip[0]);
end

function utils.get_rand_bytes(size)
	assert(size ~= nil and math.type(size) == 'integer');

	local cp = ffi.new("unsigned char [?]", size);
	ffi.C.getentropy(cp, size);

	local bin_inp = core_utils.new_hex_data_s_type();
	bin_inp.size = size;

	bin_inp.value = ffi.C.malloc(size+1);
	ffi.C.memset(bin_inp.value, 0, (bin_inp.size+1));
	ffi.C.memcpy(bin_inp.value, cp, bin_inp.size);

	return bin_inp;
end


return utils;
