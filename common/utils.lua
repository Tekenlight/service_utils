local ffi = require("ffi");
local core_utils = require('lua_schema.core_utils');
local List = require('pl.List');
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

	local bin_inp = core_utils.new_binary_buffer();
	bin_inp.size = size;

	bin_inp.value = core_utils.alloc(size+1);
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

--[[
    Slices the input table (array) from first to last, both indices inclusive
    First element of an array is assumed to be 1
]]
utils.table_slice = function(tbl, first, last)
    return List(tbl):slice(first, last);
end

utils.starts_with = function(str, prefix)
    assert(type(str) == 'string');
    assert(type(prefix) == 'string');
    return (string.sub(str, 1, #prefix) == prefix)
end

utils.pdf_to_text = function(pdf_path, txt_path, err_log_path)
    assert(type(pdf_path) == 'string', "Invalid pdf_path");
    assert(type(txt_path) == 'string', "Invalid txt_path");
    assert(type(err_log_path) == 'string', "Invalid err_log_path");

    local ok
    local a = os.execute(string.format('pdftotext -layout "%s" "%s" 2>"%s"', pdf_path, txt_path, err_log_path));
    if type(a) == "number" then
        ok = (a == 0);
    else
        ok = (a == true);
    end
    os.remove(pdf_path);

    if not ok then
        local err_log = "";
        local f = io.open(err_log_path, "r");
        if f then
            err_log = f:read("*a");
            f:close();
        end
        os.remove(err_log_path);
        os.remove(txt_path);
        return false, nil, "pdftotext failed (is poppler-utils installed?): " .. err_log;
    end
    os.remove(err_log_path);

    local text = "";
    local tf = io.open(txt_path, "r");
    if tf then
        text = tf:read("*a");
        tf:close();
    end
    os.remove(txt_path);

    return true, text, nil;
end

return utils;
