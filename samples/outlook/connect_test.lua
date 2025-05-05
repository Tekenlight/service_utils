local date = require('date');

local email_client = require('outlook.email_client');

local client_sec_json = (function ()
    local file = io.open("/home/ubuntu/product/service_common/test/outlook/azure_details.json", "r")
    --local file = io.open("<path to the JSON file containing microsoft credentials>", "r")
    local content = file:read("*all");
    file:close();
    return content;
end)();


local now = date(true)
now = now:adddays(-4);
local crit_date =  now:fmt("%Y/%m/%d");

local email_id = 'sudheer.hr@tekenlight.com';

local connection, token, http_status = email_client.make_connection(client_sec_json, email_id);

print(debug.getinfo(1).source, debug.getinfo(1).currentline);
require 'pl.pretty'.dump(token);
print(debug.getinfo(1).source, debug.getinfo(1).currentline);
