local ffi = require('ffi');
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

local function get_tbl_def(context, tbl_name)
	local tbl_def = context.open_tbls[tbl_name];
	assert(tbl_def ~= nil and type(tbl_def) == 'table');
	print(debug.getinfo(1).source, debug.getinfo(1).currentline);
	require 'pl.pretty'.dump(tbl_def);
	print(debug.getinfo(1).source, debug.getinfo(1).currentline);

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

local function assert_key_columns_present(context, tbl_def, obj)
	for i, col in ipairs(tbl_def.key_col_names) do
		if (obj[col] == nil) then
			error("Key column ["..col.."] must be present in the input object");
		end
	end
end

local function assert_version_column_present(context, tbl_def, obj)
	if (obj.version == nil) then
		error("Column [version] not present in the input object");
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

tao.insert = function(self, context, obj)
	assert(context ~= nil and type(context) == 'table');
	assert(obj ~= nil and type(obj) == 'table');
	local tbl_def = self.tbl_def;
	assert_key_columns_present(context, tbl_def, obj);

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
			inputs[count] = obj[col];
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

local function prepare_update_stmt(context, conn, tbl_def, obj)
	local inputs = {};
	local stmt = nil;
	stmt = "UPDATE " .. tbl_def.tbl_props.database_schema .. "." .. tbl_def.tbl_props.name .. "\n";
	stmt = stmt.."SET ";
	local count = 0;
	local j = 0;
	for i, col in ipairs(tbl_def.non_key_col_names) do
		if (obj[col] ~= nil) then
			j = j + 1;
			count = count + 1;
			inputs[count] = obj[col];
			if (j ~= 1) then
				stmt = stmt..", "..col .. "=?";
			else
				stmt = stmt..col .. "=?";
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
		inputs[count] = obj[col];
		if (i ~= 1) then
			stmt = stmt.." AND "..col.."=?";
		else
			stmt = stmt.." "..col.."=?";
		end
	end
	if (tbl_def.col_props.update_fields) then
		count = count + 1;
		inputs[count] = obj.version;;
		stmt = stmt.." AND version" .. "=?";
	end

	return stmt, inputs;
end

tao.update = function(self, context, obj)
	assert(context ~= nil and type(context) == 'table');
	assert(obj ~= nil and type(obj) == 'table');
	local tbl_def = self.tbl_def;
	assert_key_columns_present(context, tbl_def, obj);
	if (tbl_def.col_props.update_fields == true) then
		assert_version_column_present(context, tbl_def, obj);
	end

	local conn = self.conn;
	assert(conn ~= nil);

	local query_stmt, inputs = prepare_update_stmt(context, conn, tbl_def, obj);

	local stmt = conn:prepare(query_stmt);
	local flg, msg = stmt:vexecute(#inputs, inputs, true)
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



return tao_factory;
