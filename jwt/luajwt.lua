local cjson  = require 'cjson'
local core_utils = require("lua_schema.core_utils");
local evl_crypto_loader = package.loadlib('libevlcrypto.so','luaopen_libevlcrypto');
local loaded, evl_crypto = pcall(evl_crypto_loader);
if(not loaded) then
    error("Could not load library:"..evl_crypto);
end

local alg_sign = {
	['HS256'] = function(data, key) return evl_crypto.hmac_digest('sha256', data, key, true) end,
	['HS384'] = function(data, key) return evl_crypto.hmac_digest('sha384', data, key, true) end,
	['HS512'] = function(data, key) return evl_crypto.hmac_digest('sha512', data, key, true) end,
}

local alg_verify = {
	['HS256'] = function(data, signature, key) return signature == alg_sign['HS256'](data, key) end,
	['HS384'] = function(data, signature, key) return signature == alg_sign['HS384'](data, key) end,
	['HS512'] = function(data, signature, key) return signature == alg_sign['HS512'](data, key) end,
}

local function b64_encode_str(input)	
	local result = core_utils.str_base64_encode(input)

	result = result:gsub('+','-'):gsub('/','_'):gsub('=','')

	return result
end

local function url_decode(input)
	local i = 1;
	local len = string.len(input);
	local b64_len = 0;
	local c;
	while (i <= len) do
		c = string.sub(input, i, i);
		if (c ~= ' ' and c ~= '\t' and  c ~= '\r' and c ~= '\n') then
			b64_len = b64_len + 1;
		end
		i = i + 1;
	end
	while ((b64_len % 4) ~= 0) do
		input = input .. '=';
		b64_len = b64_len + 1;
	end

	input = input:gsub('-','+'):gsub('_','/')

	return input;
end


local function b64_decode(input)
	return core_utils.base64_decode(url_decode(input))
end

local function b64_decode_str(input)
	return core_utils.str_base64_decode(url_decode(input))
end

local function tokenize(str, div, len)
	local result, pos = {}, 0

	for st, sp in function() return str:find(div, pos, true) end do

		result[#result + 1] = str:sub(pos, st-1)
		pos = sp + 1

		len = len - 1

		if len <= 1 then
			break
		end
	end

	result[#result + 1] = str:sub(pos)

	return result
end

local M = {}

function M.encode(data, key, alg)
	if type(data) ~= 'table' then return nil, "Argument #1 must be table" end
	if type(key) ~= 'string' then return nil, "Argument #2 must be string" end

	alg = alg or "HS256";

	if not alg_sign[alg] then
		return nil, "Algorithm not supported"
	end

	local header = { typ='JWT', alg=alg }

	local segments = {
		b64_encode_str(cjson.encode(header)),
		b64_encode_str(cjson.encode(data))
	}

	local signing_input = table.concat(segments, ".");

	local status, signature = pcall(alg_sign[alg], signing_input, key);
	if (not status) then
		local err = signature;
		return nil, err, nil;
	end
	local s = b64_encode_str(signature);

	segments[#segments+1] = b64_encode_str(signature);

	return table.concat(segments, "."), nil;
end

function M.decode(data, key, verify)
	if key and verify == nil then verify = true end
	if type(data) ~= 'string' then return nil, "Argument #1 must be string" end
	if verify and type(key) ~= 'string' then return nil, "Argument #2 must be string" end

	local token = tokenize(data, '.', 3)

	if #token ~= 3 then
		return nil, "Invalid token"
	end

	local headerb64, bodyb64, sigb64 = token[1], token[2], token[3]

	local ok, header, body, sig = pcall(function ()

		return	cjson.decode(b64_decode_str(headerb64)), 
			cjson.decode(b64_decode_str(bodyb64)),
			b64_decode_str(sigb64)
	end)	


	if not ok then
		return nil, "Invalid json"
	end

	if verify then

		if not header.typ or header.typ ~= "JWT" then
			return nil, "Invalid typ"
		end

		if not header.alg or type(header.alg) ~= "string" then
			return nil, "Invalid alg"
		end

		if body.exp and type(body.exp) ~= "number" then
			return nil, "exp must be number"
		end

		if body.nbf and type(body.nbf) ~= "number" then
			return nil, "nbf must be number"
		end

		if not alg_verify[header.alg] then
			return nil, "Algorithm not supported"
		end

		if not alg_verify[header.alg](headerb64 .. "." .. bodyb64, sig, key) then
			return nil, "Invalid signature"
		end

		if body.exp and os.time() >= body.exp then
			return nil, "Not acceptable by exp"
		end

		if body.nbf and os.time() < body.nbf then
			return nil, "Not acceptable by nbf"
		end
	end

	return body
end

return M
