local ffi = require('ffi');
local schema_processor = require("schema_processor");
local transaction = require("service_utils.orm.transaction");
local master_db_cache = require('service_utils.orm.master_db_cache');

local tao = {}

local issue_savepoint_sql = [[SAVEPOINT ORM_TAO_FACTORY_SAVEPOINT]]
local rollback_savepoint_sql = [[ROLLBACK TO SAVEPOINT ORM_TAO_FACTORY_SAVEPOINT]]

local function get_db_table_name(tbl_def)
	return tbl_def.tbl_props.database_schema .. "." .. tbl_def.tbl_props.name;
end

local low_prepare_str_key = function(tbl_def, rec)
	assert(rec ~= nil and type(rec) == 'table');

	local key_columns = tbl_def.key_col_names;
	local key = {};
	for i = 1, #key_columns do
		local obj_key = key_columns[i]
		key[obj_key] = rec[obj_key];
	end
	local str = ""
	for k, v in pairs(key) do
		str = str .. k .. "~" .. v .. "~~"
	end
	return string.sub(str, 1, -3);
end

local prepare_str_key = function(tao, rec)
	assert(tao ~= nil and type(tao) == 'table');
	assert(rec ~= nil and type(rec) == 'table');

	return low_prepare_str_key(tao.tbl_def, rec);
end

local function get_qualified_table_name(context, tbl_name)
	local tbl_def_class_name = context.module_path..".tbl."..tbl_name
	return tbl_def_class_name;
end

local function instantiate_tbl_def(context, tbl_name)
	local tbl_def_class_name = get_qualified_table_name(context, tbl_name);
	local tbl_def = require(tbl_def_class_name);

	return tbl_def;
end

local mt = { __index = tao };
local tao_factory = {};

tao_factory.init = function(context)
	context.open_tbls = {};
end

tao_factory.open = function(context, db_name, tbl_name)
	assert(context ~= nil and type(context) == 'table');
	assert(db_name ~= nil and type(db_name) == 'string');
	assert(tbl_name ~= nil and type(tbl_name) == 'string');
	local l_open_tbls = context.open_tbls;
	assert(l_open_tbls ~= nil);
	local tbl_def = nil;
	if (l_open_tbls[tbl_name] == nil) then
		tbl_def = instantiate_tbl_def(context, tbl_name);
		if (tbl_def == nil) then
			error("Table definition for ["..tbl_name.."] not found");
		end
		l_open_tbls[tbl_name] = tbl_def;
	end
	tbl_def = l_open_tbls[tbl_name];
	local obj = {};
	obj = setmetatable(obj, mt);
	obj.db_name = db_name;
	assert(context:get_connection(db_name) ~= nil);
	obj.tbl_def = tbl_def;
	assert(obj.tbl_def ~= nil);
	return obj;
end

tao_factory.flush_all = function(context)
	for _, conn in pairs(context.db_connections) do
		if (conn.conn.cached_data) then
			conn.conn.cached_data = {};
		end
	end
end

local function val_of_elem_in_obj(obj, name)
	assert(obj ~= nil and type(obj) == 'table');
	assert(name ~= nil and type(name) == 'string');
	assert(string.match(name, "%[") == nil);
	assert(string.match(name, "%]") == nil);
	local names = require "pl.stringx".split(name, '.')
	local val = obj;
	for i,v in ipairs(names) do
		if (val[v] == nil) then
			val = nil;
			break;
		end
		val = val[v];
	end

	return val;

end

local function get_element_val_from_obj(obj, name, col_map, tbl_def)
	if (col_map == nil) then
		return obj[name];
	else
		local obj_col_name = col_map[name];
		assert(obj_col_name ~= nil and type(obj_col_name) == 'string', "column ["..name.."] not present in object corresponding to table ["..get_db_table_name(tbl_def).."]");
		local val = val_of_elem_in_obj(obj, obj_col_name);
		return val;
	end
end

tao_factory.get_element_name_in_obj = function(tbl_col_name, col_map)
	if (col_map == nil) then
		return tbl_col_name;
	else
		return col_map[tbl_col_name];
	end
end

local function assert_key_columns_present(context, tbl_def, obj, col_map)
	assert(col_map == nil or type(col_map) == 'table');
	if (col_map == nil) then
		for i, col in ipairs(tbl_def.key_col_names) do
			if (obj[col] == nil) then
				error("Key column ["..col.."] must be present in the input object");
			end
		end
	else
		for i, col in ipairs(tbl_def.key_col_names) do
			local obj_col_name = col_map[col];
			if (not(obj_col_name ~= nil and type(obj_col_name) == 'string')) then
				print(debug.getinfo(1).source, debug.getinfo(1).currentline);
				require 'pl.pretty'.dump(tbl_def.key_col_names);
				require 'pl.pretty'.dump(obj);
				require 'pl.pretty'.dump(col_map);
				print(debug.getinfo(1).source, debug.getinfo(1).currentline);
			end
			assert(obj_col_name ~= nil and type(obj_col_name) == 'string',
				"Key columns not present ["..get_db_table_name(tbl_def)..":"..col.."]");
			local val = val_of_elem_in_obj(obj, obj_col_name);
			if (val == nil) then
				error("["..get_db_table_name(tbl_def).."]:".."Key column ["..obj_col_name.."] must be present in the input object");
			end
		end
	end
end

local function assert_version_column_present(context, tbl_def, obj, col_map)
	assert(col_map == nil or type(col_map) == 'table');
	if (col_map == nil) then
		if (obj.version == nil) then
			error("Column [version] not present in the input object");
		end
	else
		local obj_col_name = col_map.version;
		assert(obj_col_name ~= nil and type(obj_col_name) == 'string',
			"version should be present in col_map for table ".. get_db_table_name(tbl_def));
		local val = val_of_elem_in_obj(obj, obj_col_name);
		if (val == nil) then
			error("Version Column [".. obj_col_name .."] not present in the input object");
		end
	end
end

declare("TOTAL_TRIALS", 0);
declare("TOTAL_HITS", 0);

tao.select = function(self, context, ...)
	assert(context ~= nil and type(context) == 'table');
	local tbl_def = self.tbl_def;
	local obj = {};
	local inp_args = {...};
	local key = {};
	do
		local n = #inp_args;
		local v = nil;
		for i,col in ipairs(tbl_def.key_col_names) do
			v = select(i, table.unpack(inp_args));
			if (v == nil) then
				error(get_db_table_name(tbl_def)..":SELECT:".."Parameter:["..i.."]:["..col.."] cannot be NULL")
			end
			key[tbl_def.key_col_names[i]] = v;
		end
	end
	local conn = context:get_connection(self.db_name);
	assert(conn ~= nil);
	do
		-- Caching
		TOTAL_TRIALS = TOTAL_TRIALS + 1;
		local key_str = prepare_str_key(self, key)
		local db_table_name = get_db_table_name(tbl_def);
		if (conn.cached_data[db_table_name] == nil) then
			conn.cached_data[db_table_name] = {};
		end
		local out = conn.cached_data[db_table_name][key_str];
		if (out ~= nil) then
			TOTAL_HITS = TOTAL_HITS + 1;
			return out;
		end
		--[[
		print(debug.getinfo(1).source, debug.getinfo(1).currentline, TOTAL_HITS);
		print(debug.getinfo(1).source, debug.getinfo(1).currentline, TOTAL_TRIALS);
		]]
	end
	--[[
	print(debug.getinfo(1).source, debug.getinfo(1).currentline);
	require 'pl.pretty'.dump(self.tbl_def.tbl_props);
	print(debug.getinfo(1).source, debug.getinfo(1).currentline);
	]]
	if (self.tbl_def.tbl_props.cache) then
		-- MD-caching
		--print(debug.getinfo(1).source, debug.getinfo(1).currentline);
		local out = master_db_cache.fetch(context, self, key);
		if (out ~= nil) then
			--print(debug.getinfo(1).source, debug.getinfo(1).currentline);

			-- Caching
			local key_str = prepare_str_key(self, out)
			local db_table_name = get_db_table_name(tbl_def);
			if (conn.cached_data[db_table_name] == nil) then
				conn.cached_data[db_table_name] = {}
			end
			conn.cached_data[db_table_name][key_str] = out;

			return out;
		end
	end

	local stmt = conn:prepare(tbl_def.select_stmt);
	stmt:execute(table.unpack({...}));
	local result = stmt:fetch_result();
	if (result == nil) then
		local params_string = "[";
		local v = nil;
		for i,col in ipairs(tbl_def.key_col_names) do
			if (i ~= 1) then
				params_string = params_string .. ", ";
			end
			v = select(i, table.unpack(inp_args));
			params_string = params_string ..  col.."="..v;
		end
		params_string = params_string .. "]";
		local msg = "Record not found for "..params_string;
		return nil, msg;
	end

	local out = stmt.map(result, tbl_def.selected_col_names);
	do
		-- Caching
		local key_str = prepare_str_key(self, out)
		local db_table_name = get_db_table_name(tbl_def);
		if (conn.cached_data[db_table_name] == nil) then
			conn.cached_data[db_table_name] = {}
		end
		conn.cached_data[db_table_name][key_str] = out;
	end
	if (self.tbl_def.tbl_props.cache) then
		-- MD-caching
		master_db_cache.add(context, self, out);
	end
	return out;
end

tao.selupd = function(self, context, ...)
	assert(context ~= nil and type(context) == 'table');
	local tbl_def = self.tbl_def;
	local obj = {};
	local inp_args = {...};
	do
		local n = #inp_args;
		local v = nil;
		for i,col in ipairs(tbl_def.key_col_names) do
			v = select(i, table.unpack(inp_args));
			if (v == nil) then
				error("Parameter:["..i.."]:["..col.."] cannot be NULL")
			end
		end
	end
	local conn = context:get_connection(self.db_name);
	assert(conn ~= nil);
	do
		-- Caching
		-- NO CACHING FOR SELUPD
	end
	if (self.tbl_def.tbl_props.cache) then
		-- MD-caching
		-- NO CACHING FOR SELUPD
	end

	local stmt = conn:prepare(tbl_def.selupd_stmt);
	stmt:execute(table.unpack({...}));
	local result = stmt:fetch_result();
	if (result == nil) then
		local params_string = "[";
		local v = nil;
		for i,col in ipairs(tbl_def.key_col_names) do
			if (i ~= 1) then
				params_string = params_string .. ", ";
			end
			v = select(i, table.unpack(inp_args));
			params_string = params_string ..  col.."="..v;
		end
		params_string = params_string .. "]";
		local msg = "Record not found for "..params_string;
		return nil, msg;
	end

	local out = stmt.map(result, tbl_def.selected_col_names);
	do
		-- Caching
		local key_str = prepare_str_key(self, out)
		local db_table_name = get_db_table_name(tbl_def);
		if (conn.cached_data[db_table_name] == nil) then
			conn.cached_data[db_table_name] = {}
		end
		conn.cached_data[db_table_name][key_str] = out;
	end
	if (self.tbl_def.tbl_props.cache) then
		-- MD-caching
		master_db_cache.add(context, self, out);
	end
	return out;
end

tao.insert = function(self, context, obj, col_map)
	assert(col_map == nil or type(col_map) == 'table');
	assert(context ~= nil and type(context) == 'table');
	assert(obj ~= nil and type(obj) == 'table');
	local tbl_def = self.tbl_def;
	assert_key_columns_present(context, tbl_def, obj, col_map);

	local conn = context:get_connection(self.db_name);
	assert(conn ~= nil);

	local stmt = conn:prepare(tbl_def.insert_stmt);
	local inputs = {};
	local auto_columns = {};
	local data = {};
	local key_columns = {};
	local count = 0;
	local now = conn:get_systimestamp();
	if (tbl_def.col_props.soft_del == true) then
		auto_columns.deleted = false;
	end
	if (tbl_def.col_props.creation_fields == true) then
		auto_columns.creation_uid = context.uid
		auto_columns.creation_time = now;
	end
	if (tbl_def.col_props.update_fields == true) then
		auto_columns.update_uid = context.uid
		auto_columns.update_time = now;
		local version = ffi.cast("int64_t", 1);
		auto_columns.version = version;
	end

	for i, col in ipairs(tbl_def.key_col_names) do
		local element_name = tao_factory.get_element_name_in_obj(col, col_map)
		if (obj[element_name] ~= nil) then
			local elemet_val = get_element_val_from_obj(obj, col, col_map, tbl_def)
			key_columns[col] = elemet_val;
		end
	end

	for i, col in ipairs(tbl_def.declared_col_names) do
		count = count + 1;
		if (obj[col] ~= nil) then
			--inputs[count] = obj[col];
			local elemet_val = get_element_val_from_obj(obj, col, col_map, tbl_def)
			inputs[count] = elemet_val
			data[col] = elemet_val;
		else
			local default_value = tbl_def.declared_columns[col].default_value;
			if(default_value ~= nil) then
				inputs[count] = default_value;
				data[col] = default_value;
			else
				inputs[count] = nil;
				data[col] = nil;
			end
		end
	end
	for i, col in ipairs(tbl_def.auto_col_names) do
		count = count + 1;
		if (auto_columns[col] ~= nil) then
			inputs[count] = auto_columns[col];
			data[col] = auto_columns[col];
		else
			local default_value = tbl_def.auto_columns[col].default_value;
			if(default_value ~= nil) then
				inputs[count] = default_value;
				data[col] = default_value;
			else
				inputs[count] = nil;
				data[col] = nil;
			end
		end
	end

	if (conn:get_in_transaction()) then conn:prepare(issue_savepoint_sql):execute(); end
	local flg, msg = stmt:vexecute(count, inputs, true)
	if (not flg) then
		if (conn:get_in_transaction()) then
			conn:prepare(rollback_savepoint_sql):execute();
			conn:reset_connection_error();
		end
		local ret = 0;
		--((nil ~= string.match(msg, 'duplicate')) or (nil ~= string.match(msg, 'violates unique constraint')))
		if ((nil ~= string.match(msg, 'duplicate key value violates unique constraint'))) then
			ret = -1;
		else
			ret = -2;
		end
		return false, msg, ret;
	end
	local ret = stmt:affected();
	if (0 == ret) then
		return false, msg, ret;
	end

	do
		-- Caching
		local key_str = prepare_str_key(self, data)
		local db_table_name = get_db_table_name(tbl_def);
		if (conn.cached_data[db_table_name] == nil) then
			conn.cached_data[db_table_name] = {};
		end
		conn.cached_data[db_table_name][key_str] = data;;
	end
	if (self.tbl_def.tbl_props.cache) then
		-- MD-caching
		-- Nothing to be done during insert
	end

	tao_factory.set_auto_columns(context, tbl_def, obj, data, col_map);

	-- insert data into the dml ops map
	transaction.append_to_ops_list(context, self.tbl_def.tbl_props.name, 0, data, key_columns, self.db_name);

	return true, nil, ret;
end

tao_factory.get_column_map_from_obj_meta = function(context, tbl_def, obj_meta, columns)
	assert(columns == nil or type(columns) == 'table');
	local columns_map = nil;
	if (columns) then
		columns_map = {};
		for i, name in ipairs(columns) do
			columns_map[name] = 1;
		end
		for i, name in ipairs(tbl_def.key_col_names) do
			columns_map[name] = 1;
		end
		--[[
		for i, name in ipairs(tbl_def.auto_col_names) do
			columns_map[name] = 1;
		end
		]]
	end
	assert(obj_meta ~= nil);
	assert(tbl_def ~= nil);
	local out = {};
	local elem_handler;
	assert(type(obj_meta) == 'table');
	assert(obj_meta.elem ~= nil and type(obj_meta.elem) == 'string');
	assert(obj_meta.elem_ns == nil or type(obj_meta.elem_ns) == 'string');
	elem_handler = schema_processor:get_message_handler(obj_meta.elem, obj_meta.elem_ns);
	assert(elem_handler ~= nil);
	local elems = elem_handler.properties.generated_subelements;
	for i, col in ipairs(tbl_def.declared_col_names) do
		if (columns_map == nil or columns_map[col] ~= nil) then
			if (elems[col] ~= nil and elems[col].properties.content_type == 'S') then
				out[col] = col;
			end
		end
	end
	if (tbl_def.col_props.update_fields == true) then
		if (elems.version ~= nil and elems.version.properties.content_type == 'S') then
			out.version = 'version';;
		end
	end
	return out;
end

tao.insert_using_meta = function(self, context, obj, obj_meta, columns)
	assert(obj_meta ~= nil);
	local col_map = tao_factory.get_column_map_from_obj_meta(context, self.tbl_def, obj_meta, columns)
	return self:insert(context, obj, col_map);
end

tao_factory.set_auto_columns = function(context, tbl_def, obj, data, col_map)
	if (tbl_def.col_props.update_fields) then
		local element_name = tao_factory.get_element_name_in_obj("version", col_map);
		if (element_name) then
			obj[element_name] = data["version"]
		end

		element_name = tao_factory.get_element_name_in_obj("update_uid", col_map);
		if (element_name) then
			obj[element_name] = data["update_uid"]
		end

		element_name = tao_factory.get_element_name_in_obj("update_time", col_map);
		if (element_name) then
			obj[element_name] = data["update_time"]
		end
	end

	if (tbl_def.col_props.entity_state_field == true) then
		local element_name = tao_factory.get_element_name_in_obj("entity_state", col_map);
		if (element_name) then
			obj[element_name] = data["entity_state"]
		end
	end
	return;
end

local function prepare_update_stmt(context, conn, tbl_def, obj, col_map)
	if (col_map ~= nil) then
		assert(type(col_map) == 'table');
	end
	local inputs = {};
	-- data will hold the data to be updated
	local data = {};
	-- it will hold the where clause parameter of the query
	local key_columns = {};
	local stmt = nil;
	stmt = "UPDATE " .. tbl_def.tbl_props.database_schema .. "." .. tbl_def.tbl_props.name .. "\n";
	stmt = stmt.."SET ";
	local count = 0;
	local j = 0;

	for i, col in ipairs(tbl_def.key_col_names) do
		if (obj[col] ~= nil) then
			local elemet_val = get_element_val_from_obj(obj, col, col_map, tbl_def)
		end
	end

	if (col_map == nil) then
		-- Update all non-key columns
		for i, col in ipairs(tbl_def.non_key_col_names) do
			j = j + 1;
			count = count + 1;
			inputs[count] = obj[col];
			data[col] = obj[col];
			if (j ~= 1) then
				stmt = stmt..", "..col .. "=?";
			else
				stmt = stmt..col .. "=?";
			end
		end
	else
		-- Update mapped non-key columns
		for i, col in ipairs(tbl_def.non_key_col_names) do
			local obj_col_name = col_map[col];
			if (obj_col_name ~= nil) then
				local val = val_of_elem_in_obj(obj, obj_col_name);
				j = j + 1;
				count = count + 1;
				inputs[count] = val;
				data[obj_col_name] = val;
				if (j ~= 1) then
					stmt = stmt..", "..col .. "=?";
				else
					stmt = stmt..col .. "=?";
				end
			end
		end
	end
	j = nil;

	if (tbl_def.col_props.update_fields == true) then
		local now = conn:get_systimestamp();
		local new_version = obj.version + 1;

		count = count + 1;
		inputs[count] = context.uid;
		data["update_uid"] = context.uid
		if (count == 1) then
			stmt = stmt.." update_uid=?";
		else
			stmt = stmt..", update_uid=?";
		end

		data["update_time"] = now
		count = count + 1;
		inputs[count] = now;
		stmt = stmt..", update_time=?";

		data["version"] = new_version
		count = count + 1;
		inputs[count] = new_version;
		stmt = stmt..", version=?";
	end

	if (tbl_def.col_props.entity_state_field == true) then
		if (obj["entity_state"] ~= nil) then
			count = count + 1;
			inputs[count] = obj["entity_state"];
			if (count == 1) then
				stmt = stmt.." entity_state=?";
			else
				stmt = stmt..", entity_state=?";
			end
			data.entity_state = obj.entity_state;
		end
	end

	stmt = stmt .. "\n";
	stmt = stmt .. "WHERE";

	for i, col in ipairs(tbl_def.key_col_names) do
		count = count + 1;
		local val;
		if (col_map ~= nil) then
			local obj_col_name = col_map[col];
			assert(obj_col_name ~= nil);
			val = val_of_elem_in_obj(obj, obj_col_name);
		else
			val = obj[col];
		end
		inputs[count] = val
		assert(inputs[count] ~= nil);
		key_columns[col] = val
		if (i ~= 1) then
			stmt = stmt.." AND "..col.."=?";
		else
			stmt = stmt.." "..col.."=?";
		end
	end

	if (tbl_def.col_props.update_fields) then
		count = count + 1;
		local val;
		if (col_map ~= nil) then
			val = get_element_val_from_obj(obj, 'version', col_map, tbl_def);
		else
			val = obj['version'];
		end
		inputs[count] = val
		key_columns["version"] = val
		stmt = stmt.." AND version" .. "=?";
	end

	return stmt, inputs, count, data, key_columns;
end

tao.raw_update = function(self, context, obj, col_map)
	assert(context ~= nil and type(context) == 'table');
	assert(obj ~= nil and type(obj) == 'table');
	if (col_map ~= nil) then
		assert(type(col_map) == 'table');
	end
	local tbl_def = self.tbl_def;
	assert_key_columns_present(context, tbl_def, obj, col_map);
	if (tbl_def.col_props.update_fields == true) then
		assert_version_column_present(context, tbl_def, obj, col_map);
	end

	local conn = context:get_connection(self.db_name);
	assert(conn ~= nil);

	local query_stmt, inputs, count, data, key_columns = prepare_update_stmt(context, conn, tbl_def, obj, col_map);

	if (conn:get_in_transaction()) then conn:prepare(issue_savepoint_sql):execute(); end
	local stmt = conn:prepare(query_stmt);
	local flg, msg = stmt:vexecute(count, inputs, true)
	if (not flg) then
		if (conn:get_in_transaction()) then
			conn:prepare(rollback_savepoint_sql):execute();
			conn:reset_connection_error();
		end
		return false, msg, -1;
	end
	local ret = stmt:affected();
	if (0 == ret) then
		msg = "["..tbl_def.tbl_props.database_schema .. "." .. tbl_def.tbl_props.name.."]:"
		msg = msg.."Error : Trying to update a non-exsitent version of the record";
		return false, msg, ret;
	end

	do
		-- Caching
		local key_str = prepare_str_key(self, key_columns)
		local db_table_name = get_db_table_name(tbl_def);
		if (conn.cached_data[db_table_name] == nil) then
			conn.cached_data[db_table_name] = {};
		end
		local out = conn.cached_data[db_table_name][key_str];
		if (out ~= nil) then
			for n,v in pairs(data) do
				out[n] = v;
			end
		end
	end
	if (self.tbl_def.tbl_props.cache) then
		-- MD-caching
		-- Remove the record from MDB cache when there is an update
		master_db_cache.remove(context, self, data);
	end

	tao_factory.set_auto_columns(context, tbl_def, obj, data, col_map);

	-- insert data into the dml ops map
	transaction.append_to_ops_list(context, tbl_def.tbl_props.name, 1, data, key_columns, self.db_name);

	return true, nil, ret;
end

tao.update = function(self, context, obj, col_map)
	assert(col_map ~= nil and type(col_map) == 'table');
	return self:raw_update(context, obj, col_map);
end

tao.update_using_meta = function(self, context, obj, obj_meta, columns)
	assert(obj_meta ~= nil);
	local col_map = tao_factory.get_column_map_from_obj_meta(context, self.tbl_def, obj_meta, columns)
	return self:raw_update(context, obj, col_map);
end

tao.flush = function(self, context)
	local tbl_def = self.tbl_def;
	do
		-- Caching
		local db_table_name = get_db_table_name(tbl_def);
		if (conn.cached_data[db_table_name] == nil) then
			conn.cached_data[db_table_name] = {};
		end
		for n,v  in pairs(conn.cached_data[db_table_name]) do
			conn.cached_data[db_table_name][n] = nil;
		end
	end
	if (self.tbl_def.tbl_props.cache) then
		-- MD-caching
		-- Nothing to be done during table flush, as this is a local operation
	end
	return ;
end

tao.delete = function(self, context, obj)
	assert(context ~= nil and type(context) == 'table');
	assert(obj ~= nil and type(obj) == 'table');
	local tbl_def = self.tbl_def;
	assert_key_columns_present(context, tbl_def, obj);
	if (tbl_def.col_props.update_fields == true) then
		assert_version_column_present(context, tbl_def, obj);
	end

	local inputs = {};
	local data = {};
	local count = 0;
	for i, col in ipairs(tbl_def.key_col_names) do
		count = count + 1;
		inputs[count] = obj[col];
		data[col] = obj[col];
	end
	if (tbl_def.col_props.update_fields) then
		count = count + 1;
		inputs[count] = obj.version;
		data["version"] = obj.version;
	end

	local conn = context:get_connection(self.db_name);
	assert(conn ~= nil);

	if (conn:get_in_transaction()) then conn:prepare(issue_savepoint_sql):execute(); end
	local stmt = conn:prepare(tbl_def.delete_stmt);
	local flg, msg = stmt:vexecute(count, inputs, true)
	if (not flg) then
		if (conn:get_in_transaction()) then
			conn:prepare(rollback_savepoint_sql):execute();
			conn:reset_connection_error();
		end
		return false, msg, -1;
	end
	local ret = stmt:affected();
	if (0 == ret) then
		msg = "["..tbl_def.tbl_props.database_schema .. "." .. tbl_def.tbl_props.name.."]:"
		msg = msg.."Error : Trying to delete a non existent or an older version of the record";
		return false, msg, ret;
	end

	do
		-- Caching
		local key_str = prepare_str_key(self, data)
		local db_table_name = get_db_table_name(tbl_def);
		if (conn.cached_data[db_table_name] == nil) then
			conn.cached_data[db_table_name] = {};
		end
		local out = conn.cached_data[db_table_name][key_str];
		if (out ~= nil) then
			conn.cached_data[db_table_name][key_str] = nil;
		end
	end
	if (self.tbl_def.tbl_props.cache) then
		-- MD-caching
		-- Remove the record from MDB cache when there is a delete
		master_db_cache.remove(context, self, data);
	end

	-- insert data into the dml ops map
	transaction.append_to_ops_list(context, tbl_def.tbl_props.name, 2, data, data, self.db_name);

	return true, nil, ret;
end

local function logical_del_or_undel(context, conn, action, tbl_def, obj, name)
	assert(context ~= nil and type(context) == 'table');
	assert(conn ~= nil);
	assert(obj ~= nil and type(obj) == 'table');
	assert(tbl_def ~= nil and tbl_def.col_props.soft_del == true);
	assert(action ~= nil and type(action) == 'string' and (action == 'D' or action == 'U'))

	assert_key_columns_present(context, tbl_def, obj);
	if (tbl_def.col_props.update_fields == true) then
		assert_version_column_present(context, tbl_def, obj);
	end

	assert(conn ~= nil);

	local inputs = {};
	local data = {};
	local count = 0;
	local operation = 0;

	count = count + 1;
	if (action == 'D') then
		inputs[count] = true;
		operation = 3;
	else
		inputs[count] = false;
		operation = 4;
	end

	if (tbl_def.col_props.update_fields == true) then
		local now = conn:get_systimestamp();
		local new_version = obj.version + 1;

		count = count + 1;
		inputs[count] = context.uid;
		data["update_uid"] = context.uid

		count = count + 1;
		inputs[count] = now;
		data["update_time"] = now

		count = count + 1;
		inputs[count] = new_version;
		data["version"] = new_version;
	end

	for i, col in ipairs(tbl_def.key_col_names) do
		count = count + 1;
		inputs[count] = obj[col];
		data[col] = obj[col];
	end
	count = count + 1;
	if (action == 'D') then
		inputs[count] = false;
	else
		inputs[count] = true;
	end

	if (tbl_def.col_props.update_fields) then
		count = count + 1;
		inputs[count] = obj.version;
	end

	local stmt = conn:prepare(tbl_def.logdel_stmt);
	if (conn:get_in_transaction()) then conn:prepare(issue_savepoint_sql):execute(); end
	local flg, msg = stmt:vexecute(count, inputs, true)
	if (not flg) then
		if (conn:get_in_transaction()) then
			conn:prepare(rollback_savepoint_sql):execute();
			conn:reset_connection_error();
		end
		return false, msg, -1;
	end
	local ret = stmt:affected();
	if (0 == ret) then
		msg = "["..tbl_def.tbl_props.database_schema .. "." .. tbl_def.tbl_props.name.."]:"
		if (action == 'D') then
			msg = msg.."Error : Did not find the correct undeleted version of the record for logical delete";
		else
			msg = msg.."Error : Did not find the correct deleted version of the record for logical delete";
		end
		return false, msg, ret;
	end

	do
		-- Caching
		local key_str = low_prepare_str_key(tbl_def, data)
		local db_table_name = get_db_table_name(tbl_def);
		if (conn.cached_data[db_table_name] == nil) then
			conn.cached_data[db_table_name] = {};
		end
		local out = conn.cached_data[db_table_name][key_str];
		if (out ~= nil) then
			for n,v in pairs(data) do
				out[n] = v;
			end
		end
	end
	if (tbl_def.tbl_props.cache) then
		-- MD-caching
		-- Remove the record from MDB cache when there is an logdel/undel (update)
		master_db_cache.remove(context, self, data);
	end

	tao_factory.set_auto_columns(context, tbl_def, obj, data, nil);

	-- insert data into the dml ops map
	transaction.append_to_ops_list(context, tbl_def.tbl_props.name, operation, data, data, name);

	return true, nil, ret;
end

tao.logdel = function(self, context, obj)
	assert(context ~= nil and type(context) == 'table');
	assert(obj ~= nil and type(obj) == 'table');
	local tbl_def = self.tbl_def;
	assert(tbl_def ~= nil and tbl_def.col_props.soft_del == true);
	assert_key_columns_present(context, tbl_def, obj);
	if (tbl_def.col_props.update_fields == true) then
		assert_version_column_present(context, tbl_def, obj);
	end

	local conn = context:get_connection(self.db_name);
	assert(conn ~= nil);

	return logical_del_or_undel(context, conn, 'D', tbl_def, obj, self.db_name);
end

tao.undelete = function(self, context, obj)
	assert(context ~= nil and type(context) == 'table');
	assert(obj ~= nil and type(obj) == 'table');
	local tbl_def = self.tbl_def;
	assert(tbl_def ~= nil and tbl_def.col_props.soft_del == true);
	assert_key_columns_present(context, tbl_def, obj);
	if (tbl_def.col_props.update_fields == true) then
		assert_version_column_present(context, tbl_def, obj);
	end

	local conn = context:get_connection(self.db_name);
	assert(conn ~= nil);

	return logical_del_or_undel(context, conn, 'U', tbl_def, obj, self.db_name);
end

tao.get_list = function(self, context, query_params)
	assert(context ~= nil and type(context) == 'table');
	assert(obj ~= nil and type(obj) == 'table');
	local tbl_def = self.tbl_def;
	assert(tbl_def ~= nil);

	assert(1 ~= 1);
end

tao.generic_select_query = function (self, context, order_by, where_statement, ...)
	assert(where_statement == nil or (type(where_statement) == 'string' and string.len(where_statement) > 0));
	assert(context ~= nil and type(context) == 'table');

	local tbl_def = self.tbl_def;
	assert(tbl_def ~= nil);

	local select_query = "";
	for i,v in ipairs(tbl_def.selected_col_names) do -- {
		if (i ==1) then
			select_query = select_query .. 'SELECT ' .. v;
		else
			select_query = select_query .. ', ' .. v;
		end
	end -- }
	select_query = select_query .. ' FROM '.. tbl_def.tbl_props.database_schema .. "." .. tbl_def.tbl_props.name;

	if where_statement ~= nil then
		select_query = select_query .. " WHERE " .. where_statement;
	end

	if order_by ~= nil then
		select_query = select_query .. " ORDER BY " .. order_by;
	end

	local conn = context:get_connection(self.db_name);
	assert(conn ~= nil);

	local stmt = conn:prepare(select_query);

	if where_statement ~= nil then
		stmt:execute(table.unpack({...}));
	else
		stmt:execute();
	end

	local count = 0;
	local data = {};

	local rec = stmt:fetch_result();
	while (rec ~= nil) do -- {
		local row = stmt.map(rec, tbl_def.selected_col_names);
		data[count] = row;
		count = count + 1;
		rec = stmt:fetch_result();
	end --}

	return data;
end

tao_factory.prepare_mod_key = function(self, context, db_name, table_name, rec)
	assert(context ~= nil and type(context) == 'table');
	assert(db_name ~= nil and type(db_name) == 'string');
	assert(table_name ~= nil and type(table_name) == 'string');
	assert(rec ~= nil and type(rec) == 'table');

	local tao = tao_factory.open(context, db_name, table_name)
	return prepare_str_key(tao, rec);
end

tao_factory.key_from_mod = function(input_string)
	assert(input_string ~= nil and type(input_string) == 'string');
	local obj = {}

	for key, value in input_string:gmatch("(%w+)~([^~]+)") do
		obj[key] = value
	end

	return obj
end

return tao_factory;
