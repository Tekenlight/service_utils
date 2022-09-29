
local ffi = require('ffi');
local date_utils = require('lua_schema.date_utils');
local jwt = require('service_utils.jwt.luajwt')
local master_db_params = require("db_params");
local tao_factory = require('service_utils.orm.tao_factory');
local properties_funcs = platform.properties_funcs();
local error_handler = require("lua_schema.error_handler");


local context_harness = {};


local function make_db_connections(params)
	local db_connections = {};
	for n, v in pairs(params) do
		local db_access = require(v.handler);
		local conn = db_access.open_connetion(table.unpack(v.params));
		db_connections[n] = { client_type = v.client_type, conn = conn, handler = db_access };
	end
	return db_connections;
end

local function begin_trans(uc)
	for n, v in pairs(uc.db_connections) do
		if (v.client_type == 'rdbms') then
			v.conn:begin();
		end
	end
end

local function reset_db_connections(uc)
	for n, v in pairs(uc.db_connections) do
		if (v.client_type == 'rdbms') then
			if (v.conn.exec) then v.conn:end_tran(); end
		end
	end
end

local function begin_transaction(db_schema_name, uc)
	local flg = false;
	if (db_schema_name == nil) then
		error("CONNECTION NAME MUST BE SPECIFIED FOR IF TRANSACTIONA CONTROL IS REQUIRED");
		return false;
	else
		uc.db_connections[db_schema_name].conn:begin();
		flg = true;
	end
	return flg;
end

local function end_transaction(db_schema_name, uc, status)
	local flg = false;
	if (status) then
		uc.db_connections[db_schema_name].conn:commit();
		flg = true;
	else
		uc.db_connections[db_schema_name].conn:rollback();
		flg = true;
	end
	return flg;
end

function context_harness.prepare_uc(databases, module_path, jwt_token)
	assert(databases ~= nil and type(databases) == 'table');
	assert(module_path ~= nil and type(module_path) == 'string');
	assert(jwt_token ~= nil and type(jwt_token) == 'string');

	local db_conection_params = master_db_params:get_params(table.unpack(databases));

	local uc = require('service_utils.common.user_context').new();
	local key = properties_funcs.get_string_property("platform.jwtSignatureKey");

	local header, token, sig, token_parts = jwt.deserialize(jwt_token, key, true);
	if (header == nil or header == false) then
		local msg = token;
		error(msg);
	end

	if (token.verified ~= true) then
		local token_valid, msg = jwt.valid(header, token, sig, key, token_parts);
		if (not token_valid) then
			error(msg);
		end
	end

	token.exp_time = os.date('%Y-%m-%d %T', token.exp);
	token.nbf_time = os.date('%Y-%m-%d %T', token.nbf);
	token.verified = true;

	uc.uid = ffi.cast("int64_t", tonumber(token.uid));
	uc.token = token;
	uc.access_token = jwt.encode(token, key, header.alg);;
	uc.module_path = module_path;

	tao_factory.init(uc);

	if (nil ~= db_conection_params) then
		uc.db_connections = make_db_connections(db_conection_params);
	end

	error_handler.init();

	return uc;
end

local function does_request_need_auth(request, url_parts)
	local json_parser = cjson.new();
	local prop_str = properties_funcs.get_string_property("service_utils.REST.controller.noAuthUrls");
	if (prop_str == nil) then
		return true;
	end
	local obj, msg = json_parser.decode(prop_str);
	if (obj == nil) then
		return true;
	end
	local url = (URI_CLASS:new(request:get_uri())):path();
	for i,v in ipairs(obj.urls) do
		if (v == url) then
			return false;
		end
	end

	return true;
end

context_harness.prepare_uc_REST = function(request, url_parts)
	local uc = require('service_utils.common.user_context').new();

	local key = properties_funcs.get_string_property("platform.jwtSignatureKey");

	local hdr_flds = request:get_hdr_fields();
	local jwt_token = hdr_flds['X-Auth'];
	local offset = 1;

	if (jwt_token == nil) then
		if (does_request_need_auth(request, url_parts)) then
			return nil, "header X-Auth: JWT token not present";
		else
			uc.uid = ffi.cast("int64_t", 0);
		end
	else
		local token_header, token_body, sig, token_parts = jwt.deserialize(jwt_token, key, true);
		if (token_header == nil) then
			local msg = token_body;
			if (does_request_need_auth(request, url_parts)) then
				return nil, msg;
			else
				uc.uid = ffi.cast("int64_t", 0);
			end
		else
			assert(token_body ~= nil);
			assert(sig ~= nil);
			assert(token_parts ~= nil);
			if (token_body.typ ~= 'jwt/access') then
				return nil, "Only access tokens are allowed";
			end
			if (token_body.verified == nil or (not token_body.verified)) then
				local token_valid, msg = jwt.valid(token_header, token_body, sig, key, token_parts);
				if (not token_valid) then
					return nil, msg;
				end
			end
			token_body.verified = true;
			uc.access_token = jwt.encode(token_body, key, token_header.alg);;
			--uc.verified_jwt_token = jwt.encode(token_body, key, token_header.alg);
			token_body.exp_time = date_utils.from_xml_datetime(os.date('%Y-%m-%dT%TZ', token_body.exp));
			token_body.nbf_time = date_utils.from_xml_datetime(os.date('%Y-%m-%dT%TZ', token_body.nbf));
			token_body.uid = ffi.cast("int64_t", tonumber(token_body.uid));
			uc.uid = token_body.uid;
			uc.token_body = token_body;
		end
	end

	return uc;
end

return context_harness;
