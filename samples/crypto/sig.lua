local ffi = require('ffi');
local cu = require('lua_schema.core_utils');
local crypto_utils = require('service_utils.crypto.crypto_utils');

local str = [[
This is some test message for the purpose of testing digital signature, there is nothing much to type as such

This is some test message for the purpose of testing digital signature
]]


local rsa_pair = crypto_utils.form_rsa_key_pair(1024);

print(debug.getinfo(1).source, debug.getinfo(1).currentline);
local sig = crypto_utils.sign_message(str, rsa_pair.prv_key, "sha256")
print(debug.getinfo(1).source, debug.getinfo(1).currentline);



local status = crypto_utils.verify_signature(str, rsa_pair.pub_key, "sha256", sig);
print(debug.getinfo(1).source, debug.getinfo(1).currentline);
print(status);
print(debug.getinfo(1).source, debug.getinfo(1).currentline);

local status = crypto_utils.verify_signature_prv_key(str, rsa_pair.prv_key, "sha256", sig);
print(debug.getinfo(1).source, debug.getinfo(1).currentline);
print(status);
print(debug.getinfo(1).source, debug.getinfo(1).currentline);

