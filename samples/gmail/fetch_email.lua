local date = require('date');

local email_client = require('service_utils.gmail.email_client');

local client_sec_json = (function ()
    local file = io.open("/home/ubuntu/product/service_common/test/rest_gmail/gmail-rest-api-integration-34db9244c527.json", "r")
    --local file = io.open("<path to the JSON file downloaded during service client setup in google cloud console>", "r")
    local content = file:read("*all");
    file:close();
    return content;
end)();


local now = date(true)
now = now:adddays(-4);
local crit_date =  now:fmt("%Y/%m/%d");

local email_id = 'sudheer.hr@tekenlight.com';

local connection, token, http_status = email_client.make_connection(client_sec_json, email_id);

local list = email_client.get_email_list(connection, email_id, token,
    {
        after = crit_date
    }
);


local emails = email_client.get_inbox_emails(connection, email_id, token, list, false);

print(debug.getinfo(1).source, debug.getinfo(1).currentline);
--print(#list.messages);
print(emails[1].id);
require 'pl.pretty'.dump(list.messages);
print(emails[1].id == list.messages[1].id)
require 'pl.pretty'.dump(emails);
print(debug.getinfo(1).source, debug.getinfo(1).currentline);

--[=[
local msg = [[Hi,

We are unable to process this message

please send the same in the correct format

Kindly contact support for any help.

Best,
SVS
]]

if (emails[1] ~= nil and emails[1].return_path == '<hrsudeer@yahoo.com>') then
    print(debug.getinfo(1).source, debug.getinfo(1).currentline);
    print(debug.getinfo(1).source, debug.getinfo(1).currentline);
    email_client.plain_text_reply(connection, email_id, token, emails[1].id, msg);
end

]=]


