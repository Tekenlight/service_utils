--   luarocks install redis-lua
--
--


local redis = require 'redis'

-- Create a Redis client
local client = redis.connect('127.0.0.1', 6379)

-- Use KEYS to find all keys that match a pattern
local keys = client:keys('SUBSCRIBER.BIOP_MASTERS.*')

-- Check if any keys were found
if #keys == 0 then
    print("No keys found")
else
    -- Fetch the values for all matching keys
    local values = client:mget(table.unpack(keys))

    -- Print the keys and their corresponding values
    for i, key in ipairs(keys) do
        print(key .. ": " .. values[i])
        client:del(key);
    end
end
