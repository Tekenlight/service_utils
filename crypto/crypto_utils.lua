local ffi = require('ffi');
local cu = require('lua_schema.core_utils');

--[[ Supported ciphers in openssl => from man page
 base64             Base 64

 bf-cbc             Blowfish in CBC mode
 bf                 Alias for bf-cbc
 bf-cfb             Blowfish in CFB mode
 bf-ecb             Blowfish in ECB mode
 bf-ofb             Blowfish in OFB mode

 cast-cbc           CAST in CBC mode
 cast               Alias for cast-cbc
 cast5-cbc          CAST5 in CBC mode
 cast5-cfb          CAST5 in CFB mode
 cast5-ecb          CAST5 in ECB mode
 cast5-ofb          CAST5 in OFB mode

 des-cbc            DES in CBC mode
 des                Alias for des-cbc
 des-cfb            DES in CBC mode
 des-ofb            DES in OFB mode
 des-ecb            DES in ECB mode

 des-ede-cbc        Two key triple DES EDE in CBC mode
 des-ede            Two key triple DES EDE in ECB mode
 des-ede-cfb        Two key triple DES EDE in CFB mode
 des-ede-ofb        Two key triple DES EDE in OFB mode

 des-ede3-cbc       Three key triple DES EDE in CBC mode
 des-ede3           Three key triple DES EDE in ECB mode
 des3               Alias for des-ede3-cbc
 des-ede3-cfb       Three key triple DES EDE CFB mode
 des-ede3-ofb       Three key triple DES EDE in OFB mode

 desx               DESX algorithm.

 gost89             GOST 28147-89 in CFB mode (provided by ccgost engine)
 gost89-cnt        `GOST 28147-89 in CNT mode (provided by ccgost engine)

 idea-cbc           IDEA algorithm in CBC mode
 idea               same as idea-cbc
 idea-cfb           IDEA in CFB mode
 idea-ecb           IDEA in ECB mode
 idea-ofb           IDEA in OFB mode

 rc2-cbc            128 bit RC2 in CBC mode
 rc2                Alias for rc2-cbc
 rc2-cfb            128 bit RC2 in CFB mode
 rc2-ecb            128 bit RC2 in ECB mode
 rc2-ofb            128 bit RC2 in OFB mode
 rc2-64-cbc         64 bit RC2 in CBC mode
 rc2-40-cbc         40 bit RC2 in CBC mode

 rc4                128 bit RC4
 rc4-64             64 bit RC4
 rc4-40             40 bit RC4

 rc5-cbc            RC5 cipher in CBC mode
 rc5                Alias for rc5-cbc
 rc5-cfb            RC5 cipher in CFB mode
 rc5-ecb            RC5 cipher in ECB mode
 rc5-ofb            RC5 cipher in OFB mode

 aes-[128|192|256]-cbc  128/192/256 bit AES in CBC mode
 aes-[128|192|256]      Alias for aes-[128|192|256]-cbc
 aes-[128|192|256]-cfb  128/192/256 bit AES in 128 bit CFB mode
 aes-[128|192|256]-cfb1 128/192/256 bit AES in 1 bit CFB mode
 aes-[128|192|256]-cfb8 128/192/256 bit AES in 8 bit CFB mode
 aes-[128|192|256]-ecb  128/192/256 bit AES in ECB mode
 aes-[128|192|256]-ofb  128/192/256 bit AES in OFB mode

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
	["gost89"] = 1,
	["gost89-cnt"] = 1,
	["gost89-ecb"] = 1,
	["id-aes128-GCM"] = 0, -- GCM needs certain settings to be done evpoco
	["id-aes192-GCM"] = 0, -- GCM needs certain settings to be done evpoco
	["id-aes256-GCM"] = 0, -- GCM needs certain settings to be done evpoco
	-- Following are aliases
	["AES128"] = 1,
	["AES192"] = 1,
	["AES256"] = 1,
	["BF"] = 1,
	["CAMELLIA128"] = 1,
	["CAMELLIA192"] = 1,
	["CAMELLIA256"] = 1,
	["CAST"] = 1,
	["CAST-cbc"] = 1,
	["DES"] = 1,
	["DES3"] = 1,
	["DESX"] = 1,
	["RC2"] = 1,
	["aes128"] = 1,
	["aes192"] = 1,
	["aes256"] = 1,
	["bf"] = 1,
	["blowfish"] = 1,
	["camellia128"] = 1,
	["camellia192"] = 1,
	["camellia256"] = 1,
	["cast"] = 1,
	["cast-cbc"] = 1,
	["des"] = 1,
	["des3"] = 1,
	["desx"] = 1,
	["rc2"] = 1
}

local evl_crypto = (require('service_utils.common.utils')).load_evlcrypto();

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

	local status, ct, len, ptr = pcall(evl_crypto.encrypt_text, plain_text, symmetric_key);
	if (not status) then
		error(ct);
	end

	local ct_s = cu.new_hex_data_s_type();
	ct_s.buf_mem_managed = 1; -- In order to overcome freeing of pointers twice
	ct_s.value = ptr;
	ct_s.size = ffi.cast("size_t", len);
	return ct, len, ct_s;
end

crypto_utils.b64_encrypt_plain_text = function(plain_text, symmetric_key)
	assert(type(plain_text) == 'string');
	assert(type(symmetric_key) == 'userdata');

	local status, ct, len = pcall(evl_crypto.encrypt_text, plain_text, symmetric_key);
	if (not status) then
		error(ct);
	end

	local ct_s = cu.new_hex_data_s_type();
	ct_s.buf_mem_managed = 1; -- In order to overcome freeing of pointers twice
	local ctp = ffi.cast("cipher_text_s*", ct);
	ct_s.value = ctp.buffer;
	ct_s.size = ctp.len;
	local b64_ct = cu.base64_encode(ct_s);

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

crypto_utils.decrypt_hex_s_cipher_text = function(ct_s, symmetric_key)
	assert(type(ct_s) == 'cdata');
	assert(ffi.istype("hex_data_s_type", ct_s));
	assert(type(symmetric_key) == 'userdata');

	local ptr = ffi.getptr(ct_s.value);
	local size = tonumber(ct_s.size);

	local status, pt = pcall(evl_crypto.decrypt_udata_cipher_text, ptr, size, symmetric_key);
	if (not status) then
		error(pt);
	end

	return pt;
end

crypto_utils.decrypt_b64_cipher_text = function(b64_cipher_text, symmetric_key)
	assert(type(b64_cipher_text) == 'string');
	assert(type(symmetric_key) == 'userdata');

	local ct_s = cu.base64_decode(b64_cipher_text);
	local ptr = ffi.getptr(ct_s.value);
	local size = tonumber(ct_s.size);

	local status, pt = pcall(evl_crypto.decrypt_udata_cipher_text, ptr, size, symmetric_key);
	if (not status) then
		error(pt);
	end

	return pt;
end

crypto_utils.rsa_encrypt_symmetric_key = function(symmetric_key, rsa_pub_key)
	assert(type(symmetric_key) == 'userdata');
	assert(type(rsa_pub_key) == 'userdata');

	local status, e_symm_key, len, ptr = pcall(evl_crypto.rsa_encrypt_symm_key, symmetric_key, rsa_pub_key);
	if (not status) then
		error(e_symm_key);
	end

	local ct_s = cu.new_hex_data_s_type();
	ct_s.buf_mem_managed = 1; -- In order to overcome freeing of pointers twice
	ct_s.value = ptr;
	ct_s.size = ffi.cast("size_t", len);
	return e_symm_key, len, ct_s;
end

crypto_utils.rsa_b64_encrypt_symmetric_key = function(symmetric_key, rsa_pub_key)
	assert(type(symmetric_key) == 'userdata');
	assert(type(rsa_pub_key) == 'userdata');

	local status, e_symm_key = pcall(evl_crypto.rsa_encrypt_symm_key, symmetric_key, rsa_pub_key);
	if (not status) then
		error(e_symm_key);
	end

	local ct_s = cu.new_hex_data_s_type();
	ct_s.buf_mem_managed = 1; -- In order to overcome freeing of pointers twice
	local ctp = ffi.cast("cipher_text_s*", e_symm_key);
	ct_s.value = ctp.buffer;
	ct_s.size = ctp.len;
	local b64_e_symm_key = cu.base64_encode(ct_s);

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

crypto_utils.rsa_decrypt_hex_s_enc_symmetric_key = function(e_symm_key_s, rsa_prv_key)
	assert(type(e_symm_key_s) == 'cdata');
	assert(ffi.istype("hex_data_s_type", e_symm_key_s));
	assert(type(rsa_prv_key) == 'userdata');

	local ptr = ffi.getptr(e_symm_key_s.value);
	local size = tonumber(e_symm_key_s.size);

	local status, o_symm_key = pcall(evl_crypto.rsa_decrypt_udata_enc_symm_key, ptr, size, rsa_prv_key);
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

crypto_utils.s_sha_hash = function(input, salt, length)
	assert(type(input) == 'string');
	assert(type(salt) == 'string');
	assert(math.type(length) == 'integer');
	assert(length == 1 or length == 256 or length == 384 or length == 512);

	return evl_crypto['s_sha'..length..'_hash'](input, salt);
end


return crypto_utils;


