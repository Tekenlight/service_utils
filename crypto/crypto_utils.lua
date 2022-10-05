local ffi = require('ffi');
local cu = require('lua_schema.core_utils');

ffi.cdef[[
void * pin_loaded_so(const char * libname);
struct cipher_text_s {
    unsigned char * buffer;
    size_t len;
};
]]

local cipher_algorithms = {
	["AES-128-CBC"] = 1,
	["AES-128-CFB"] = 1,
	["AES-128-CFB1"] = 1,
	["AES-128-CFB8"] = 1,
	["AES-128-CTR"] = 1,
	["AES-128-ECB"] = 1,
	["AES-128-OFB"] = 1,
	["AES-128-XTS"] = 1,
	["AES-192-CBC"] = 1,
	["AES-192-CFB"] = 1,
	["AES-192-CFB1"] = 1,
	["AES-192-CFB8"] = 1,
	["AES-192-CTR"] = 1,
	["AES-192-ECB"] = 1,
	["AES-192-OFB"] = 1,
	["AES-256-CBC"] = 1,
	["AES-256-CFB"] = 1,
	["AES-256-CFB1"] = 1,
	["AES-256-CFB8"] = 1,
	["AES-256-CTR"] = 1,
	["AES-256-ECB"] = 1,
	["AES-256-OFB"] = 1,
	["AES-256-XTS"] = 1,
	["BF-CBC"] = 1,
	["BF-CFB"] = 1,
	["BF-ECB"] = 1,
	["BF-OFB"] = 1,
	["CAMELLIA-128-CBC"] = 1,
	["CAMELLIA-128-CFB"] = 1,
	["CAMELLIA-128-CFB1"] = 1,
	["CAMELLIA-128-CFB8"] = 1,
	["CAMELLIA-128-ECB"] = 1,
	["CAMELLIA-128-OFB"] = 1,
	["CAMELLIA-192-CBC"] = 1,
	["CAMELLIA-192-CFB"] = 1,
	["CAMELLIA-192-CFB1"] = 1,
	["CAMELLIA-192-CFB8"] = 1,
	["CAMELLIA-192-ECB"] = 1,
	["CAMELLIA-192-OFB"] = 1,
	["CAMELLIA-256-CBC"] = 1,
	["CAMELLIA-256-CFB"] = 1,
	["CAMELLIA-256-CFB1"] = 1,
	["CAMELLIA-256-CFB8"] = 1,
	["CAMELLIA-256-ECB"] = 1,
	["CAMELLIA-256-OFB"] = 1,
	["CAST5-CBC"] = 1,
	["CAST5-CFB"] = 1,
	["CAST5-ECB"] = 1,
	["CAST5-OFB"] = 1,
	["ChaCha"] = 1,
	["DES-CBC"] = 1,
	["DES-CFB"] = 1,
	["DES-CFB1"] = 1,
	["DES-CFB8"] = 1,
	["DES-ECB"] = 1,
	["DES-EDE"] = 1,
	["DES-EDE-CBC"] = 1,
	["DES-EDE-CFB"] = 1,
	["DES-EDE-OFB"] = 1,
	["DES-EDE3"] = 1,
	["DES-EDE3-CBC"] = 1,
	["DES-EDE3-CFB"] = 1,
	["DES-EDE3-CFB1"] = 1,
	["DES-EDE3-CFB8"] = 1,
	["DES-EDE3-OFB"] = 1,
	["DES-OFB"] = 1,
	["DESX-CBC"] = 1,
	["RC2-40-CBC"] = 1,
	["RC2-64-CBC"] = 1,
	["RC2-CBC"] = 1,
	["RC2-CFB"] = 1,
	["RC2-ECB"] = 1,
	["RC2-OFB"] = 1,
	["RC4"] = 1,
	["RC4-40"] = 1,
	["RC4-HMAC-MD5"] = 1,
	["gost89"] = 0,
	["gost89-cnt"] = 0,
	["gost89-ecb"] = 0,
	["id-aes128-GCM"] = 0,
	["id-aes192-GCM"] = 0,
	["id-aes256-GCM"] = 0
}


--[[
"AES128 => AES-128-CBC"
"AES192 => AES-192-CBC"
"AES256 => AES-256-CBC"
"BF => BF-CBC"
"CAMELLIA128 => CAMELLIA-128-CBC"
"CAMELLIA192 => CAMELLIA-192-CBC"
"CAMELLIA256 => CAMELLIA-256-CBC"
"CAST => CAST5-CBC"
"CAST-cbc => CAST5-CBC"
"DES => DES-CBC"
"DES3 => DES-EDE3-CBC"
"DESX => DESX-CBC"
"RC2 => RC2-CBC"
"aes128 => AES-128-CBC"
"aes192 => AES-192-CBC"
"aes256 => AES-256-CBC"
"bf => BF-CBC"
"blowfish => BF-CBC"
"camellia128 => CAMELLIA-128-CBC"
"camellia192 => CAMELLIA-192-CBC"
"camellia256 => CAMELLIA-256-CBC"
"cast => CAST5-CBC"
"cast-cbc => CAST5-CBC"
"des => DES-CBC"
"des3 => DES-EDE3-CBC"
"desx => DESX-CBC"
"rc2 => RC2-CBC"
]]

local evl_crypto_loader = package.loadlib('libevlcrypto.so','luaopen_libevlcrypto');
local loaded, evl_crypto = pcall(evl_crypto_loader);
if(not loaded) then
    error("Could not load library: "..evl_crypto);
end
local loaded, lib = pcall(ffi.C.pin_loaded_so, 'libevlcrypto.so');
if(not loaded) then
    error("Could not load library: "..evl_crypto);
end

local crypto_utils = {};

crypto_utils.form_rsa_key_pair = function(modulus)
	assert(type(modulus) == 'number');
	local status, rsa_key_pair = pcall(evl_crypto.generate_rsa_key_pair, modulus);
	if (not status) then
		error(rsa_key_pair);
	end
	local pub_key = evl_crypto.get_rsa_public_key(rsa_key_pair);
	local prv_key = evl_crypto.get_rsa_private_key(rsa_key_pair);

	return { pub_key = pub_key, prv_key = prv_key };
end

crypto_utils.get_rsa_public_key = function(rsa_pub_key)
	assert(type(rsa_pub_key) == 'userdata');
	local status, pub_key = pcall(evl_crypto.get_rsa_public_key, rsa_pub_key);
	if (not status) then
		error(pub_key);
	end

	return pub_key;
end

crypto_utils.get_rsa_private_key = function(rsa_prv_key)
	assert(type(rsa_prv_key) == 'userdata');
	local status, prv_key = pcall(evl_crypto.get_rsa_private_key, rsa_prv_key);
	if (not status) then
		error(prv_key);
	end

	return prv_key;
end

crypto_utils.form_rsa_key_from_public_key = function(public_key)
	assert(type(public_key) == 'string');
	local status, rsa_public_key = pcall(evl_crypto.load_rsa_public_key, public_key);
	if (not status) then
		error(rsa_public_key);
	end
	return rsa_public_key;
end

crypto_utils.form_rsa_key_from_private_key = function(private_key)
	assert(type(private_key) == 'string');
	local status, rsa_private_key = pcall(evl_crypto.load_rsa_private_key, private_key);
	if (not status) then
		error(rsa_private_key);
	end
	return rsa_private_key;
end

crypto_utils.generate_symmetric_key = function(name)
	assert(type(name) == 'string');
	assert((cipher_algorithms[string.upper(name)] == 1) or (cipher_algorithms[name] == 1));
	local status, symmetric_key = pcall(evl_crypto.generate_symmetric_key, name);
	if (not status) then
		error(symmetric_key);
	end

	return symmetric_key;
end

crypto_utils.generate_aes_key = function(size)
	assert(type(size) == 'number');
	local status, symmetric_key = pcall(evl_crypto.generate_aes_key, size);
	if (not status) then
		error(symmetric_key);
	end

	return symmetric_key;
end

crypto_utils.encrypt_plain_text = function(plain_text, symmetric_key)
	assert(type(plain_text) == 'string');
	assert(type(symmetric_key) == 'userdata');

	local status, ct, len = pcall(evl_crypto.encrypt_text, plain_text, symmetric_key);
	if (not status) then
		error(ct);
	end

	return ct, len;
end

crypto_utils.b64_encrypt_plain_text = function(plain_text, symmetric_key)
	assert(type(plain_text) == 'string');
	assert(type(symmetric_key) == 'userdata');

	local status, ct, len = pcall(evl_crypto.encrypt_text, plain_text, symmetric_key);
	if (not status) then
		error(ct);
	end

	local ct_s = ffi.new("hex_data_s_type", 0);
	local ctp = ffi.cast("cipher_text_s*", ct);
	ct_s.value = ctp.buffer;
	ct_s.size = ctp.len;
	local b64_ct = cu.base64_encode(ct_s);
	ct_s.value = ffi.NULL; -- In order to overcome freeing of pointers twice

	return b64_ct;
end

crypto_utils.decrypt_cipher_text = function(cipher_text, symmetric_key)
	assert(type(cipher_text) == 'userdata');
	assert(type(symmetric_key) == 'userdata');

	local status, pt = pcall(evl_crypto.decrypt_cipher_text, cipher_text, symmetric_key);
	if (not status) then
		error(pt);
	end

	return pt;
end

crypto_utils.decrypt_b64_cipher_text = function(b64_cipher_text, symmetric_key)
	assert(type(b64_cipher_text) == 'string');
	assert(type(symmetric_key) == 'userdata');

	local ct = cu.base64_decode(b64_cipher_text);
	local ptr = ffi.getptr(ct.value);
	local size = tonumber(ct.size);

	local status, pt = pcall(evl_crypto.decrypt_udata_cipher_text, ptr, size, symmetric_key);
	if (not status) then
		error(pt);
	end

	return pt;
end

crypto_utils.rsa_encrypt_symmetric_key = function(symmetric_key, rsa_pub_key)
	assert(type(symmetric_key) == 'userdata');
	assert(type(rsa_pub_key) == 'userdata');

	local status, e_symm_key, len = pcall(evl_crypto.rsa_encrypt_symm_key, symmetric_key, rsa_pub_key);
	if (not status) then
		error(e_symm_key);
	end

	return e_symm_key, len;
end

crypto_utils.rsa_b64_encrypt_symmetric_key = function(symmetric_key, rsa_pub_key)
	assert(type(symmetric_key) == 'userdata');
	assert(type(rsa_pub_key) == 'userdata');

	local status, e_symm_key = pcall(evl_crypto.rsa_encrypt_symm_key, symmetric_key, rsa_pub_key);
	if (not status) then
		error(e_symm_key);
	end

	local ct_s = ffi.new("hex_data_s_type", 0);
	local ctp = ffi.cast("cipher_text_s*", e_symm_key);
	ct_s.value = ctp.buffer;
	ct_s.size = ctp.len;
	local b64_e_symm_key = cu.base64_encode(ct_s);
	ct_s.value = ffi.NULL; -- In order to overcome freeing of pointers twice

	return b64_e_symm_key;
end

crypto_utils.rsa_decrypt_enc_symmetric_key = function(e_symm_key, rsa_prv_key)
	assert(type(e_symm_key) == 'userdata');
	assert(type(rsa_prv_key) == 'userdata');

	local status, o_symm_key = pcall(evl_crypto.rsa_decrypt_enc_symm_key, e_symm_key, rsa_prv_key);
	if (not status) then
		error(o_symm_key);
	end

	return o_symm_key;
end

crypto_utils.rsa_decrypt_b64_enc_symmetric_key = function(b64_e_symm_key, rsa_prv_key)
	assert(type(b64_e_symm_key) == 'string');
	assert(type(rsa_prv_key) == 'userdata');
	local status, o_symm_key = pcall(evl_crypto.rsa_decrypt_b64_enc_symm_key, b64_e_symm_key, rsa_prv_key);
	if (not status) then
		error(o_symm_key);
	end

	return o_symm_key;
end


return crypto_utils;


