local ffi = require('ffi');
local error_handler = require("lua_schema.error_handler");
local cjson = require('cjson.safe');
local schema_processor = require("schema_processor");

local service_client = require('service_utils.REST.external_service_client');
local properties_funcs = platform.properties_funcs();

local host_utils = {};
local client;

host_utils.parse_url = function(property_name)
	assert(type(property_name) == 'string');

	local host_url = properties_funcs.get_string_property(property_name);
	assert(type(host_url) == 'string');
	assert(string.sub(host_url, 1, 1) == '/');

	local url_parts = {};
	for i,v in ipairs((require "pl.stringx".split(host_url, '/'))) do
		if (i ~= 1) then
			url_parts[i-1] = v;
		end
	end

	assert(url_parts[1] ~= nil);
	assert(url_parts[2] ~= nil);
	assert(url_parts[3] ~= nil);
	assert(url_parts[4] ~= nil);

	return url_parts;
end

host_utils.resolve = function(property_name)
	assert(type(property_name) == 'string');

	local host_config_xml = properties_funcs.get_string_property(property_name);
	assert(type(host_config_xml) == 'string');

	local host_confg_rec_handler =
			schema_processor:get_message_handler('host_config_rec', 'http://evpoco.tekenlight.org/idl_spec');
    local host_ent, msg = host_confg_rec_handler:from_xml(host_config_xml);
	assert(type(host_ent) == 'table');
	assert(host_ent.host ~= nil);

	if (host_ent.port ~= nil) then
		host_ent.port = tonumber(host_ent.port);
	end
	if (host_ent.secure == nil) then
		host_ent.secure = false;
	end
	if (host_ent.port == nil or host_ent.port == 0) then
		if (host_ent.protocol ~= nil) then
			if (string.upper(host_ent.protocol) == 'HTTP') then
				if (type(host_ent.secure) == 'boolean' and host_ent.secure) then
					host_ent.port = 443;
				else
					host_ent.port = 80;
				end
			elseif (string.upper(host_ent.protocol) == 'SMTP') then
				if (type(host_ent.secure) == 'boolean' and host_ent.secure) then
					host_ent.port = 587;
				else
					host_ent.port = 25;
				end
			elseif (string.upper(host_ent.protocol) == 'FTP') then
				if (type(host_ent.secure) == 'boolean' and host_ent.secure) then
					host_ent.port = 22;
				else
					host_ent.port = 21;
				end
			elseif (string.upper(host_ent.protocol) == 'SFTP') then
				host_ent.port = 22;
			else
				error("Unable to resolve port number");
			end
		end
	end

	return host_ent;
end

return host_utils;



