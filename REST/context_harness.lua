
local ffi = require('ffi');
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

return context_harness;
