local schema_processor = require("schema_processor");
local rest_client_factory = require('service_utils.REST.client');
local cjson = require('cjson.safe');
local json_parser = cjson.new();
local core_utils = require("lua_schema.core_utils");
local properties_funcs = platform.properties_funcs();

local service_client = {};

local function get_api_idl_obj(module_name, class_name)
	local parts = (require "pl.stringx".split(module_name, '.'))
	local n = #parts;
	local idl_class_name = class_name .. "_interface";
	local idl_class_path;

	for i,v in ipairs(parts) do
		if (i==1) then
			idl_class_path = v;
		else
			idl_class_path = idl_class_path.."."..v;
		end
	end
	local app_base_path = properties_funcs.get_string_property("service_utils.REST.controller.appBasePath");
	if (app_base_path ~= nil) then
		idl_class_path = app_base_path"."..idl_class_path.. ".idl.".. idl_class_name
	else
		idl_class_path = idl_class_path.. ".idl.".. idl_class_name
	end
	return require(idl_class_path);
end

local function get_input_json(schema_def, obj)
	local msg_handler = schema_processor:get_message_handler(schema_def.name, schema_def.ns);
	assert(msg_handler ~= nil);
	local json, msg = msg_handler:to_json(obj);
	if (json == nil) then
		error(msg);
	end
	return json;
end

local function get_output_obj(schema_def, response)
	local msg_handler = schema_processor:get_message_handler(schema_def.name, schema_def.ns);
	assert(msg_handler ~= nil);
	local obj, msg = msg_handler:from_json(response);
	if (obj == nil) then
		error(msg);
	end
	return obj;
end

service_client.transceive = function(context, inp)
	assert(context ~= nil and type(context) == 'table');
	assert(inp ~= nil and type(inp) == 'table');
	assert(inp.service_name ~= nil and type(inp.service_name) == 'string');
	assert(inp.module_name ~= nil and type(inp.module_name) == 'string');
	assert(inp.class_name ~= nil and type(inp.class_name) == 'string');
	assert(inp.method_name ~= nil and type(inp.method_name) == 'string');
	assert(inp.query_params ~= nil and type(inp.query_params) == 'table');
	assert(inp.request_obj == nil or type(inp.request_obj) == 'table');

	local interface_class = get_api_idl_obj(inp.module_name, inp.class_name);
	assert(interface_class.methods ~= nil);

	local method_properties = interface_class.methods[inp.method_name];
	if (method_properties == nil) then
		error("Invalid methdod ["..inp.class_name.."] ".."["..inp.method_name.."]");
	end

	local request_json = '';
	if (method_properties.message.in_out[1] ~= nil) then
		assert(inp.request_obj ~= nil);
		request_json = get_input_json(method_properties.message.in_out[1], inp.request_obj);
	end

	local config_conn = context.db_connections['CONFIG'].conn;
	assert(config_conn ~= nil);
	local status, response, msg = config_conn:zrangebyscore(inp.service_name, '-inf', false, '+inf', false);
    if (not status) then
		local msg = messages:format('HOST_NOT_RESOLVED_FROM_CONFIG', inp.service_name);
		error(msg);
		return false, nil;
	end

	local host_confg_rec_handler = schema_processor:get_message_handler('host_config_rec',
															'http://evpoco.tekenlight.org/idl_spec');
	local host_config_element = host_confg_rec_handler:from_json(core_utils.str_base64_decode(response[1]));
	local client = rest_client_factory.new(host_config_element.host, tonumber(host_config_element.port));
	local headers = {};
	headers.method = method_properties.http_method;
    headers['X-Auth'] = context.access_token;
	local uri = "/"..string.gsub(inp.module_name, "%.", "/");
	local uri = uri.."/"..inp.class_name.."/"..inp.method_name;
	local i = 1;
	for  n,v in pairs(inp.query_params) do
		if (i == 1) then
			uri = uri..'?';
		else
			uri = uri..'&';
		end
		i = i + 1;
		uri = uri..n.."="..tostring(v); -- To check if tostring will work for query params
	end
    client:send_request(uri, headers, request_json);

	local status, response_json = client:recv_response();
    if (not status) then
		local obj, msg = json_parser.decode(response_json);
		if (obj == nil) then
			return false, response_json;
		end
        return false, obj;
    end

	if (method_properties.message.in_out[2] ~= nil) then
		assert(response_json ~= nil and type(response_json) == 'string');
		local obj = get_output_obj(method_properties.message.in_out[2], response_json);
		return status, obj;
	else
		return status, nil;
	end
end




return service_client;

