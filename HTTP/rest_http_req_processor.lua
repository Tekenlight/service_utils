URI = require("uri");

local function isempty(s)
	return s == nil or s == '';
end

function map_request_to_handler(request)
	local uri = request:get_uri();
	local url_parts = {};
	local i = 0;
	local j = 0;
	local first_url_char = uri:sub(1,1);

	local url_parts1 = URI:new(uri);
	for i,v in ipairs((require "pl.stringx".split(url_parts1:path(), '/'))) do
		if (i ~= 1) then
			url_parts[i-1] = v;
		end
	end
	if (isempty(url_parts[1])) then url_parts[1] = 'default_handler'; end
	if (isempty(url_parts[2])) then url_parts[2] = 'handle_request'; end

	return url_parts[1], url_parts[2];
end


local platform = require("platform");
local request = platform.get_http_request();
local response = platform.get_http_response();

--local req_handler_name, func = map_request_to_handler(request);
local req_handler_name, func = 'service_utils.REST.controller', 'handle_request';
local req_handler = require(req_handler_name);
return pcall(req_handler[func], request, response); 

