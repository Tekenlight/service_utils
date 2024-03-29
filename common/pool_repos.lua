local ffi = require('ffi');

local repos_lib = (require('service_utils.common.utils')).load_library('libevpoolrepos');

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

pool.share_from_pool = function(self, name)
	do
		assert(self~= nil and type(self) == 'table');
		assert(self._pool ~= nil and type(self._pool) == 'userdata');
		assert(name ~= nil and type(name) == 'string');
		assert(self.allow_sharing == true);
	end
	local ss = self._pool.share_from_pool(self._pool, name);
	if (ss == nil) then
		return nil;
	else
		return ss;
	end
end

pool_repos.new = function(poolname, allow_sharing)
	if (allow_sharing == nil) then
		allow_sharing = false;
	end
	assert(poolname ~= nil and type(poolname) == 'string');
	assert(allow_sharing ~= nil and type(allow_sharing) == 'boolean');

	local pool = {};
	pool._pool = repos_lib.new(poolname);
	pool = setmetatable(pool, p_mt);
	pool.allow_sharing = allow_sharing;

	return pool
end

return pool_repos;
