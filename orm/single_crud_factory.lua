local error_handler = require("lua_schema.error_handler");
local tao_factory = require('service_utils.orm.tao_factory');
local mapper = require('service_utils.orm.mapping_util');

local messages = require('biop.registrar.literals');

local single_crud = {};
local mt = { __index = single_crud };

local crud_factory = {};

crud_factory.new = function(crud_params)
	assert(crud_params ~= nil and type(crud_params) == 'table');
	assert(crud_params.class_name ~= nil and type(crud_params.class_name) == 'string');
	assert(crud_params.msg_ns ~= nil and type(crud_params.msg_ns) == 'string');
	assert(crud_params.msg_elem_name ~= nil and type(crud_params.msg_elem_name) == 'string');
	assert(crud_params.db_name ~= nil and type(crud_params.db_name) == 'string');
	assert(crud_params.tbl_name ~= nil and type(crud_params.tbl_name) == 'string');

	local crud_obj = {};
	crud_obj = setmetatable(crud_obj, mt);
	crud_obj.class_name = crud_params.class_name;
	crud_obj.msg_ns = crud_params.msg_ns;
	crud_obj.msg_elem_name = crud_params.msg_elem_name;
	crud_obj.db_name = crud_params.db_name;
	crud_obj.tbl_name = crud_params.tbl_name;

	return crud_obj;
end

local function get_key_params(tao, obj)
	local key_params = {};
	local count = 0;
	local key_col_names = tao.tbl_def.key_col_names;
	for i, col in ipairs(key_col_names) do
		count = count + 1;
		key_params[i] = obj[col];
	end
	return key_params, count;
end

local function get_key_params_str(tao, obj)
	local key_param_str = '';
	local key_col_names = tao.tbl_def.key_col_names;
	for i, col in ipairs(key_col_names) do
		if (i == 1) then
			key_param_str = key_param_str .. col.." = " ..tostring(obj[col]);
		else
			key_param_str = key_param_str ..", ".. col .. " = " .. tostring(obj[col]);
		end
	end
	return key_param_str;
end

single_crud.fetch = function (self, context, query_params)
	local tao = tao_factory.open(context, self.db_name, self.tbl_name);

	local key_params, key_count = get_key_params(tao, query_params);

	local out, msg = tao:select(context, table.unpack(key_params));

	if (out == nil) then
		local key_param_str = get_key_params_str(tao, query_params);
		local msg = messages:format('RECORD_NOT_FOUND', key_param_str);
		error_handler.raise_error(-1, msg, debug.getinfo(1));
		return false, nil;
	end

	local obj = mapper.copy_elements(self.msg_ns, self.msg_elem_name, out);

	return true, obj;
end

single_crud.add = function (self, context, obj)
	local tao = tao_factory.open(context, self.db_name, self.tbl_name);

	if (not tao:insert(context, obj)) then
		local key_params_str = get_key_params_str(tao, obj);
		local msg = messages:format('RECORD_INSERTION_FAILED', key_params_str);
		error_handler.raise_error(-1, msg, debug.getinfo(1));
		return false, nil;
	end

	return true, nil;
end

single_crud.modify = function (self, context, obj)
	local tao = tao_factory.open(context, self.db_name, self.tbl_name);

	local flg, msg = tao:update(context, obj);
	if (not flg) then
		local key_params_str = get_key_params_str(tao, obj);
		local msg = messages:format('RECORD_NOT_FOUND', key_params_str);
		error_handler.raise_error(-1, msg, debug.getinfo(1));
		return false, nil;
	end

	return true, nil;
end

single_crud.delete = function (self, context, obj)
	local tao = tao_factory.open(context, self.db_name, self.tbl_name);

	local flg, msg;
	if (tao.tbl_def.col_props.soft_del) then
		flg, msg = tao:logdel(context, obj);
	else
		flg, msg = tao:delete(context, obj);
	end
	if (not flg) then
		local key_params_str = get_key_params_str(tao, obj);
		local msg = messages:format('RECORD_NOT_FOUND', key_params_str);
		error_handler.raise_error(-1, msg, debug.getinfo(1));
		return false, nil;
	end

	return true, nil;
end

single_crud.undelete = function (self, context, obj)
	local tao = tao_factory.open(context, self.db_name, self.tbl_name);

	if (not tao.tbl_def.col_props.soft_del) then
		error("["..tao.tbl_def.tbl_props.database_schema .. "." .. tao.tbl_def.tbl_props.name.."]:".. " does not support soft delete");
	end

	local flg, msg = tao:undelete(context, obj);
	if (not flg) then
		local key_params_str = get_key_params_str(tao, obj);
		local msg = messages:format('RECORD_NOT_FOUND', key_params_str);
		error_handler.raise_error(-1, msg, debug.getinfo(1));
		return false, nil;
	end

	return true, nil;
end

return crud_factory;

