local service_client = require('service_utils.REST.service_client');
local cjson = require("cjson.safe");
local json_parser = cjson.new();
local date = require('date');
local date_utils = require('lua_schema.date_utils');
local core_utils = require('lua_schema.core_utils');
local stringx = require('pl.stringx');
local gmime = require("service_utils.gmimejson");

local email_client = {}

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

local get_email_message = function(connection, email_id, token, mail_item, including_attachments) --{
    local payload = mail_item.payload
    local props = {
        id = mail_item.id,
        thread_id = mail_item.threadId,
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
        props[string.sub(v.mimeType, 5).."_body"] = get_plain_text_mail_body(v);
    elseif (payload.mimeType == 'multipart/alternative') then --} {
        for i,v in ipairs(payload.parts) do --{
            if (v.filename == "") then --{
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
                        props[string.sub(v.mimeType, 5).."_body"] = get_plain_text_mail_body(v);
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
            if (v.filename == "") then --{
                if (string.sub(v.mimeType, 1, 9) == 'multipart') then --{
                    props.message_body, props.html_body = find_body_text(v.parts);
                else --} {
                    if (v.mimeType == 'text/plain') then --{
                        props.message_body = get_plain_text_mail_body(v);
                    elseif (props.message_body == nil and string.sub(v.mimeType, 1, 4) == 'text') then --} {
                        props.message_body = get_plain_text_mail_body(v);
                    end --}
                    if (string.sub(v.mimeType, 1, 4) == 'text') then --{
                        props[string.sub(v.mimeType, 5).."_body"] = get_plain_text_mail_body(v);
                    end --}
                end --}
            else --} {
                local attachment = {}
                if (including_attachments) then --{
                    attachment = get_attachment(connection, email_id, token, mail_item.id, v, including_attachments);
                end --}
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
            if (v.filename == "") then --{
                if (string.sub(v.mimeType, 1, 9) == 'multipart') then --{
                    props.message_body, props.html_body = find_body_text(v.parts);
                else --} {
                    if (v.mimeType == 'text/plain') then --{
                        props.message_body = get_plain_text_mail_body(v);
                    elseif (props.message_body == nil and string.sub(v.mimeType, 1, 4) == 'text') then --} {
                        props.message_body = get_plain_text_mail_body(v);
                    end --}
                    if (string.sub(v.mimeType, 1, 4) == 'text') then --{
                        props[string.sub(v.mimeType, 5).."_body"] = get_plain_text_mail_body(v);
                    end --}
                end --}
            else --} {
                local attachment = get_attachment(connection, email_id, mail_item.id, v);
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
            if (v.filename == "") then --{
                if (string.sub(v.mimeType, 1, 9) == 'multipart') then --{
                    props.message_body = find_body_text(v.parts);
                else --} {
                    if (v.mimeType == 'text/plain') then --{
                        props.message_body, props.html_body = get_plain_text_mail_body(v);
                    elseif (props.message_body == nil and string.sub(v.mimeType, 1, 4) == 'text') then --} {
                        props.message_body = get_plain_text_mail_body(v);
                    end --}
                    if (string.sub(v.mimeType, 1, 4) == 'text') then --{
                        props[string.sub(v.mimeType, 5).."_body"] = get_plain_text_mail_body(v);
                    end --}
                end --}
            else --} {
                --[[Attachments here are not interesting ]]
            end --}
        end --}
    elseif (payload.mimeType == 'multipart/report') then --} {
        for i,v in ipairs(payload.parts) do --{
            if (v.filename == "") then --{
                if (string.sub(v.mimeType, 1, 9) == 'multipart') then --{
                    props.message_body, props.html_body = find_body_text(v.parts);
                else --} {
                    if (v.mimeType == 'text/plain') then --{
                        props.message_body = get_plain_text_mail_body(v);
                    elseif (props.message_body == nil and string.sub(v.mimeType, 1, 4) == 'text') then --} {
                        props.message_body = get_plain_text_mail_body(v);
                    end --}
                    if (string.sub(v.mimeType, 1, 4) == 'text') then --{
                        props[string.sub(v.mimeType, 5).."_body"] = get_plain_text_mail_body(v);
                    end --}
                end --}
            else --} {
                local attachment = get_attachment(connection, email_id, mail_item.id, v);
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

email_client.message_from_rfc2822_string = function(raw)

    local mail_item = gmime.parse(raw);

    local message = get_email_message(connection, email_id, token, mail_item, including_attachments);
    if (message == nil) then
        --error("Could not gather parts of message id "..mail_item.id);
    end

    return message;
end


return email_client;
