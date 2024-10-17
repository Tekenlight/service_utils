local ffi = require('ffi');
local external_service_client = require('service_utils.REST.external_service_client');
local service_client = require('service_utils.REST.service_client');
local msf = require('common.msg_literal');
local cjson = require("cjson.safe");
local json_parser = cjson.new();
local jwt = require("service_utils.jwt.luajwt");
local uri_util = require('uri._util');
local date = require('date');
local error_handler = require('lua_schema.error_handler');
local date_utils = require('lua_schema.date_utils');
local core_utils = require('lua_schema.core_utils');
local schema_processor = require("schema_processor");
local stringx = require('pl.stringx');

local INCORRECT_MAIL_FORMAT_MSG = [[
Hello,

We are unable to process this message due to unexpected mime type of the message [%s]
Kindly send the mail in correct format

Regards,
]]

local email_client = {}

--[[
return connection, auth, http_status;

auth contains the following elements (they are self explanatory)

access_token,
expires_in,
ext_expires_in,
token_type

]]

email_client.make_connection = function (client_security_json, email_id)
    assert(type(client_security_json) == 'string');
    assert(type(email_id) == 'string');

    local stat, key_data, err = pcall(json_parser.decode, client_security_json);

    local client_id = key_data.client_id;
    local client_secret = key_data.client_secret;
    local tenant_id = key_data.tenant_id;

    local oauth_connection = external_service_client.make_connection({
        --url = "https://oauth2.googleapis.com/token",
        url = "login.microsoftonline.com",
        port = 443,
        secure = true,
        peer_name = "login.microsoftonline.com"
    });
    if (oauth_connection == nil) then
        return nil, nil, nil;
    end

    local claims = {
        grant_type = "client_credentials",
        client_id = client_id,
        client_secret = client_secret,
        scope = "https://graph.microsoft.com/.default"
    }

    local body = '';
    for n,v in pairs(claims) do
        if (body ~= '') then
            body = body..'&';
        end
        body = body .. n.. '=' .. uri_util.uri_encode(tostring(v));
    end

    local headers = {
        ["Content-Type"] = "application/x-www-form-urlencoded",
        ["Content-Length"] = #body,
        method = 'POST',
    };
    local uri = "/" .. tenant_id .. "/oauth2/v2.0/token"

    local status, response_str, http_status, hdrs = service_client.send_and_receive(oauth_connection, uri, headers, body);
    if (not status or http_status > 300) then
        return nil, nil, http_status;
    end
    local stat, auth, err = pcall(json_parser.decode, response_str);
    assert(stat, auth);
    assert(auth ~= nil, err);

    local connection = nil;

    return connection, auth, http_status;
end

return email_client;
