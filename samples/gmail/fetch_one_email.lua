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


local email = email_client.get_message(connection, email_id, token, '1928f7202bd93447', false);

print(debug.getinfo(1).source, debug.getinfo(1).currentline);
require 'pl.pretty'.dump(email);
print(debug.getinfo(1).source, debug.getinfo(1).currentline);

