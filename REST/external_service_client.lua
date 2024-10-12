local schema_processor = require("schema_processor");
local rest_client_factory = require('service_utils.REST.client');
local cjson = require('cjson.safe');
local json_parser = cjson.new();
local core_utils = require("lua_schema.core_utils");
local properties_funcs = platform.properties_funcs();
local service_client = require('service_utils.REST.service_client');
local constatns = require('service_utils.common.constants');

local external_service_client = {};

external_service_client.make_connection = function(inp)
    assert(type(inp) == 'table');
    assert(type(inp.url) == 'string');
    assert(inp.port == nil or math.type(inp.port) == 'integer');
    assert(inp.secure == nil or type(inp.secure) == 'boolean');
    if (inp.secure == nil) then
        inp.secure = false;
    end
    assert(inp.peer_name == nil or type(inp.peer_name) == 'string', "Invalid peer_name");

    local client = rest_client_factory.new(inp.url, tonumber(inp.port), inp.secure,
                                    true, constants.RECV_TIMEOUT_EXTERNAL_SOCKETS, inp.peer_name);
    if (client ~= nil) then
        client._recv_timeout = constants.RECV_TIMEOUT_EXTERNAL_SOCKETS;
        client._send_timeout = constants.SEND_TIMEOUT_EXTERNAL_SOCKETS;
    end

    return client;
end

external_service_client.generic_transceive = function(client, headers, inp, uri)
    assert(type(client) == 'table', "Invalid input client");
    assert(type(headers) == 'table', "Invalid input <headers>");
    assert(type(inp) == 'table', "Invalid input <inp>");
    assert(type(uri) == 'string', "Invalid input <uri>");

    local request_json = json_parser.encode(inp.request_obj);

    local status, response, http_status, hdrs, client = service_client.core_transcieve({}, client, uri, headers, request_json);
    if (not status) then
        return status, response, http_status, hdrs, client;
    end

    local response_json = response;

    local obj = json_parser.decode(response_json);

    return status, obj, http_status, hdrs, client;
end

external_service_client.transceive = function(client, inp_headers, inp)
    assert(type(client) == 'table', "Invalid input client");
    assert(type(inp_headers) == 'table', "Invalid input <inp_headers>");
    assert(type(inp) == 'table', "Invalid input <inp>");

    local method_properties, interface_class = service_client.get_interface_method_properties({}, inp);

    local uri = service_client.prepare_uri({}, inp);
    local request_json = service_client.prepare_request_json({}, method_properties, inp);

    local headers = service_client.prepare_headers({}, inp, method_properties)
    assert(headers.method == inp_headers.method);
    local status, response, http_status, hdrs, client = service_client.core_transcieve({}, client, uri, headers, request_json);
    if (not status) then
        return status, response, http_status, hdrs, client;
    end

    local response_json = response;
    local status, obj = service_client.prepare_response_obj({}, method_properties, response_json);

    return status, obj, http_status, hdrs, client;
end


external_service_client.transceive_using_client = function(context, inp, client)
    return service_client.transceive_using_client(context, inp, client);
end

return external_service_client;

