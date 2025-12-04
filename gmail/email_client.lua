local ffi = require('ffi');
local external_service_client = require('service_utils.REST.external_service_client');
local service_client = require('service_utils.REST.service_client');
local msf = require('service_utils.common.msg_literal');
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
local utils = require('service_utils.common.utils');

local INCORRECT_MAIL_FORMAT_MSG = [[
Hello,

We are unable to process this message due to unexpected mime type of the message [%s]
Kindly send the mail in correct format

Regards,
]]
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
    assert(stat, key_data);
    assert(key_data ~= nil, err);

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
    assert(auth ~= nil, err);

    local connection = external_service_client.make_connection({
        --url = "https://oauth2.googleapis.com/token",
        url = "gmail.googleapis.com",
        port = 443,
        secure = true,
        peer_name = "gmail.googleapis.com"
    });
    if (connection == nil) then
        return nil, nil, nil;
    end

    return connection, auth, http_status;
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

    local q = 'in:inbox label:INBOX -label:SENT';
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
    assert(inc_list ~= nil, err);

    if (type(inc_list.messages) == 'table') then utils.tablecat(messages, inc_list.messages); end

    while (inc_list.nextPageToken ~= nil and inc_list.nextPageToken ~= "") do

        uri = base_uri..q_uri..'&pageToken='..inc_list.nextPageToken;
        status, response_str, http_status, hdrs = service_client.send_and_receive(connection, uri, headers, nil);
        assert(status, response_str);

        inc_list = nil;
        stat, inc_list, err = pcall(json_parser.decode, response_str);
        assert(stat, inc_list);
        assert(inc_list ~= nil, err);

        if (type(inc_list.messages) == 'table') then utils.tablecat(messages, inc_list.messages); end
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
    if (payload.body.data == "") then
        return "";
    end
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
    assert(attachment ~= nil, err);

    return attachment;
end

local parse_return_path = function(rp)
    local email;
    local details = {};
    email = rp:match('^%s*<([^>]+)>%s*$')
    if email then
        return email;
    else
        -- Match just an email address without a name
        email = rp:match('^%s*([^%s]+@[^%s]+)%s*$')
        if email then
            return email;
        end
    end

    return nil;
end

local parse_to = function (to)
    local recipients = {}

    -- Iterate over each recipient, which might be separated by commas
    for recipient in to:gmatch('([^,]+)') do
        local name, email

        -- Match "Name" <email@example.com>
        name, email = recipient:match('^%s*"?([^"]+)"?%s*<([^>]+)>%s*$')
        if name and email then
            table.insert(recipients, {real_name = name, address = email})
        else
            -- Match Name <email@example.com>
            name, email = recipient:match('^%s*([^<]+)%s*<([^>]+)>%s*$')
            if name and email then
                table.insert(recipients, {real_name = name:match("^%s*(.-)%s*$"), address = email})
            else
                -- Match <email@example.com>
                email = recipient:match('^%s*<([^>]+)>%s*$')
                if email then
                    table.insert(recipients, {real_name = nil, address = email})
                else
                    -- Match just an email address without a name
                    email = recipient:match('^%s*([^%s]+@[^%s]+)%s*$')
                    if email then
                        table.insert(recipients, {real_name = nil, address = email})
                    end
                end
            end
        end
    end

    return recipients
end

local parse_from = function(from)
    local name, email

    -- Try to match "Name" <email@example.com>
    name, email = from:match('^%s*"?([^"]+)"?%s*<([^>]+)>%s*$')
    if name and email then
        return name, email
    end

    -- Try to match Name <email@example.com>
    name, email = from:match('^%s*([^<]+)%s*<([^>]+)>%s*$')
    if name and email then
        return name:match("^%s*(.-)%s*$"), email
    end

    -- Try to match <email@example.com>
    email = from:match('^%s*<([^>]+)>%s*$')
    if email then
        return nil, email
    end

    -- Try to match just an email address without name
    email = from:match('^%s*([^%s]+@[^%s]+)%s*$')
    if email then
        return nil, email
    end

    return nil, nil  -- If it doesn't match any pattern
end

local send_error_response = function(connection, email_id, token, message_id, message_to_send, orig_message)
    assert(type(connection) == 'table');
    assert(type(email_id) == 'string');
    assert(type(token) == 'table');
    assert(type(message_id) == 'string');
    assert(type(message_to_send) == 'string');
    assert(type(orig_message) == 'table');


    local body = "From: "..email_id.."\r\n"..
        "To: "..orig_message.return_path.."\r\n"..
        "Subject: Re: "..orig_message.subject.."\r\n"..
        "\r\n"..
        message_to_send.."\r\n\r\n"
        ;

    local b64_body = core_utils.url_base64_encode(body);
    local stat, rfc_message, err = pcall(json_parser.encode, {
        raw = b64_body,
        threadId = message_id
    });

    local uri = service_client.complete_uri_with_qp('/gmail/v1/users/'..email_id..'/messages/send',
        {}
    );

    local headers = {
        method = "POST",
        Authorization = "Bearer " .. token.access_token,
        ["Content-Type"] = "application/json",
        ["Content-Length"] = #rfc_message
    };

    local status, response_str, http_status, hdrs = service_client.send_and_receive(connection, uri, headers, rfc_message);
    assert(status, response_str);

    return;

end

local function find_body_text(parts)
    local plain_text = nil;
    local html_text = nil;
    for i,v in ipairs(parts) do
        if (v.filename == "") then
            if (v.parts ~= nil) then
                return find_body_text(v.parts);
            else
                if (v.mimeType == 'text/plain') then
                    plain_text = get_plain_text_mail_body(v);
                elseif (plain_text == nil and string.sub(v.mimeType, 1, 4) == 'text') then
                    plain_text = get_plain_text_mail_body(v);
                end
                if (v.mimeType == 'text/html') then
                    html_text = get_plain_text_mail_body(v);
                end
            end
        end
    end

    return plain_text, html_text;
end

local get_email_message = function(connection, email_id, token, mail_item, including_attachments) 
    local payload = mail_item.payload
    local props = {
        id = mail_item.id,
        thread_id = mail_item.threadId,
        attachments = {},
        parts = {};
        fetch_complete = true;
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
            props.from = stringx.strip(v.value);
            local n,e = parse_from(props.from);
            props.from_s = {
                real_name = n,
                address = e
            };
        elseif (v.name == 'To') then
            props.to = v.value;
            props.to_s = parse_to(props.to);
        elseif (v.name == 'Delivered-To') then
            props.delivered_to = v.value;
        elseif (v.name == 'Return-Path') then
            props.return_path = v.value;
            props.return_path_address = parse_return_path(v.value);
        elseif (v.name == 'Subject') then
            props.subject = v.value;
        elseif (v.name == 'Content-Type') then
            props.content_type = v.value;
        elseif (v.name == 'Cc') then
            props.cc = v.value;
            props.cc_recipients = parse_to(props.cc);
        elseif (v.name == 'Message-ID') then
            props.header_message_id = v.value;
        end
    end
    props.mime_type = payload.mimeType;

    if (payload.mimeType == 'text/plain') then
        props.message_body = get_plain_text_mail_body(payload);
    elseif (payload.mimeType == 'text/html') then
        props.message_body = get_plain_text_mail_body(payload);
        props.html_body = get_plain_text_mail_body(payload);
    elseif (string.sub(payload.mimeType, 1, 4) == 'text') then
        props.message_body = get_plain_text_mail_body(payload);
        props[string.sub(v.mimeType, 5).."_body"] = get_plain_text_mail_body(v);
    elseif (payload.mimeType == 'multipart/alternative') then
        for i,v in ipairs(payload.parts) do
            if (v.filename == "") then
                if (string.sub(v.mimeType, 1, 9) == 'multipart') then
                    props.message_body, props.html_body = find_body_text(v.parts);
                else
                    props.parts[#(props.parts)+1] = v;
                    if (v.mimeType == 'text/plain') then
                        props.message_body = get_plain_text_mail_body(v);
                    elseif (props.message_body == nil and string.sub(v.mimeType, 1, 4) == 'text') then
                        props.message_body = get_plain_text_mail_body(v);
                    end
                    if (string.sub(v.mimeType, 1, 4) == 'text') then
                        props[string.sub(v.mimeType, 5).."_body"] = get_plain_text_mail_body(v);
                    end
                end
            end
        end
        if (props.message_body == nil) then
            print("=====================");
            print("Could not locate message body for this email");
            print("=====================");
            props.message_body = "Could not locate message body for this email";
        end
    elseif (payload.mimeType == 'multipart/mixed') then
        for i,v in ipairs(payload.parts) do
            if (v.filename == "") then
                if (string.sub(v.mimeType, 1, 9) == 'multipart') then
                    props.message_body, props.html_body = find_body_text(v.parts);
                else
                    if (v.mimeType == 'text/plain') then
                        props.message_body = get_plain_text_mail_body(v);
                    elseif (props.message_body == nil and string.sub(v.mimeType, 1, 4) == 'text') then
                        props.message_body = get_plain_text_mail_body(v);
                    end
                    if (string.sub(v.mimeType, 1, 4) == 'text') then
                        props[string.sub(v.mimeType, 5).."_body"] = get_plain_text_mail_body(v);
                    end
                end
            else
                local attachment = {}
                if (including_attachments) then
                    attachment = get_attachment(connection, email_id, token, mail_item.id, v, including_attachments);
                end
                attachment.attachment_id = v.body.attachmentId;
                attachment.file_name = v.filename;
                attachment.mime_type = v.mimeType;
                if (attachment.size == nil) then
                    attachment.size = v.body.size;
                end
                props.attachments[#(props.attachments)+1] = attachment;
            end
        end
    elseif (payload.mimeType == 'multipart/parallel') then
        for i,v in ipairs(payload.parts) do
            if (v.filename == "") then
                if (string.sub(v.mimeType, 1, 9) == 'multipart') then
                    props.message_body, props.html_body = find_body_text(v.parts);
                else
                    if (v.mimeType == 'text/plain') then
                        props.message_body = get_plain_text_mail_body(v);
                    elseif (props.message_body == nil and string.sub(v.mimeType, 1, 4) == 'text') then
                        props.message_body = get_plain_text_mail_body(v);
                    end
                    if (string.sub(v.mimeType, 1, 4) == 'text') then
                        props[string.sub(v.mimeType, 5).."_body"] = get_plain_text_mail_body(v);
                    end
                end
            else
                local attachment = get_attachment(connection, email_id, mail_item.id, v);
                attachment.file_name = v.filename;
                attachment.mime_type = v.mimetype;
                if (attachment.size == nil) then
                    attachment.size = v.body.size;
                end
                props.attachments[#(props.attachments)+1] = attachment;
            end
        end
    elseif (payload.mimeType == 'multipart/related') then
        for i,v in ipairs(payload.parts) do
            if (v.filename == "") then
                if (string.sub(v.mimeType, 1, 9) == 'multipart') then
                    props.message_body = find_body_text(v.parts);
                else
                    if (v.mimeType == 'text/plain') then
                        props.message_body, props.html_body = get_plain_text_mail_body(v);
                    elseif (props.message_body == nil and string.sub(v.mimeType, 1, 4) == 'text') then
                        props.message_body = get_plain_text_mail_body(v);
                    end
                    if (string.sub(v.mimeType, 1, 4) == 'text') then
                        props[string.sub(v.mimeType, 5).."_body"] = get_plain_text_mail_body(v);
                    end
                end
            else
                --[[Attachments here are not interesting ]]
            end
        end
    elseif (payload.mimeType == 'multipart/report') then
        for i,v in ipairs(payload.parts) do
            if (v.filename == "") then
                if (string.sub(v.mimeType, 1, 9) == 'multipart') then
                    props.message_body, props.html_body = find_body_text(v.parts);
                else
                    if (v.mimeType == 'text/plain') then
                        props.message_body = get_plain_text_mail_body(v);
                    elseif (props.message_body == nil and string.sub(v.mimeType, 1, 4) == 'text') then
                        props.message_body = get_plain_text_mail_body(v);
                    end
                    if (string.sub(v.mimeType, 1, 4) == 'text') then
                        props[string.sub(v.mimeType, 5).."_body"] = get_plain_text_mail_body(v);
                    end
                end
            else
                local attachment = get_attachment(connection, email_id, mail_item.id, v);
                attachment.file_name = v.filename;
                attachment.mime_type = v.mimetype;
                if (attachment.size == nil) then
                    attachment.size = v.body.size;
                end
                props.attachments[#(props.attachments)+1] = attachment;
            end
        end
    else
        print(debug.getinfo(1).source, debug.getinfo(1).currentline);
        print("Fetching of mail did not complete, encountered payload.mimeType: "..payload.mimeType);
        print(debug.getinfo(1).source, debug.getinfo(1).currentline);
        --local msg = msf:format_with_string(INCORRECT_MAIL_FORMAT_MSG, payload.mimeType);
        --send_error_response(connection, email_id, token, mail_item.id, msg, props)
        props.message_body = "";
        props.fetch_complete = false;
    end

    return props;
end

email_client.get_message = function(connection, email_id, token, message_id, including_attachments)
    assert(type(connection) == 'table');
    assert(type(email_id) == 'string');
    assert(type(token) == 'table');
    assert(type(message_id) == 'string');
    assert(including_attachments == nil or type(including_attachments) == 'boolean')
    if (including_attachments == nil) then
        including_attachments = true;
    end

    local uri = service_client.complete_uri_with_qp('/gmail/v1/users/'..email_id..'/messages/'..message_id,
        {}
    );

    local headers = {
        method = "GET",
        Authorization = "Bearer " .. token.access_token
    };
    local status, response_str, http_status, hdrs = service_client.send_and_receive(connection, uri, headers, nil);
    assert(status, response_str);

    local stat, mail_item, err = pcall(json_parser.decode, response_str);
    assert(stat, mail_item);
    assert(mail_item ~= nil, err);

    local message = get_email_message(connection, email_id, token, mail_item, including_attachments);
    if (message == nil) then
        --error("Could not gather parts of message id "..mail_item.id);
    end

    return message;
end

--[[
gmail treats Inbox in a special way, mails that are having different labels and even not having
the label inbox can be considered as being part of inbox

This function goes throught the list and makes sure that only the ones that carry the inbox label will
be retrieved.

return email_messages;
]]
email_client.get_inbox_emails = function(connection, email_id, token, list, including_attachments)
    assert(type(connection) == 'table');
    assert(type(email_id) == 'string');
    assert(type(token) == 'table');
    assert(type(list) == 'table');
    assert(including_attachments == nil or type(including_attachments) == 'boolean')
    if (including_attachments == nil) then
        including_attachments = true;
    end

    local j = 0;
    local email_messages = {};
    local headers = {};
    for i,v in ipairs(list.messages) do
        email_messages[i] = email_client.get_message (connection, email_id, token, list.messages[i].id, including_attachments);
    end

    return email_messages;
end

--[[
Sends a plain text reply (without attachments) to a message that has
been received.

connection: established secure TCP connection to google service
email_id: email address on behalf of whom the reply is being sent.
message_id: id of the message
messafe: The message object (table) compliant with 

]]
email_client.plain_text_reply = function(connection, email_id, token, message_id, message_to_send)
    assert(type(connection) == 'table');
    assert(type(email_id) == 'string');
    assert(type(token) == 'table');
    assert(type(message_id) == 'string');
    assert(type(message_to_send) == 'string');


    local message = email_client.get_message(connection, email_id, token, message_id, false);

    local body = "From: "..email_id.."\r\n"..
        "To: "..message.return_path.."\r\n"..
        "Subject: Re: "..message.subject.."\r\n"..
        "\r\n"..
        message_to_send.."\r\n\r\n"..
        "--\r\n"..
        "Original message: \r\n"..
        message.message_body.."\r\n"
        ;

    local b64_body = core_utils.url_base64_encode(body);
    local stat, rfc_message, err = pcall(json_parser.encode, {
        raw = b64_body,
        threadId = message.thread_id
    });

    local uri = service_client.complete_uri_with_qp('/gmail/v1/users/'..email_id..'/messages/send',
        {}
    );

    local headers = {
        method = "POST",
        Authorization = "Bearer " .. token.access_token,
        ["Content-Type"] = "application/json",
        ["Content-Length"] = #rfc_message
    };

    local status, response_str, http_status, hdrs = service_client.send_and_receive(connection, uri, headers, rfc_message);
    assert(status, response_str);

    return;

end

--[[
Send an email to a specified address
connection: Pre established connection to google service
email_id: Google email_account
token: Access token received from auth
email_message: Message compliant with { ns="http://evpoco.tekenlight.org", name="email_message"}

]]
email_client.send_mail = function(connection, email_id, token, email_message)
    assert(type(connection) == 'table');
    assert(type(email_id) == 'string');
    assert(type(token) == 'table');
    assert(type(email_message) == 'table');

    local msg_handler = schema_processor:get_message_handler('email_message', 'http://evpoco.tekenlight.org');
    assert(msg_handler ~= nil, "Could not find schema element eail_message");
    local stat, status = pcall(msg_handler.is_valid, msg_handler, email_message);
    assert(stat, status);
    assert(status, error_handler.get_error_message());

    local mmf = platform.mail_message_funcs();
    local mm = mmf.new();
    local sender = nil;
    if (email_message.sender_name ~= nil) then
        sender = email_message.sender_name .. ' <'.. email_message.from .. '>';
    else
        sender = email_message.from;
    end
    mmf.set_sender(mm, sender);
    for i,v in ipairs(email_message.recipients) do
        if (v.real_name == nil) then
            mmf.add_recipient(mm, v.address, v.recipient_type);
        else
            mmf.add_recipient(mm, v.address, v.recipient_type, v.real_name);
        end
    end
    mmf.set_subject(mm, email_message.subject);
    mmf.add_content(mm, email_message.message_body);
    if (email_message.content_type ~= nil) then
        mmf.set_content_type(mm, email_message.content_type);
    end

    if (email_message.attachments ~= nil) then
        mmf.set_content_type(mm, "multipart/mixed");
        for i,v in ipairs(email_message.attachments) do
            mmf.add_attachment(mm, ffi.getptr(v.data.value), tonumber(v.data.size), v.file_name, v.mime_type);
        end
    end

    local mail_message = mmf.write_to_text(mm);

    local uri;
    local headers;
    --[[
    So far it has not become possible to establish which endpoint is suited for which situation.
    ]]
    if (false and email_message.attachments ~= nil and #(email_message.attachments) > 0) then
        uri = '/upload/gmail/v1/users/'..email_id..'/messages/send';
        headers = {
            method = "POST",
            Authorization = "Bearer " .. token.access_token,
            ["Content-Type"] = "message/rfc2822",
            ["Content-Length"] = #mail_message
        };
        local status, response_str, http_status, hdrs = service_client.send_and_receive(connection, uri, headers, mail_message);
        assert(status, response_str);
    else
        local b64_message = core_utils.url_base64_encode(mail_message);
        local stat, rfc_message, err = pcall(json_parser.encode, {
            raw = b64_message
        });

        uri = '/gmail/v1/users/'..email_id..'/messages/send';
        headers = {
            method = "POST",
            Authorization = "Bearer " .. token.access_token,
            ["Content-Type"] = "application/json",
            ["Content-Length"] = #rfc_message
        };
        local status, response_str, http_status, hdrs = service_client.send_and_receive(connection, uri, headers, rfc_message);
        assert(status, response_str);
    end

    return;
end


return email_client;
