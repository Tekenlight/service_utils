local ffi = require('ffi');
local schema_processor = require("schema_processor");
local tao = {}

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

tao_factory.open = function(context, schema_name, tbl_name)
	assert(context ~= nil and type(context) == 'table');
	assert(schema_name ~= nil and type(schema_name) == 'string');
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
	obj.conn = context.db_connections[schema_name].conn;
	assert(obj.conn ~= nil);
	obj.tbl_def = tbl_def;
	assert(obj.tbl_def ~= nil);
	return obj;
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

local function get_element_val_from_obj(obj, name, col_map)
	if (col_map == nil) then
		return obj[name];
	else
		local obj_col_name = col_map[name];
		assert(obj_col_name ~= nil and type(obj_col_name) == 'string');
		local val = val_of_elem_in_obj(obj, obj_col_name);
		return val;
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
			assert(obj_col_name ~= nil and type(obj_col_name) == 'string');
			local val = val_of_elem_in_obj(obj, obj_col_name);
			if (val == nil) then
				error("Key column ["..obj_col_name.."] must be present in the input object");
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
		assert(obj_col_name ~= nil and type(obj_col_name) == 'string');
		local val = val_of_elem_in_obj(obj, obj_col_name);
		if (val == nil) then
			error("Version Column [".. obj_col_name .."] not present in the input object");
		end
	end
end

tao.select = function(self, context, ...)
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
	local conn = self.conn;
	assert(conn ~= nil);

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
	local conn = self.conn;
	assert(conn ~= nil);

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
	return out;
end

tao.insert = function(self, context, obj, col_map)
	assert(col_map == nil or type(col_map) == 'table');
	assert(context ~= nil and type(context) == 'table');
	assert(obj ~= nil and type(obj) == 'table');
	local tbl_def = self.tbl_def;
	assert_key_columns_present(context, tbl_def, obj, col_map);

	local conn = self.conn;
	assert(conn ~= nil);

	local stmt = conn:prepare(tbl_def.insert_stmt);
	local inputs = {};
	local auto_columns = {};
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

	for i, col in ipairs(tbl_def.declared_col_names) do
		count = count + 1;
		if (obj[col] ~= nil) then
			--inputs[count] = obj[col];
			inputs[count] = get_element_val_from_obj(obj, col, col_map)
		else
			inputs[count] = nil;
		end
	end
	for i, col in ipairs(tbl_def.auto_col_names) do
		count = count + 1;
		if (auto_columns[col] ~= nil) then
			inputs[count] = auto_columns[col];
		else
			inputs[count] = nil;
		end
	end
	local flg, msg = stmt:vexecute(count, inputs, true)
	if (not flg) then
		return false, msg;
	end
	if (0 == stmt:affected()) then
		return false, msg;
	end
	return true;
end

local function get_column_map_from_obj_meta(context, tbl_def, obj_meta)
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
		if (elems[col] ~= nil and elems[col].properties.content_type == 'S') then
			out[col] = col;
		end
	end
	if (tbl_def.col_props.update_fields == true) then
		if (elems.version ~= nil and elems.version.properties.content_type == 'S') then
			out.version = 'version';;
		end
	end
	return out;
end

tao.insert_using_meta = function(self, context, obj, obj_meta)
	assert(obj_meta ~= nil);
	local col_map = get_column_map_from_obj_meta(context, self.tbl_def, obj_meta)
	return self:insert(context, obj, col_map);
end

local function prepare_update_stmt(context, conn, tbl_def, obj, col_map)
	if (col_map ~= nil) then
		assert(type(col_map) == 'table');
	end
	local inputs = {};
	local stmt = nil;
	stmt = "UPDATE " .. tbl_def.tbl_props.database_schema .. "." .. tbl_def.tbl_props.name .. "\n";
	stmt = stmt.."SET ";
	local count = 0;
	local j = 0;
	if (col_map == nil) then
		-- Update all non-key columns
		for i, col in ipairs(tbl_def.non_key_col_names) do
			j = j + 1;
			count = count + 1;
			inputs[count] = obj[col];
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
				if (j ~= 1) then
					stmt = stmt..", "..col .. "=?";
				else
					stmt = stmt..col .. "=?";
				end
			end
		end
	end
	j = nil;
	if (count == 0) then
		error("None of the columns for table ["..tbl_def.tbl_props.database_schema .. "." .. tbl_def.tbl_props.name.."] present in the input object");
	end
	if (tbl_def.col_props.update_fields == true) then
		local now = conn:get_systimestamp();
		local new_version = obj.version + 1;

		count = count + 1;
		inputs[count] = context.uid;
		stmt = stmt..", update_uid=?";

		count = count + 1;
		inputs[count] = now;
		stmt = stmt..", update_time=?";

		count = count + 1;
		inputs[count] = new_version;
		stmt = stmt..", version=?";

	end
	stmt = stmt .. "\n";
	stmt = stmt .. "WHERE";

	for i, col in ipairs(tbl_def.key_col_names) do
		count = count + 1;
		local obj_col_name = col_map[col];
		assert(obj_col_name ~= nil);
		inputs[count] = val_of_elem_in_obj(obj, obj_col_name);
		assert(inputs[count] ~= nil);
		if (i ~= 1) then
			stmt = stmt.." AND "..col.."=?";
		else
			stmt = stmt.." "..col.."=?";
		end
	end
	if (tbl_def.col_props.update_fields) then
		count = count + 1;
		inputs[count] = get_element_val_from_obj(obj, 'version', col_map);
		stmt = stmt.." AND version" .. "=?";
	end

	return stmt, inputs, count;
end

tao.update = function(self, context, obj, col_map)
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

	local conn = self.conn;
	assert(conn ~= nil);

	local query_stmt, inputs, count = prepare_update_stmt(context, conn, tbl_def, obj, col_map);

	local stmt = conn:prepare(query_stmt);
	local flg, msg = stmt:vexecute(count, inputs, true)
	if (not flg) then
		return false, msg;
	end
	if (stmt:affected() == 0) then
		msg = "["..tbl_def.tbl_props.database_schema .. "." .. tbl_def.tbl_props.name.."]:"
		msg = msg.."Error : Trying to update a non-exsitent version of the record";
		return false, msg;
	end
	return true, nil;
end

tao.update_using_meta = function(self, context, obj, obj_meta)
	assert(obj_meta ~= nil);
	local col_map = get_column_map_from_obj_meta(context, self.tbl_def, obj_meta)
	return self:update(context, obj, col_map);
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
	local count = 0;
	for i, col in ipairs(tbl_def.key_col_names) do
		count = count + 1;
		inputs[count] = obj[col];
	end
	if (tbl_def.col_props.update_fields) then
		count = count + 1;
		inputs[count] = obj.version;;
	end

	local conn = self.conn;
	assert(conn ~= nil);

	local stmt = conn:prepare(tbl_def.delete_stmt);
	local flg, msg = stmt:vexecute(#inputs, inputs, true)
	if (not flg) then
		return false, msg;
	end
	if (stmt:affected() == 0) then
		msg = "["..tbl_def.tbl_props.database_schema .. "." .. tbl_def.tbl_props.name.."]:"
		msg = msg.."Error : Trying to delete a non existent or an older version of the record";
		return false, msg;
	end
	return true, nil;
end

local function logical_del_or_undel(context, conn, action, tbl_def, obj)
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
	local count = 0;

	count = count + 1;
	if (action == 'D') then
		inputs[count] = true;
	else
		inputs[count] = false;
	end

	if (tbl_def.col_props.update_fields == true) then
		local now = conn:get_systimestamp();
		local new_version = obj.version + 1;

		count = count + 1;
		inputs[count] = context.uid;

		count = count + 1;
		inputs[count] = now;

		count = count + 1;
		inputs[count] = new_version;
	end

	for i, col in ipairs(tbl_def.key_col_names) do
		count = count + 1;
		inputs[count] = obj[col];
	end
	count = count + 1;
	if (action == 'D') then
		inputs[count] = false;
	else
		inputs[count] = true;
	end

	if (tbl_def.col_props.update_fields) then
		count = count + 1;
		inputs[count] = obj.version;;
	end

	local stmt = conn:prepare(tbl_def.logdel_stmt);
	local flg, msg = stmt:vexecute(#inputs, inputs, true)
	if (not flg) then
		return false, msg;
	end
	if (stmt:affected() == 0) then
		msg = "["..tbl_def.tbl_props.database_schema .. "." .. tbl_def.tbl_props.name.."]:"
		if (action == 'D') then
			msg = msg.."Error : Did not find the correct undeleted version of the record for logical delete";
		else
			msg = msg.."Error : Did not find the correct deleted version of the record for logical delete";
		end
		return false, msg;
	end
	return true, nil;
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

	local conn = self.conn;
	assert(conn ~= nil);

	return logical_del_or_undel(context, conn, 'D', tbl_def, obj);
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

	local conn = self.conn;
	assert(conn ~= nil);

	return logical_del_or_undel(context, conn, 'U', tbl_def, obj);
end

tao.commit = function(self, context)
	assert(self ~= nil and type(self) == 'table');
	assert(context ~= nil and type(context) == 'table');
	local conn = self.conn;
	local flg, msg = conn:commit();
	if (not flg) then
		error(msg);
	end
	return;
end

tao.rollback = function(self, context)
	assert(self ~= nil and type(self) == 'table');
	assert(context ~= nil and type(context) == 'table');
	local conn = self.conn;
	local flg, msg = conn:rollback();
	if (not flg) then
		error(msg);
	end
	return;
end


return tao_factory;
