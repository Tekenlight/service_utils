local ffi = require('ffi');
local error_handler = require("lua_schema.error_handler");
local cjson = require('cjson.safe');
local schema_processor = require("schema_processor");

local service_client = require('service_utils.REST.external_service_client');
local properties_funcs = platform.properties_funcs();

local host_utils = {};
local client;

host_utils.resolve = function(property_name)
	assert(type(property_name) == 'string');

	local aaa_host_config_json = properties_funcs.get_string_property(property_name);
	assert(type(aaa_host_config_json) == 'string');

	local host_confg_rec_handler =
			schema_processor:get_message_handler('host_config_rec', 'http://evpoco.tekenlight.org/idl_spec');
    local host_ent, msg = host_confg_rec_handler:from_json(aaa_host_config_json);
	assert(type(host_ent) == 'table');
	assert(host_ent.host ~= nil);

	if (host_ent.port ~= nil) then
		host_ent.port = tonumber(host_ent.port);
	end
	if (host_ent.secure == nil) then
		host_ent.secure = false;
	end

	return host_ent;
end

return host_utils;



