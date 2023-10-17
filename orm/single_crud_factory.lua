local error_handler = require("lua_schema.error_handler");
local tao_factory = require('service_utils.orm.tao_factory');
local mapper = require('service_utils.orm.mapping_util');

local messages = require('service_utils.literals.literals');

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

single_crud.prepare_mod_key = function (self, context, entity_name, obj)
	assert(type(entity_name) == 'string', "Invalid entity_name");
	local key_obj = {};
	key_obj.entity_name = entity_name;
	key_obj.entity_key = tao_factory:prepare_mod_key(context, self.db_name, self.tbl_name, obj);

	return key_obj;
end

single_crud.fetch = function (self, context, query_params)
	local tao = tao_factory.open(context, self.db_name, self.tbl_name);

	local key_params, key_count = get_key_params(tao, query_params);

	local out, msg = tao:select(context, table.unpack(key_params));

	if (out == nil) then
		local key_param_str = get_key_params_str(tao, query_params);
		local msg = messages:format('RECORD_NOT_FOUND', key_param_str);
		error_handler.raise_error(404, msg);
		return false, nil;
	end

	local obj = mapper.copy_elements(self.msg_ns, self.msg_elem_name, out);

	return true, obj;
end

single_crud.add = function (self, context, obj)
	local tao = tao_factory.open(context, self.db_name, self.tbl_name);

	local flg, msg, ret = tao:insert_using_meta(context, obj, {elem = self.msg_elem_name, elem_ns = self.msg_ns});
	if (not flg) then
		if (ret == -1) then
			local key_params_str = get_key_params_str(tao, obj);
			local msg = messages:format('DUPLICATE_RECORD_FOUND', key_params_str);
			error_handler.raise_error(409, msg);
			return false, msg, ret;
		else
			error_handler.raise_error(500, msg);
			return false, msg, ret;
		end
	end

	return true, nil, ret;
end

single_crud.modify = function (self, context, obj)
	local tao = tao_factory.open(context, self.db_name, self.tbl_name);

	local flg, msg, ret = tao:update_using_meta(context, obj, {elem = self.msg_elem_name, elem_ns = self.msg_ns});
	if (not flg) then
		if (ret == 0) then
			local key_params_str = get_key_params_str(tao, obj);
			local msg = messages:format('RECORD_NOT_FOUND', key_params_str);
			error_handler.raise_error(404, msg);
			return false, msg, ret;
		else
			error_handler.raise_error(500, msg);
			return false, msg, ret;
		end
	end

	return true, nil, ret;
end

single_crud.phydel = function (self, context, obj)
	local tao = tao_factory.open(context, self.db_name, self.tbl_name);

	local flg, msg, ret = tao:delete(context, obj);
	if (not flg) then
		if (ret == 0) then
			local key_params_str = get_key_params_str(tao, obj);
			local msg = messages:format('RECORD_NOT_FOUND', key_params_str);
			error_handler.raise_error(404, msg);
			return false, msg, ret;
		else
			error_handler.raise_error(500, msg);
			return false, msg, ret;
		end
	end

	return true, nil, ret;
end

single_crud.logdel = function (self, context, obj)
	local tao = tao_factory.open(context, self.db_name, self.tbl_name);

	local flg, msg, ret = tao:logdel(context, obj);
	if (not flg) then
		if (ret == 0) then
			local key_params_str = get_key_params_str(tao, obj);
			local msg = messages:format('RECORD_NOT_FOUND', key_params_str);
			error_handler.raise_error(404, msg);
			return false, msg, ret;
		else
			error_handler.raise_error(500, msg);
			return false, msg, ret;
		end
	end

	return true, nil, ret;
end

single_crud.delete = function (self, context, obj)
	local tao = tao_factory.open(context, self.db_name, self.tbl_name);
	if (tao.tbl_def.col_props.soft_del) then
		return self:logdel(context, obj)
	else
		return self:phydel(context, obj)
	end
end

single_crud.undelete = function (self, context, obj)
	local tao = tao_factory.open(context, self.db_name, self.tbl_name);

	if (not tao.tbl_def.col_props.soft_del) then
		error("["..tao.tbl_def.tbl_props.database_schema .. "." .. tao.tbl_def.tbl_props.name.."]:".. " does not support soft delete");
	end

	local flg, msg, ret = tao:undelete(context, obj);
	if (not flg) then
		if (ret == 0) then
			local key_params_str = get_key_params_str(tao, obj);
			local msg = messages:format('RECORD_NOT_FOUND', key_params_str);
			error_handler.raise_error(404, msg);
			return false, msg, ret;
		else
			error_handler.raise_error(500, msg);
			return false, msg, ret;
		end
	end

	return true, nil, ret;
end
single_crud.cancel_amendment = function (self, context, obj, columns)
	if (columns == nil) then columns = {}; end
	local tao = tao_factory.open(context, self.db_name, self.tbl_name);
	assert(obj.entity_state ~= nil)

	if (obj.entity_state ~= '2') then
		local key_params_str = get_key_params_str(tao, obj);
		local msg = messages:format('INVALID_OPERATION', key_params_str);
		error_handler.raise_error(400, msg);
		return false, msg, -1;
	end

	obj.entity_state = '1';
	local flg, msg, ret = tao:update_using_meta(context, obj, {elem = self.msg_elem_name, elem_ns = self.msg_ns}, columns);

	if (not flg) then
		if (ret == 0) then
			local key_params_str = get_key_params_str(tao, obj);
			local msg = messages:format('RECORD_NOT_FOUND', key_params_str);
			error_handler.raise_error(404, msg);
			return false, msg, ret;
		else
			error_handler.raise_error(500, msg);
			return false, msg, ret;
		end
	end
	return true, nil, 0;
end


single_crud.approve = function (self, context, obj)
	local tao = tao_factory.open(context, self.db_name, self.tbl_name);
	assert(obj.entity_state ~= nil)

	if (obj.entity_state ~= '0' and obj.entity_state ~= '2') then
		local key_params_str = get_key_params_str(tao, obj);
		local msg = messages:format('INVALID_OPERATION', key_params_str);
		error_handler.raise_error(400, msg);
		return false, msg, -1;
	end

	if (obj.entity_state == '2') then
		local key_params, key_count = get_key_params(tao, obj);
		local out, msg = tao:select(context, table.unpack(key_params));
		if (out == nil) then
			local key_param_str = get_key_params_str(tao, obj);
			local msg = messages:format('RECORD_NOT_FOUND', key_param_str);
			error_handler.raise_error(404, msg);
			return false, nil;
		end

		local colmap = tao_factory.get_column_map_from_obj_meta(context, tao.tbl_def, {elem = self.msg_elem_name, elem_ns = self.msg_ns});
		if (out.version) then
			obj[colmap.version] = out.version;
		end
	end
	obj.entity_state = '1';
	local flg, msg, ret = tao:update_using_meta(context, obj, {elem = self.msg_elem_name, elem_ns = self.msg_ns});

	if (not flg) then
		if (ret == 0) then
			local key_params_str = get_key_params_str(tao, obj);
			local msg = messages:format('RECORD_NOT_FOUND', key_params_str);
			error_handler.raise_error(404, msg);
			return false, msg, ret;
		else
			error_handler.raise_error(500, msg);
			return false, msg, ret;
		end
	end
	return true, nil, 0;
end

single_crud.dependent_action = function (self, context, obj, default_action)
	if (default_action == nil) then default_action = 'NO_ACTION'; end
	assert(type(default_action) == 'string');
	local tao = tao_factory.open(context, self.db_name, self.tbl_name);

	local vercol = 'version';
	local delcol = "deleted";
	local colmap = tao_factory.get_column_map_from_obj_meta(context, tao.tbl_def, {elem = self.msg_elem_name, elem_ns = self.msg_ns});
	if (colmap.version ~= nil) then vercol = colmap.version; end
	if (colmap.deleted ~= nil) then delcol = colmap.deleted; end

	local action = default_action;
	if (obj[vercol] == nil) then
		if (obj[delcol] ~= true) then
			action = 'INSERT';
		end
	else
		action = 'UPDATE';
		if (obj[delcol]) then
			action = 'DELETE';
		end
	end

	if (action == 'UPDATE' or action == 'DELETE') then
		local key_params, key_count = get_key_params(tao, obj);
		local out, msg = tao:select(context, table.unpack(key_params));
		if (out == nil) then
			local key_param_str = get_key_params_str(tao, obj);
			local msg = messages:format('RECORD_NOT_FOUND', key_param_str);
			error_handler.raise_error(404, msg);
			return false, nil;
		end

		if (out.version) then
			obj[vercol] = out.version;
		end
	end

	if (action == 'INSERT') then
		return self:add(context, obj);
	elseif (action == 'UPDATE') then
		return self:modify(context, obj);
	elseif (action == 'DELETE') then
		return self:delete(context, obj);
	else
		assert(action == 'NO_ACTION', "SOMETHING HAS GONE WRONG");
	end

	return true, nil, 0;
end


single_crud.approve_and_select = function (self, context, obj)
	local approve_flg, error_msg, ret = single_crud.approve(self, context, obj);
	local tao = tao_factory.open(context, self.db_name, self.tbl_name);

	if not approve_flg then
		return approve_flg, error_msg, ret;
	end

	local key_params, key_count = get_key_params(tao, obj);
	local out, msg = tao:select(context, table.unpack(key_params));

	if (out == nil) then
		local key_param_str = get_key_params_str(tao, obj);
		local msg = messages:format('RECORD_NOT_FOUND', key_param_str);
		error_handler.raise_error(404, msg);
		return false, nil;
	end

	-- remove creation_uid, creation_time, update_uid, update_time from the table
	if out ~= nil and out.creation_uid ~= nil then out.creation_uid = nil end
	if out ~= nil and out.creation_time ~= nil then out.creation_time = nil end
	if out ~= nil and out.update_uid ~= nil then out.update_uid = nil end
	if out ~= nil and out.update_time ~= nil then out.update_time = nil end

	local obj = mapper.copy_elements(self.msg_ns, self.msg_elem_name, out);

	return true, obj, ret;
end

single_crud.initiate_amendement = function (self, context, obj, columns)
	if (columns == nil) then columns = {}; end
	local tao = tao_factory.open(context, self.db_name, self.tbl_name);
	assert(obj.entity_state ~= nil)

	if (obj.entity_state ~= '1' and obj.entity_state ~= '2') then
		local key_params_str = get_key_params_str(tao, obj);
		local msg = messages:format('INVALID_OPERATION', key_params_str);
		error_handler.raise_error(400, msg);
		return false, msg, -1;
	end

	obj.entity_state = '2';
	local flg, msg, ret = tao:update_using_meta(context, obj, {elem = self.msg_elem_name, elem_ns = self.msg_ns}, columns);
	if (not flg) then
		if (ret == 0) then
			local key_params_str = get_key_params_str(tao, obj);
			local msg = messages:format('RECORD_NOT_FOUND', key_params_str);
			error_handler.raise_error(404, msg);
			return false, msg, ret;
		else
			error_handler.raise_error(500, msg);
			return false, msg, ret;
		end
	end

	return true, nil, ret;
end


return crud_factory;

