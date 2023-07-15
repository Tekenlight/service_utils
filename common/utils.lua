local ffi = require("ffi");
local core_utils = require('lua_schema.core_utils');
local utils = {}

ffi.cdef[[
int getentropy(void *buf, size_t buflen);
void * pin_loaded_so(const char * libname);
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

function utils.os_name()
	local uname_s = ffi.new("struct utsname", {});
	ffi.C.uname(uname_s);

	return (ffi.string(uname_s.sysname));
end

function utils.pin_loaded_so(libname)
	assert(libname ~= nil and type(libname) == 'string');
	local loaded, lib = pcall(ffi.C.pin_loaded_so, libname);
	if (not loaded) then
		error("Could not load library ["..libname"] : "..lib);
	end
end

function utils.load_library(libname, extension)
	assert(libname ~= nil and type(libname) == 'string');
	assert(extension == nil or type(extension) == 'string');

	local libname_full;
	if (extension == nil) then
		if ('Darwin' == (require('lua_schema.core_utils')).os_name()) then
			extension = 'dylib';
		else
			extension = 'so';
		end
	end
	libname_full = libname..'.'..extension;

	local libhandle, msg = package.loadlib(libname_full,'luaopen_'..libname);
	if (libhandle == nil) then
		error("Could not load library " .. libname_full ..":".. msg);
	end
	local loaded, lib = pcall(libhandle);
	if(not loaded) then
		error("Could not load library : "..libname_full.. ":"..lib);
	end
	utils.pin_loaded_so(libname_full);
	return lib;
end

return utils;
