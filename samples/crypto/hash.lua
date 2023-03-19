local crypto_utils = require('service_utils.crypto.crypto_utils');

assert(true == pcall(crypto_utils.s_sha_hash, ".", "abc@def.com", 1));
assert(true == pcall(crypto_utils.s_sha_hash, ".", "abc@def.com", 256));
assert(true == pcall(crypto_utils.s_sha_hash, ".", "abc@def.com", 384));
assert(true == pcall(crypto_utils.s_sha_hash, ".", "abc@def.com", 512));

assert(false == pcall(crypto_utils.s_sha_hash, ".", "abc@def.com", 2));
assert(false == pcall(crypto_utils.s_sha_hash, ".",  2));
assert(false == pcall(crypto_utils.s_sha_hash, ".",  2, 2));

print(debug.getinfo(1).source, debug.getinfo(1).currentline, crypto_utils.s_sha_hash(".", "abc@def.com", 1));
print(debug.getinfo(1).source, debug.getinfo(1).currentline, crypto_utils.s_sha_hash(".", "abc@def.com", 256));
print(debug.getinfo(1).source, debug.getinfo(1).currentline, crypto_utils.s_sha_hash(".", "abc@def.com", 384));
print(debug.getinfo(1).source, debug.getinfo(1).currentline, crypto_utils.s_sha_hash(".", "abc@def.com", 512));

