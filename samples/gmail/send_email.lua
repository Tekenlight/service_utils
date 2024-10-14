local error_handler = require('lua_schema.error_handler');
local date = require('date');

local email_client = require('service_utils.gmail.email_client');

error_handler.init();

local client_sec_json = (function ()
    local file = io.open("<path to the JSON file downloaded during service client setup in google cloud console>", "r")
    local content = file:read("*all");
    file:close();
    return content;
end)();


local now = date(true)
now = now:adddays(-3);
local crit_date =  now:fmt("%Y/%m/%d");

local email_id = 'sudheer.hr@tekenlight.com';

local connection, token, http_status = email_client.make_connection(client_sec_json, email_id);


local email_message = {};
email_message.from = 'sudheer.hr@tekenlight.com';
email_message.sender_name = 'Sudheer H R';
email_message.recipients = {};
email_message.recipients[1] = {};
email_message.recipients[1].address = 'hrsudeer@yahoo.com';
email_message.recipients[1].recipient_type = 0;
email_message.recipients[1].real_name = 'Yahoo Sudheer H R';
email_message.subject = 'Testing send utility';
email_message.message_body =

[=[Hi,

This is a test mail

Enjoy the testing

Best,
]=]

email_client.send_mail(connection, 'sudheer.hr@tekenlight.com', token, email_message);

