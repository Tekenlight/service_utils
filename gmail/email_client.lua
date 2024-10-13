local external_service_client = require('service_utils.REST.external_service_client');
local service_client = require('service_utils.REST.service_client');
local messages = require('service_common.literals');
local cjson = require("cjson.safe");
local json_parser = cjson.new();
local jwt = require("service_utils.jwt.luajwt");
local uri_util = require('uri._util');
local date = require('date');
local date_utils = require('lua_schema.date_utils');
local core_utils = require('lua_schema.core_utils');

--[[

The token returned by google authentication contains the following elements

access_token: The bearer token to be used in each API
expires_in: The time duration after which the token will expire
token_type: Type of token it is .


--]]

local email_client = {}

--[[
return connection, auth, http_status;
]]

email_client.make_connection = function (client_security_json, email_id)
    assert(type(client_security_json) == 'string');
    assert(type(email_id) == 'string');

    local stat, key_data, err = pcall(json_parser.decode, client_security_json);

    local private_key = key_data.private_key
    local client_email = key_data.client_email

    -- Create JWT token
    local jwt_claims = {
        iss = client_email,
        scope = "https://www.googleapis.com/auth/gmail.readonly https://www.googleapis.com/auth/gmail.send",
        aud = "https://oauth2.googleapis.com/token",
        exp = os.time() + 3600,
        iat = os.time(),
        sub = email_id  -- Email of the user you want to impersonate
    }

    local jwt_token = jwt.encode(jwt_claims, private_key, "RS256")

    local body = "grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=" .. jwt_token;

    local headers = {
        ["Content-Type"] = "application/x-www-form-urlencoded",
        ["Content-Length"] = #body,
        method = 'POST',
        Accept = "*/*"
    };

    local oauth_connection = external_service_client.make_connection({
        --url = "https://oauth2.googleapis.com/token",
        url = "oauth2.googleapis.com",
        port = 443,
        secure = true,
        peer_name = "oauth2.googleapis.com/token"
    });
    if (oauth_connection == nil) then
        return nil, nil, nil;
    end

    local status, response_str, http_status, hdrs = service_client.send_and_receive(oauth_connection, "/token", headers, body);
    if (not status or http_status > 300) then
        return nil, nil, http_status;
    end
    local stat, auth, err = pcall(json_parser.decode, response_str);
    assert(stat, auth);

    local connection = external_service_client.make_connection({
        --url = "https://oauth2.googleapis.com/token",
        url = "gmail.googleapis.com",
        port = 443,
        secure = true,
        peer_name = "gmail.googleapis.com"
    });
    if (connection == nil) then
        return false, nil, 500;
    end

    return connection, auth, http_status;
end

local tablecat = function(t2, t1)
    assert(type(t2) == 'table');
    assert(type(t1) == 'table');

    --[[
    for _,v in ipairs(t1) do
        table.inser(t2, v);
    end
    ]]

    table.move(t1, 1, #t1, #t2 + 1, t2);

    return t2;
end

--[[
return  list
]]
email_client.get_email_list = function(connection, email_id, token, crit)
    assert(type(connection) == 'table');
    assert(type(crit.after) == 'string')
    assert(type(token) == 'table');
    assert(type(crit) == 'table');

    local headers = {
        method = "GET",
        Authorization = "Bearer " .. token.access_token
    };

    local q = 'in:inbox label:INBOX';
    for n,v in pairs(crit) do
        q = q .. ' ' .. n..':'..v;
    end

    local uri_util = require('uri._util');
    local base_uri = '/gmail/v1/users/'..email_id..'/messages';
    local qp = {
        q = q,
    };
    local q_uri = service_client.complete_uri_with_qp(nil, qp, true);

    local uri = base_uri..q_uri;

    local status, response_str, http_status, hdrs = service_client.send_and_receive(connection, uri, headers, nil);
    assert(status, response_str);

    local messages = {};
    local stat, inc_list, err = pcall(json_parser.decode, response_str);
    assert(stat, inc_list);

    if (type(inc_list.messages) == 'table') then tablecat(messages, inc_list.messages); end

    while (inc_list.nextPageToken ~= nil and inc_list.nextPageToken ~= "") do

        uri = base_uri..q_uri..'&pageToken='..inc_list.nextPageToken;
        status, response_str, http_status, hdrs = service_client.send_and_receive(connection, uri, headers, nil);
        assert(status, response_str);

        inc_list = nil;
        stat, inc_list, err = pcall(json_parser.decode, response_str);
        assert(stat, inc_list);

        if (type(inc_list.messages) == 'table') then tablecat(messages, inc_list.messages); end
    end

    local list = { messages = messages };
    return list;
end

local not_in_inbox = function (arr)
    for i,v in ipairs(arr) do
        if (string.upper(v) == 'INBOX') then
            return false;
        end
    end
    return true;
end

local get_plain_text_mail_body = function(payload)
    return core_utils.str_url_base64_decode(payload.body.data);
end

local get_attachment = function(connection, email_id, token, id, payload)

    local uri = '/gmail/v1/users/'..email_id..'/messages/'..id..'/attachments/'.. payload.body.attachmentId;
    local uri = service_client.complete_uri_with_qp(uri, {});
    local headers = {
        method = "GET",
        Authorization = "Bearer " .. token.access_token
    };

    local status, response_str, http_status, hdrs = service_client.send_and_receive(connection, uri, headers, nil);
    assert(status, response_str);

    local stat, attachment, err = pcall(json_parser.decode, response_str);
    assert(stat, attachment);

    return attachment;
end

local get_email_message = function(connection, email_id, token, mail_item) 
    local payload = mail_item.payload
    local props = {
        id = mail_item.id,
        attachments = {},
    };

    for i,v in ipairs(payload.headers) do
        if (v.name == 'Date') then
            local tzo;
            local tz_part = v.value:match("[+-][0-9][0-9][0-9][0-9].*");
            if (tz_part ~= nil) then
                local sign = tz_part:sub(1, 1);
                if (sign == '-') then
                    sign = -1;
                else
                    sign = 1;
                end
                local hh = tonumber(tz_part:sub(2, 3));
                local mi = tonumber(tz_part:sub(4, 5));
                tzo = sign * hh*60 + mi;
            end
            props.date = date_utils.date_time_from_dto(date(v.value), tzo);
        elseif (v.name == 'From') then
            props.from = v.value;
        elseif (v.name == 'To') then
            props.to = v.value;
        elseif (v.name == 'Delivered-To') then
            props.delivered_to = v.value;
        elseif (v.name == 'Return-Path') then
            props.return_path = v.value;
        elseif (v.name == 'Subject') then
            props.subject = v.value;
        elseif (v.name == 'Content-Type') then
            props.content_type = v.value;
        elseif (v.name == 'Cc') then
            props.cc = v.value;
        end
    end
    props.mime_type = payload.mimeType;

    if (payload.mimeType == 'text/plain') then
        props.message_body = get_plain_text_mail_body(payload);
    elseif (payload.mimeType == 'text/html') then
        props.message_body = get_plain_text_mail_body(payload);
    elseif (string.sub(payload.mimeType, 1, 4) == 'text') then
        props.message_body = get_plain_text_mail_body(payload);
    elseif (payload.mimeType == 'multipart/alternative') then
        for i,v in ipairs(payload.parts) do
            if (v.mimeType == 'text/plain') then
                props.message_body = get_plain_text_mail_body(v);
            elseif (string.sub(v.mimeType, 1, 4) == 'text') then
                props.message_body = get_plain_text_mail_body(v);
            end
        end
    elseif (payload.mimeType == 'multipart/mixed') then
        for i,v in ipairs(payload.parts) do
            if (v.filename == "") then
                if (v.mimeType == 'text/plain') then
                    props.message_body = get_plain_text_mail_body(v);
                elseif (string.sub(v.mimeType, 1, 4) == 'text') then
                    props.message_body = get_plain_text_mail_body(v);
                end
            else
                local attachment = get_attachment(connection, email_id, token, mail_item.id, v);
                attachment.file_name = v.filename;
                attachment.mime_type = v.mimeType;
                attachment.size_as_in_mail = v.body.size;
                props.attachments[#(props.attachments)+1] = attachment;
            end
        end
    elseif (payload.mimeType == 'multipart/parallel') then
        for i,v in ipairs(payload.parts) do
            if (v.filename == "") then
                if (v.mimeType == 'text/plain') then
                    props.message_body = get_plain_text_mail_body(v);
                elseif (string.sub(v.mimeType, 1, 4) == 'text') then
                    props.message_body = get_plain_text_mail_body(v);
                end
            else
                local attachment = get_attachment(connection, email_id, mail_item.id, v);
                attachment.file_name = v.filename;
                attachment.mime_type = v.mimetype;
                attachment.size_as_in_mail = v.body.size;
                props.attachments[#(props.attachments)+1] = attachment;
            end
        end
    elseif (payload.mimeType == 'multipart/related') then
        for i,v in ipairs(payload.parts) do
            if (v.mimeType == 'text/plain') then
                props.message_body = get_plain_text_mail_body(v);
            elseif (string.sub(v.mimeType, 1, 4) == 'text') then
                props.message_body = get_plain_text_mail_body(v);
            end
        end
    else
        print(debug.getinfo(1).source, debug.getinfo(1).currentline);
        print(payload.mimeType);
        print(debug.getinfo(1).source, debug.getinfo(1).currentline);
        return nil;
    end

    return props;
end

--[[
gmail treats Inbox in a special way, mails that are having different labels and even not having
the label inbox can be considered as being part of inbox

This function goes throught the list and makes sure that only the ones that carry the inbox label will
be retrieved.

return email_messages;
]]
email_client.get_inbox_emails = function(connection, email_id, token, list)
    assert(type(connection) == 'table');
    assert(type(token) == 'table');
    assert(type(list) == 'table');

    local j = 0;
    local email_messages = {};
    local headers = {};
    for i,v in ipairs(list.messages) do
        local uri = service_client.complete_uri_with_qp('/gmail/v1/users/'..email_id..'/messages/'..list.messages[i].id,
            {}
        );

        headers = {
            method = "GET",
            Authorization = "Bearer " .. token.access_token
        };
            local status, response_str, http_status, hdrs = service_client.send_and_receive(connection, uri, headers, nil);
        local stat, mail_item, err = pcall(json_parser.decode, response_str);
        assert(stat, mail_item);

        if (not_in_inbox(mail_item.labelIds)) then
            goto continue ;
        end

        j = j + 1;
        local message = get_email_message(connection, email_id, token, mail_item);
        if (message ~= nil) then
            email_messages[j] = message;
        else
            error("Could not gather parts of message id "..mail_item.id);
        end

        ::continue::
    end

    return email_messages;
end




return email_client;
