local ffi = require('ffi');
local error_handler = require("lua_schema.error_handler");

local host_utils = require("service_utils.REST.host_utils");
local service_client = require('service_utils.REST.external_service_client');

local batch_init = {};
local client;

--local url = "biop.tekenlight.com"
--local url = "tekenlight.com"
local url = "google.com"

local function establish_connection(inp)
	print(debug.getinfo(1).source, debug.getinfo(1).currentline);
	client = service_client.make_connection(inp);
	print(debug.getinfo(1).source, debug.getinfo(1).currentline);
end


local inp = {};
inp.url = url;
inp.secure = true;
inp.port = 443;
inp.peer_name = url;

establish_connection(inp);

print(debug.getinfo(1).source, debug.getinfo(1).currentline);
require 'pl.pretty'.dump(client);
print(debug.getinfo(1).source, debug.getinfo(1).currentline);




client:send_request("/", { ["method"] = "GET", ["Host"] = "google.com", ["User-Agent"] = "curl/7.81.0", ["Accept"] = "*/*"}, nil);


print(debug.getinfo(1).source, debug.getinfo(1).currentline);
local status, response_json, http_status, hdrs = client:recv_response();
print(debug.getinfo(1).source, debug.getinfo(1).currentline);

print(status);
print(response_json);
require 'pl.pretty'.dump(hdrs);
