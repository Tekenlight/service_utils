local serde = require('service_utils.common.primitive_serde');
local cjson = require("cjson.safe").new();
local cu = require('lua_schema.core_utils');
local properties_funcs = platform.properties_funcs();

declare("MD_TOTAL_TRIALS", 0);
declare("MD_TOTAL_HITS", 0);

local master_db_cache = {}

local make_config_conn = function()
	local config_db_name = properties_funcs.get_string_property("service_utils.config_db_name");
	local config_params = require('db_params'):get_db_params(config_db_name);
	local db_access = require(config_params.handler);
	local conn = db_access.open_connection(table.unpack(config_params.params));
	conn.database_name = config_db_name;

	return conn;
end

local get_database_name = function(context, tao)
	local conn = context:get_connection(tao.db_name);
	return conn.database_name;
end

local serialize = function(rec)
	assert(type(rec) == 'table', "Invalid rec");
	local sd = {};
	for n,v in pairs(rec) do
		sd[n] = serde.serialize(v);
	end
	local out = cjson.encode(sd);

	return out;
end

local deserialize = function(json_str)
	assert(type(json_str) == 'string', "Invalid json_str");
	local out = cjson.decode(json_str);

	local result = {};
	for n,v in pairs(out) do
		result[n] = serde.deserialize(v.sv, v.tn, v.sz);
	end

	return result;
end

local low_prepare_str_key = function(db_name, tbl_def, rec)
	assert(rec ~= nil and type(rec) == 'table');
	assert(db_name ~= nil and type(db_name) == 'string');

    local key_columns = tbl_def.key_col_names;
    local key = {};
    for i = 1, #key_columns do
        local obj_key = key_columns[i]
        key[obj_key] = rec[obj_key];
    end
    local str = db_name .."." .. tbl_def.tbl_props.database_schema.. "." .. tbl_def.tbl_props.name;
    for k, v in pairs(key) do
        str = str .. k .. "~" .. v .. "~~"
    end
    return string.sub(str, 1, -3); 
end

master_db_cache.form_key = function(context , tao, key)
	assert(type(context) == 'table', "Invalid context");
	assert(type(tao) == 'table', "Invalid tao");
	assert(type(key) == 'table', "Invalid key");

	return low_prepare_str_key(get_database_name(context, tao), tao.tbl_def, key);
end

master_db_cache.add = function (context, tao, record)
	assert(type(tao) == 'table', "Invalid tao");
	assert(type(record) == 'table', "Invalid key");
	assert(type(context) == 'table', "Invalid context");
	print(debug.getinfo(1).source, debug.getinfo(1).currentline, "ADD");

	--local config_conn = context.db_connections['CONFIG'].conn;
	local config_conn = make_config_conn();

	local key_str = master_db_cache.form_key(context, tao, record);

	local status, msg = config_conn:set(key_str, cu.str_base64_encode(serialize(record)));
	if (not status) then
		error(msg);
	end

	--[[ expiry time can fetched from config]]
	print(debug.getinfo(1).source, debug.getinfo(1).currentline);
	print(tonumber(properties_funcs.get_int_property("service_utils.orm.master_db_cache.TTL")));
	print(debug.getinfo(1).source, debug.getinfo(1).currentline);
	local status, msg = config_conn:set_expiry(key_str, tonumber(properties_funcs.get_int_property("service_utils.orm.master_db_cache.TTL")));
	if (not status) then
		error(msg);
	end

	return;
end

master_db_cache.fetch = function (context, tao, key)
	MD_TOTAL_TRIALS = MD_TOTAL_TRIALS + 1;
	assert(type(tao) == 'table', "Invalid tao");
	assert(type(key) == 'table', "Invalid key");
	assert(type(context) == 'table', "Invalid context");
	print(debug.getinfo(1).source, debug.getinfo(1).currentline, "FETCH");

	--local config_conn = context.db_connections['CONFIG'].conn;
	local config_conn = make_config_conn();

	local key_str = master_db_cache.form_key(context, tao, key);
	local status, response, msg = config_conn:get(key_str);
	if (not status) then
		error(msg);
	end

	if (response ~= nil) then
		MD_TOTAL_HITS = MD_TOTAL_HITS + 1;
		print(debug.getinfo(1).source, debug.getinfo(1).currentline, "CACHE HIT", MD_TOTAL_HITS);
		print(debug.getinfo(1).source, debug.getinfo(1).currentline, "CACHE HIT", MD_TOTAL_TRIALS);
		return deserialize(cu.str_base64_decode(response));
	else
		print(debug.getinfo(1).source, debug.getinfo(1).currentline, "CACHE MISS");
		print(debug.getinfo(1).source, debug.getinfo(1).currentline, "CACHE MISS");
		return nil;
	end
end

master_db_cache.remove = function (context, tao, key)
	assert(type(tao) == 'table', "Invalid tao");
	assert(type(key) == 'table', "Invalid key");
	assert(type(context) == 'table', "Invalid context");
	print(debug.getinfo(1).source, debug.getinfo(1).currentline, "REMOVE");

	--local config_conn = context.db_connections['CONFIG'].conn;
	local config_conn = make_config_conn();

	local key_str = master_db_cache.form_key(context, tao, key);
	local status, response, msg = config_conn:del(key_str);
	if (not status) then
		error(msg);
	end

	return;
end

return master_db_cache;
