local service_client = require('service_utils.REST.service_client');
local cjson = require("cjson.safe");
local json_parser = cjson.new();
local date = require('date');
local date_utils = require('lua_schema.date_utils');
local core_utils = require('lua_schema.core_utils');
local stringx = require('pl.stringx');
local gmime = require("service_utils.gmimejson");

local parser = {}

local get_plain_text_mail_body = function(payload)
    if (payload.body.data == nil) then
        return "";
    end
    return core_utils.str_url_base64_decode(payload.body.data);
end

local get_attachment = function(payload)

    return payload.body;
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

local function find_body_text(parts)
    local plain_text = nil;
    local html_text = nil;
    for i,v in ipairs(parts) do
        if (v.filename == nil) then
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

--[[

These MIME types define how multiple parts within a single message relate to each other and should be interpreted by the receiving application.

1.  multipart/alternative: The parts are alternative versions of the same content
    (e.g., a plain text and an HTML version of an email); the recipient displays the "best" format it supports.
2.  multipart/mixed: The parts are independent content bundled together
    (e.g., a message body and separate file attachments) and are generally displayed sequentially.
3.  multipart/parallel: The parts should be displayed simultaneously
    (e.g., an image displayed while an audio file plays), though this is less common in modern usage.
4.  multipart/related: The parts are components of an aggregate whole
    (e.g., an HTML document and its embedded images referenced by Content-IDs) and are not meant to be displayed individually.
5.  multipart/report: Defined for returning machine-readable delivery status or message disposition notifications,
    often with a human-readable text part and a machine-readable status part.


We have not implemented support for the following types

1.  multipart/signed: Used for email security (S/MIME and OpenPGP), this type ensures message integrity and
    authenticity through digital signatures. It has exactly two parts: the first contains the actual message
    content (which can be nested MIME types), and the second contains the digital signature data.
2.  multipart/encrypted: Also used for email security, this subtype provides confidentiality (privacy) by
    encrypting the message body. It has two parts: the first contains control information needed for decryption
    (like the protocol used), and the second is the encrypted data, typically with a Content-Type of application/octet-stream.
3.  multipart/digest: This is essentially a list of messages, where the default Content-Type for each part is
    message/rfc822 (a full email message). It's typically used by mailing list software to send a compilation
    of several messages in one digest email.
4.  multipart/form-data: While technically not part of standard email display, this MIME type is crucial for
    web applications. It is used when data, especially files, is submitted via an HTML form using the POST method
    over HTTP, bundling the form fields and file contents into separate parts.

]]

local get_email_message = function(mail_item) --{
    local payload = mail_item;
    local props = {
        --id = mail_item.id,
        --thread_id = mail_item.threadId,
        attachments = {},
        parts = {};
        fetch_complete = true;
    };

    for i,v in ipairs(payload.headers) do --{
        if (v.name == 'Date') then --{
            local tzo;
            local tz_part = v.value:match("[+-][0-9][0-9][0-9][0-9].*");
            if (tz_part ~= nil) then --{
                local sign = tz_part:sub(1, 1);
                if (sign == '-') then --{
                    sign = -1;
                else --} {
                    sign = 1;
                end --}
                local hh = tonumber(tz_part:sub(2, 3));
                local mi = tonumber(tz_part:sub(4, 5));
                tzo = sign * hh*60 + mi;
            end --}
            props.date = date_utils.date_time_from_dto(date(v.value), tzo);
        elseif (v.name == 'From') then --} {
            props.from = stringx.strip(v.value);
            local n,e = parse_from(props.from);
            props.from_s = {
                real_name = n,
                address = e
            };
        elseif (v.name == 'To') then --} {
            props.to = v.value;
            props.to_s = parse_to(props.to);
        elseif (v.name == 'Delivered-To') then --} {
            props.delivered_to = v.value;
        elseif (v.name == 'Return-Path') then --} {
            props.return_path = v.value;
            props.return_path_address = parse_return_path(v.value);
        elseif (v.name == 'Subject') then --} {
            props.subject = v.value;
        elseif (v.name == 'Content-Type') then --} {
            props.content_type = v.value;
        elseif (v.name == 'Cc') then --} {
            props.cc = v.value;
            props.cc_recipients = parse_to(props.cc);
        elseif (v.name == 'Message-ID') then --} {
            props.header_message_id = v.value;
        end --}
    end --}
    props.mime_type = payload.mimeType;

    if (payload.mimeType == 'text/plain') then --{
        props.message_body = get_plain_text_mail_body(payload);
    elseif (payload.mimeType == 'text/html') then --} {
        props.message_body = get_plain_text_mail_body(payload);
        props.html_body = get_plain_text_mail_body(payload);
    elseif (string.sub(payload.mimeType, 1, 4) == 'text') then --} {
        props.message_body = get_plain_text_mail_body(payload);
        props[string.sub(v.mimeType, 6).."_body"] = get_plain_text_mail_body(v);
    elseif (payload.mimeType == 'multipart/alternative') then --} {
        for i,v in ipairs(payload.parts) do --{
            if (v.filename == nil) then --{
                if (string.sub(v.mimeType, 1, 9) == 'multipart') then --{
                    props.message_body, props.html_body = find_body_text(v.parts);
                else --} {
                    props.parts[#(props.parts)+1] = v;
                    if (v.mimeType == 'text/plain') then --{
                        props.message_body = get_plain_text_mail_body(v);
                    elseif (props.message_body == nil and string.sub(v.mimeType, 1, 4) == 'text') then --} {
                        props.message_body = get_plain_text_mail_body(v);
                    end --}
                    if (string.sub(v.mimeType, 1, 4) == 'text') then --{
                        props[string.sub(v.mimeType, 6).."_body"] = get_plain_text_mail_body(v);
                    end --}
                end --}
            end --}
        end --}
        if (props.message_body == nil) then --{
            print("=====================");
            print("Could not locate message body for this email");
            print("=====================");
            props.message_body = "Could not locate message body for this email";
        end --}
    elseif (payload.mimeType == 'multipart/mixed') then --} {
        for i,v in ipairs(payload.parts) do --{
            if (v.filename == nil) then --{
                if (string.sub(v.mimeType, 1, 9) == 'multipart') then --{
                    props.message_body, props.html_body = find_body_text(v.parts);
                else --} {
                    if (v.mimeType == 'text/plain') then --{
                        props.message_body = get_plain_text_mail_body(v);
                    elseif (props.message_body == nil and string.sub(v.mimeType, 1, 4) == 'text') then --} {
                        props.message_body = get_plain_text_mail_body(v);
                    end --}
                    if (string.sub(v.mimeType, 1, 4) == 'text') then --{
                        props[string.sub(v.mimeType, 6).."_body"] = get_plain_text_mail_body(v);
                    end --}
                end --}
            else --} {
                local attachment = {}
                attachment = get_attachment(v);
                attachment.attachment_id = v.body.attachmentId;
                attachment.file_name = v.filename;
                attachment.mime_type = v.mimeType;
                if (attachment.size == nil) then --{
                    attachment.size = v.body.size;
                end --}
                props.attachments[#(props.attachments)+1] = attachment;
            end --}
        end --}
    elseif (payload.mimeType == 'multipart/parallel') then --} {
        for i,v in ipairs(payload.parts) do --{
            if (v.filename == nil) then --{
                if (string.sub(v.mimeType, 1, 9) == 'multipart') then --{
                    props.message_body, props.html_body = find_body_text(v.parts);
                else --} {
                    if (v.mimeType == 'text/plain') then --{
                        props.message_body = get_plain_text_mail_body(v);
                    elseif (props.message_body == nil and string.sub(v.mimeType, 1, 4) == 'text') then --} {
                        props.message_body = get_plain_text_mail_body(v);
                    end --}
                    if (string.sub(v.mimeType, 1, 4) == 'text') then --{
                        props[string.sub(v.mimeType, 6).."_body"] = get_plain_text_mail_body(v);
                    end --}
                end --}
            else --} {
                local attachment = get_attachment(v);
                attachment.file_name = v.filename;
                attachment.mime_type = v.mimetype;
                if (attachment.size == nil) then --{
                    attachment.size = v.body.size;
                end --}
                props.attachments[#(props.attachments)+1] = attachment;
            end --}
        end --}
    elseif (payload.mimeType == 'multipart/related') then --} {
        for i,v in ipairs(payload.parts) do --{
            if (v.filename == nil) then --{
                if (string.sub(v.mimeType, 1, 9) == 'multipart') then --{
                    props.message_body = find_body_text(v.parts);
                else --} {
                    if (v.mimeType == 'text/plain') then --{
                        props.message_body, props.html_body = get_plain_text_mail_body(v);
                    elseif (props.message_body == nil and string.sub(v.mimeType, 1, 4) == 'text') then --} {
                        props.message_body = get_plain_text_mail_body(v);
                    end --}
                    if (string.sub(v.mimeType, 1, 4) == 'text') then --{
                        props[string.sub(v.mimeType, 6).."_body"] = get_plain_text_mail_body(v);
                    end --}
                end --}
            else --} {
                --[[Attachments here are not interesting ]]
            end --}
        end --}
    elseif (payload.mimeType == 'multipart/report') then --} {
        for i,v in ipairs(payload.parts) do --{
            if (v.filename == nil) then --{
                if (string.sub(v.mimeType, 1, 9) == 'multipart') then --{
                    props.message_body, props.html_body = find_body_text(v.parts);
                else --} {
                    if (v.mimeType == 'text/plain') then --{
                        props.message_body = get_plain_text_mail_body(v);
                    elseif (props.message_body == nil and string.sub(v.mimeType, 1, 4) == 'text') then --} {
                        props.message_body = get_plain_text_mail_body(v);
                    end --}
                    if (string.sub(v.mimeType, 1, 4) == 'text') then --{
                        props[string.sub(v.mimeType, 6).."_body"] = get_plain_text_mail_body(v);
                    end --}
                end --}
            else --} {
                local attachment = get_attachment(v);
                attachment.file_name = v.filename;
                attachment.mime_type = v.mimetype;
                if (attachment.size == nil) then --{
                    attachment.size = v.body.size;
                end --}
                props.attachments[#(props.attachments)+1] = attachment;
            end --}
        end --}
    else --} {
        print(debug.getinfo(1).source, debug.getinfo(1).currentline);
        print("Fetching of mail did not complete, encountered payload.mimeType: "..payload.mimeType);
        print(debug.getinfo(1).source, debug.getinfo(1).currentline);
        props.message_body = "";
        props.fetch_complete = false;
    end --}

    return props;
end --}

parser.process = function(raw)

    local json_email = gmime.parse(raw);
    local stat, mail_item, err = pcall(json_parser.decode, json_email);
    assert(stat, mail_item);
    assert(mail_item ~= nil, err);

    local message = get_email_message(mail_item);
    if (message == nil) then
        --error("Could not gather parts of message id "..mail_item.id);
    end

    return message;
end


return parser;
