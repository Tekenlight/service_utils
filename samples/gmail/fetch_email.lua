local email_client = require('service_utils.gmail.email_client');

local client_sec_json = (function ()
    local file = io.open("<path to the JSON file downloaded during service client setup in google cloud console>", "r")
    local content = file:read("*all");
    file:close();
    return content;
end)();


local email_id = 'sudheer.hr@tekenlight.com';

local connection, token, http_status = email_client.make_connection(client_sec_json, email_id);

local list = email_client.get_email_list(connection, email_id, token,
    {
        after = '2024/10/11'
    }
);


local emails = email_client.get_inbox_emails(connection, email_id, token, list);

print(debug.getinfo(1).source, debug.getinfo(1).currentline);
print(#emails);
--require 'pl.pretty'.dump(emails);
print(debug.getinfo(1).source, debug.getinfo(1).currentline);
