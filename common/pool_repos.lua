local ffi = require('ffi');

local libname = 'libevpoolrepos.so';
local repos_loader = package.loadlib(libname,'luaopen_libevpoolrepos');
local loaded, repos_lib = pcall(repos_loader);
if(not loaded) then
	error("Could not load library");
end
ffi.cdef[[
void * pin_loaded_so(const char * libname);
]]
local loaded, lib = pcall(ffi.C.pin_loaded_so, libname);
if (not loaded) then
	error("Could not load library ["..libname.."] : "..lib);
end

local pool_repos = {}
local pool = {};
local p_mt = { __index = pool };

pool.add_to_pool = function(self, name, ss)
	do
		assert(self~= nil and type(self) == 'table');
		assert(self._pool ~= nil and type(self._pool) == 'userdata');
		assert(name ~= nil and type(name) == 'string');
		assert(ss ~= nil and type(ss) == 'userdata');
		local s = (require("pl.stringx")).split(tostring(ss), ":");
		assert(s[1] ~= nil and s[1] == 'streamsocket');
	end

	self._pool.add_to_pool(self._pool, name, ss);
	return;
end

pool.get_from_pool = function(self, name)
	do
		assert(self~= nil and type(self) == 'table');
		assert(self._pool ~= nil and type(self._pool) == 'userdata');
		assert(name ~= nil and type(name) == 'string');
	end
	local ss = self._pool.get_from_pool(self._pool, name);
	if (ss == nil) then
		return nil;
	else
		return ss;
	end
end

pool_repos.new = function(poolname)
	assert(poolname ~= nil and type(poolname) == 'string');
	local pool = {};
	pool._pool = repos_lib.new(poolname);
	pool = setmetatable(pool, p_mt);

	return pool
end

return pool_repos;
