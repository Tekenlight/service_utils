local schema_processor = require("schema_processor");
local rest_client_factory = require('service_utils.REST.client');
local cjson = require('cjson.safe');
local json_parser = cjson.new();
local core_utils = require("lua_schema.core_utils");
local properties_funcs = platform.properties_funcs();

local external_service_client = {};

external_service_client.make_connection = function(context, inp)
	assert(context ~= nil and type(context) == 'table');
	assert(type(inp) == 'table');
	assert(type(inp.url) == 'string');
	assert(inp.port == nil or math.type(inp.port) == 'integer');
	assert(inp.secure == nil or type(inp.secure) == 'boolean');

	local client = rest_client_factory.new(inp.url, tonumber(inp.port));
end

return external_service_client;

