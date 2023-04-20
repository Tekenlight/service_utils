local crypto_utils = require('service_utils.crypto.crypto_utils');

local plain_text = [[<?xml version="1.0" encoding="UTF-8"?>
 <ns1:test_message xmlns:ns1="http://xchange_messages.biop.com">
   <greeting>Hello World</greeting>
   <greeting>Hello World</greeting>
 </ns1:test_message>]]

local symmetric_key = crypto_utils.generate_symmetric_key("des-cbc");

local ct, len, buffer = crypto_utils.encrypt_plain_text(plain_text, symmetric_key);
local pt = crypto_utils.decrypt_cipher_text(ct, symmetric_key);

print(plain_text == pt);
