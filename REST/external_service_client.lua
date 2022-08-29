local schema_processor = require("schema_processor");
local rest_client_factory = require('service_utils.REST.client');
local cjson = require('cjson.safe');
local json_parser = cjson.new();
local core_utils = require("lua_schema.core_utils");
local properties_funcs = platform.properties_funcs();
local service_client = require('service_utils.REST.service_client');

local external_service_client = {};

external_service_client.make_connection = function(inp)
	assert(type(inp) == 'table');
	assert(type(inp.url) == 'string');
	assert(inp.port == nil or math.type(inp.port) == 'integer');
	assert(inp.secure == nil or type(inp.secure) == 'boolean');

	local client = rest_client_factory.new(inp.url, tonumber(inp.port), inp.secure);

	return client;
end

external_service_client.transceive = function(client, headers, inp)
	assert(type(client) == 'table');
	assert(type(headers) == 'table');
	assert(type(inp) == 'table');

	local method_properties, interface_class = service_client.get_interface_method_properties({}, inp);

	local uri = service_client.prepare_uri({}, inp);
	local request_json = service_client.prepare_request_json({}, method_properties, inp);

	local status, response, http_status = service_client.core_transcieve({}, client, uri, headers, request_json);
	if (not status) then
		return status, response, http_status;
	end

	local response_json = response;
	local obj = service_client.prepare_response_obj({}, method_properties, response_json);

	return status, obj, http_status;
end

return external_service_client;

