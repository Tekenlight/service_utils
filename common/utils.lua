local ffi = require("ffi");
local core_utils = require('lua_schema.core_utils');
local utils = {}

ffi.cdef[[
int getentropy(void *buf, size_t buflen);
void * pin_loaded_so(const char * libname);
double str_cosine_similarity(const char *str1, const char *str2);
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

function utils.uuid()
	local random = math.random
	local template = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
	return string.gsub(template, '[xy]', function(c)
		local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
		return string.format('%x', v)
	end)
end

function utils.string_similarity(s1, s2)
    assert(type(s1) == 'string');
    assert(type(s2) == 'string');

    return tonumber(ffi.C.str_cosine_similarity(s1, s2));
end

utils.tablecat = function(t2, t1)
    assert(type(t2) == 'table');
    assert(type(t1) == 'table');

    table.move(t1, 1, #t1, #t2 + 1, t2);

    return t2;
end

utils.table_splice = function(tbl, start, deleteCount, ...)
    local removed = {}

    -- Handle negative start index
    if start < 0 then
        start = #tbl + start + 1
    else
        start = math.max(1, start)
    end

    -- Remove elements
    for i = 1, deleteCount do
        table.insert(removed, tbl[start])
        table.remove(tbl, start)
    end

    -- Insert new elements
    local items = {...}
    for i = #items, 1, -1 do
        table.insert(tbl, start, items[i])
    end

    return removed
end


return utils;
