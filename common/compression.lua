local ffi = require('ffi');
local cu = require('lua_schema.core_utils');
local compression = {};

compression.compress_data = function(data)
	assert(type(data) == 'string' or
			( type(data) == 'cdata' and
			  ffi.istype("hex_data_s_type", data)));

	local out = cu.new_hex_data_s_type();
	local buf, out_len;
	if (type(data) == 'string') then
		buf, out_len = platform.compress_data(data);
	else
		buf, out_len = platform.compress_data(ffi.getptr(data.value), tonumber(data.size));
	end

	out.size = out_len;
	out.value = buf;
	out.buf_mem_managed = 1;

	return out;
end

compression.uncompress_text_data = function(buffer)
	assert( type(buffer) == 'cdata' and
			ffi.istype("hex_data_s_type", buffer));

	local text_data = platform.uncompress_text_data(ffi.getptr(buffer.value), tonumber(buffer.size));

	return text_data;
end

compression.uncompress_binary_data = function(buffer)
	assert( type(buffer) == 'cdata' and
			ffi.istype("hex_data_s_type", buffer));

	local o_data, sz = platform.uncompress_binary_data(ffi.getptr(buffer.value), tonumber(buffer.size));

	local out = cu.new_hex_data_s_type();
	out.size = sz;
	out.value = o_data;
	out.buf_mem_managed = 1;

	return out;
end


return compression;
