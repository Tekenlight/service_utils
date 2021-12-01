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
	local obj = {};
	obj = setmetatable(obj, mt);
	print(debug.getinfo(1).source, debug.getinfo(1).currentline, tao.select, obj.select);
	obj.conn = context.db_connections[schema_name].conn;
	assert(obj.conn ~= nil);
	obj.tbl_def = tbl_def;
	return obj;
end

tao.select = function(self, context, ...)
	assert(context ~= nil and type(context) == 'table');
	local tbl_def = self.tbl_def;

	local conn = self.conn;
	assert(conn ~= nil);

	local stmt = conn:prepare(tbl_def.select_stmt);
	stmt:execute(table.unpack({...}));
	local result = stmt:fetch_result();
	if (result == nil) then
		return nil;
	end

	local out = stmt.map(result, tbl_def.selected_col_names);
	return out;
end

tao.update = function(self, context, obj)
	assert(context ~= nil and type(context) == 'table');
	assert(obj ~= nil and type(obj) == 'table');
	local tbl_def = self.tbl_def;

	local stmt = tbl_def.update_stmt;
	local conn = self.conn;
	assert(conn ~= nil);
end

tao.insert = function(self, context, obj)
	assert(context ~= nil and type(context) == 'table');
	assert(obj ~= nil and type(obj) == 'table');
	local tbl_def = self.tbl_def;

	local stmt = tbl_def.insert_stmt;
	local conn = self.conn;
	assert(conn ~= nil);
end

tao.delete = function(self, context, obj)
	assert(context ~= nil and type(context) == 'table');
	assert(obj ~= nil and type(obj) == 'table');
	local tbl_def = self.tbl_def;

	local stmt = tbl_def.delete_stmt;
	local conn = self.conn;
	assert(conn ~= nil);
end

tao.logdel = function(self, context, obj)
	assert(context ~= nil and type(context) == 'table');
	assert(obj ~= nil and type(obj) == 'table');
	local tbl_def = self.tbl_def;
	assert(tbl_def ~= nil and tbl_def.col_props.soft_del == true);

	local stmt = tbl_def.logdel_stmt;
	local conn = self.conn;
	assert(conn ~= nil);
end

tao.undelete = function(self, context, obj)
	assert(context ~= nil and type(context) == 'table');
	assert(obj ~= nil and type(obj) == 'table');
	local tbl_def = self.tbl_def;
	assert(tbl_def ~= nil and tbl_def.col_props.soft_del == true);

	local stmt = tbl_def.undelete_stmt;
	local conn = self.conn;
	assert(conn ~= nil);
end



return tao_factory;
