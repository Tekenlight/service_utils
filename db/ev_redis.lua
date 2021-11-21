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
local loaded, lib = pcall(ffi.load, 'libevredis.so');

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

--[[
--The following three functions are added to be compliant to the
--interface of a db connection as needed by the REST controller.
--]]
ev_redis_connection.begin = function(self, key, value) return; end
ev_redis_connection.commit = function(self, key, value) return; end
ev_redis_connection.rollback = function(self, key, value) return; end

return ev_redis_db;


