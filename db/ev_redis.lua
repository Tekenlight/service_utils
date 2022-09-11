local ffi = require("ffi");
local bc = require("bigdecimal");
local du = require('lua_schema.date_utils');
local cu = require('lua_schema.core_utils');
local types = require('service_utils.db.ev_types');
local evredis_init = package.loadlib('libevredis.so','luaopen_evredis');
local loaded, evredis = pcall(evredis_init);
if(not loaded) then
	error("Could not load library");
end

--[[
--The below is done to ensure that libevpostgres.so remains loaded even when dlclose is called
--]]
ffi.cdef[[
void * pin_loaded_so(const char * libname);
]]
local libname = 'libevredis.so';
local loaded, lib = pcall(ffi.C.pin_loaded_so, libname);
if (not loaded) then
	error("Could not load library [libevredis.so] : "..lib);
end

local ev_redis_connection = { exec = false;};
local ev_redis_db = {};

local c_mt = { __index = ev_redis_connection };

local open_connetion_internal = function(host, port, dbname, user, password)
	local conn, msg = evredis.new(host, port, dbname, user, password);
	if (nil == conn) then
		return nil, msg;
	end
	local c = {_conn = conn}
	c = setmetatable(c, c_mt);
	return c;
end

ev_redis_db.open_connetion = function(host, port, dbname, user, password)
	assert(host ~= nil and type(host) == 'string');
	assert(port ~= nil and type(port) == 'string');
	assert(dbname ~= nil and type(dbname) == 'string');
	assert(user ~= nil and type(user) == 'string');
	assert(password ~= nil and type(password) == 'string');

	local conn, msg = open_connetion_internal(host, port, dbname, user, password)
	if (conn == nil) then
		error("ERROR INITIATING CONNECTION:"..tostring(msg));
		return nil;
	end

	return conn;
end

local function valid_key(key)
	assert(key ~= nil);
	assert(type(key) == 'string');
end

local function valid_score(score)
	assert(score ~= nil);
	assert((type(score) == 'number') or
			(type(score) == 'string' and (score == '+inf' or score == '-inf')));
end

local function valid_self(self)
	assert(self ~= nil);
	assert(type(self) == 'table');
	assert(getmetatable(self) == c_mt);
	assert(self._conn ~= nil);
	assert(type(self._conn) == 'userdata');
	assert(string.match(tostring(self._conn), '[^:]+') == 'REDIS_CONNECTION');
end

local function valid_value(value)
	assert(value ~= nil);
	local tn = type(value);
	assert(( (tn == 'string') or (tn == 'number') or (tn == 'boolean')));
end

ev_redis_connection.get = function(self, key)
	valid_self(self);
	valid_key(key);

	local query = 'GET '..key;
	local status, response, msg = self._conn:transceive(query);
	if (not status) then
		return status, nil, msg;
	else
		return status, response;
	end
end

ev_redis_connection.del = function(self, key)
	valid_self(self);
	valid_key(key);

	local query = 'DEL '..key;
	local status, response, msg = self._conn:transceive(query);
	if (not status) then
		return status, nil, msg;
	else
		return status, response;
	end
end

ev_redis_connection.getdel = function(self, key)
	valid_self(self);
	valid_key(key);

	local query = 'GETDEL '..key;
	local status, response, msg = self._conn:transceive(query);
	if (not status) then
		return status, nil, msg;
	else
		return status, response;
	end
end

ev_redis_connection.set = function(self, key, value)
	valid_self(self);
	valid_key(key);
	valid_value(value);

	local query = 'SET '..key..' '..tostring(value);
	local status, response, msg = self._conn:transceive(query);
	if (not status) then
		return status,  msg;
	else
		return status;
	end
end

ev_redis_connection.zadd = function(self, key, score, value)
	valid_self(self);
	valid_key(key);
	valid_score(score);
	valid_value(value);

	--local query = 'ZADD '..key..' '..tostring(score)..' \"'..tostring(value)..'\"';
	local query = 'ZADD '..key..' '..tostring(score)..' '..tostring(value);
	local status, response, msg = self._conn:transceive(query);
	if (not status) then
		return status,  msg;
	else
		return status;
	end
end

ev_redis_connection.zrem = function(self, key, value)
	valid_self(self);
	valid_key(key);
	valid_value(value);

	--local query = 'ZADD '..key..' '..tostring(score)..' \"'..tostring(value)..'\"';
	local query = 'ZREM '..key..' '..tostring(value);
	local status, response, msg = self._conn:transceive(query);
	if (not status) then
		return status,  msg;
	else
		return status;
	end
end

ev_redis_connection.zremrangebyscore = function(self, key, score1, score1_inclusive, score2, score2_inclusive)
	valid_self(self);
	valid_key(key);
	valid_score(score1);
	assert(score1_inclusive ~= nil and type(score1_inclusive) == 'boolean');
	if (score ~= nil) then
		valid_score(score2);
		assert(score2_inclusive ~= nil and type(score2_inclusive) == 'boolean');
	end

	if (score1_inclusive) then score1_inclusive = ''; else score1_inclusive = '('; end
	if (score2 ~= nil) then
		if (score2_inclusive) then score2_inclusive = ''; else score2_inclusive = '('; end
	end

	local query = 'ZREMRANGEBYSCORE '..key..' '..score1_inclusive..tostring(score1);
	if (score2 ~= nil) then
		query = query..' '..score2_inclusive..tostring(score2);
	end
	local status, response, msg = self._conn:transceive(query);
	if (not status) then
		return status, nil, msg;
	else
		return status, response;
	end
end

ev_redis_connection.zrangebyscore = function(self, key, score1, score1_inclusive, score2, score2_inclusive)
	valid_self(self);
	valid_key(key);
	valid_score(score1);
	valid_score(score2);
	assert(score1_inclusive ~= nil and type(score1_inclusive) == 'boolean');
	assert(score2_inclusive ~= nil and type(score2_inclusive) == 'boolean');

	if (score1_inclusive) then score1_inclusive = ''; else score1_inclusive = '('; end
	if (score2_inclusive) then score2_inclusive = ''; else score2_inclusive = '('; end

	local query = 'ZRANGEBYSCORE '..key..' '..score1_inclusive..tostring(score1)..' '..score2_inclusive..tostring(score2);
	local status, response, msg = self._conn:transceive(query);
	if (not status) then
		return status, nil, msg;
	else
		return status, response;
	end
end

--[[
--The following four functions are added to be compliant to the
--interface of a db connection as needed by the REST controller.
--]]
ev_redis_connection.begin = function(self, key, value) return; end
ev_redis_connection.commit = function(self, key, value) return; end
ev_redis_connection.rollback = function(self, key, value) return; end
ev_redis_connection.close_open_cursors = function(self, key, value) return; end

return ev_redis_db;


