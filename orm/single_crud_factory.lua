local error_handler = require("lua_schema.error_handler");
local tao_factory = require('service_utils.orm.tao_factory');
local mapper = require('service_utils.orm.mapping_util');

local messages = require('service_utils.literals.literals');

local single_crud = {};
local mt = { __index = single_crud };

local crud_factory = {};

local function get_db_table_name(tbl_def)
    return tbl_def.tbl_props.database_schema .. "." .. tbl_def.tbl_props.name;
end

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
        return false, nil, nil;
    end

    local obj = mapper.copy_elements(self.msg_ns, self.msg_elem_name, out);

    return true, obj, out;
end

local upd_auto_columns = function(context, tbl_def, obj, data, col_map, creation_fields)
    if (creation_fields == nil) then creation_fields = false; end
    if (tbl_def.col_props.update_fields) then
        local element_name = tao_factory.get_element_name_in_obj("version", col_map);
        if (element_name) then
            obj[element_name] = data[element_name]
        end

        element_name = tao_factory.get_element_name_in_obj("update_uid", col_map);
        if (element_name) then
            obj[element_name] = data[element_name]
        end

        element_name = tao_factory.get_element_name_in_obj("update_time", col_map);
        if (element_name) then
            obj[element_name] = data[element_name]
        end
    end

    if (creation_fields and tbl_def.col_props.creation_fields) then
        local element_name = tao_factory.get_element_name_in_obj("creation_uid", col_map);
        if (element_name) then
            obj[element_name] = data[element_name]
        end

        element_name = tao_factory.get_element_name_in_obj("creation_time", col_map);
        if (element_name) then
            obj[element_name] = data[element_name]
        end
    end

    if (tbl_def.col_props.entity_state_field == true) then
        local element_name = tao_factory.get_element_name_in_obj("entity_state", col_map);
        if (element_name) then
            obj[element_name] = data[element_name]
        end
    end

    return;
end

single_crud.add = function (self, context, obj, extra_columns)
    if (extra_columns == nil) then extra_columns = {}; end
    local tao = tao_factory.open(context, self.db_name, self.tbl_name);

    local colmap = tao_factory.get_column_map_from_obj_meta(context, tao.tbl_def, {elem = self.msg_elem_name, elem_ns = self.msg_ns});
    for n,v in pairs(extra_columns) do
        colmap[n] = n;
    end

    local upd_obj = {};
    for n,v in pairs(obj) do
        upd_obj[n] = v;
    end
    for n,v in pairs(extra_columns) do
        upd_obj[n] = v;
    end

    --local flg, msg, ret = tao:insert_using_meta(context, obj, {elem = self.msg_elem_name, elem_ns = self.msg_ns});
    local flg, msg, ret = tao:insert(context, upd_obj, colmap);
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
    local new_colmap = tao_factory.get_column_map_from_obj_meta(context, tao.tbl_def, {elem = self.msg_elem_name, elem_ns = self.msg_ns});
    upd_auto_columns(context, tao.tbl_def, obj, upd_obj, new_colmap, true);

    return true, nil, ret;
end

single_crud.addapproved = function (self, context, obj, extra_columns)
    local stat, msg, ret = self:add(context, obj, extra_columns);
    if (not stat) then
        return stat, msg, ret;
    end
    obj.entity_state = '0';
    stat, msg, ret = self:approve(context, obj, extra_columns);
    return stat, msg, ret;
end

single_crud.modify = function (self, context, obj, extra_columns)
    if (extra_columns == nil) then extra_columns = {}; end
    local tao = tao_factory.open(context, self.db_name, self.tbl_name);

    local colmap = tao_factory.get_column_map_from_obj_meta(context, tao.tbl_def, {elem = self.msg_elem_name, elem_ns = self.msg_ns});
    for n,v in pairs(extra_columns) do
        colmap[n] = n;
    end

    local upd_obj = {};
    for n,v in pairs(obj) do
        upd_obj[n] = v;
    end
    for n,v in pairs(extra_columns) do
        upd_obj[n] = v;
    end

    --local flg, msg, ret = tao:update_using_meta(context, obj, {elem = self.msg_elem_name, elem_ns = self.msg_ns});
    local flg, msg, ret = tao:update(context, upd_obj, colmap);
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
    local new_colmap = tao_factory.get_column_map_from_obj_meta(context, tao.tbl_def, {elem = self.msg_elem_name, elem_ns = self.msg_ns});
    upd_auto_columns(context, tao.tbl_def, obj, upd_obj, new_colmap);

    return true, nil, ret;
end

single_crud.phydel = function (self, context, obj, extra_columns)
    if (extra_columns == nil) then
        extra_columns = {};
    end
    local tao = tao_factory.open(context, self.db_name, self.tbl_name);

    local colmap = tao_factory.get_column_map_from_obj_meta(context, tao.tbl_def, {elem = self.msg_elem_name, elem_ns = self.msg_ns});
    for n,v in pairs(extra_columns) do
        colmap[n] = n;
    end

    local upd_obj = {};
    for n,v in pairs(obj) do
        upd_obj[n] = v;
    end
    for n,v in pairs(extra_columns) do
        upd_obj[n] = v;
    end

    local flg, msg, ret = tao:delete(context, upd_obj);
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

    local new_colmap = tao_factory.get_column_map_from_obj_meta(context, tao.tbl_def, {elem = self.msg_elem_name, elem_ns = self.msg_ns});
    upd_auto_columns(context, tao.tbl_def, obj, upd_obj, new_colmap);

    return true, nil, ret;
end

single_crud.logdel = function (self, context, obj, extra_columns)
    if (extra_columns == nil) then
        extra_columns = {};
    end
    local tao = tao_factory.open(context, self.db_name, self.tbl_name);

    local colmap = tao_factory.get_column_map_from_obj_meta(context, tao.tbl_def, {elem = self.msg_elem_name, elem_ns = self.msg_ns});
    for n,v in pairs(extra_columns) do
        colmap[n] = n;
    end

    local upd_obj = {};
    for n,v in pairs(obj) do
        upd_obj[n] = v;
    end
    for n,v in pairs(extra_columns) do
        upd_obj[n] = v;
    end

    local flg, msg, ret = tao:logdel(context, upd_obj);
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

    local new_colmap = tao_factory.get_column_map_from_obj_meta(context, tao.tbl_def, {elem = self.msg_elem_name, elem_ns = self.msg_ns});
    upd_auto_columns(context, tao.tbl_def, obj, upd_obj, new_colmap);

    return true, nil, ret;
end

single_crud.delete = function (self, context, obj, extra_columns)
    local tao = tao_factory.open(context, self.db_name, self.tbl_name);
    if (tao.tbl_def.col_props.soft_del) then
        return self:logdel(context, obj, extra_columns)
    else
        return self:phydel(context, obj, extra_columns)
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

single_crud.cancel_amendment = function (self, context, obj, extra_columns)
    if (extra_columns == nil) then extra_columns = {}; end
    local tao = tao_factory.open(context, self.db_name, self.tbl_name);
    assert(tao.tbl_def.col_props.entity_state_field == true);

    local key_params, key_count = get_key_params(tao, obj);
    local out, msg = tao:select(context, table.unpack(key_params));
    if (out == nil) then
        local key_param_str = get_key_params_str(tao, obj);
        local msg = messages:format('RECORD_NOT_FOUND', key_param_str);
        error_handler.raise_error(404, msg);
        return false, nil;
    end

    if (out.entity_state ~= '2') then
        local key_params_str = get_key_params_str(tao, obj);
        local msg = messages:format('INVALID_OPERATION', key_params_str);
        error_handler.raise_error(400, msg);
        return false, msg, -1;
    end

    local colmap = tao_factory.get_column_map_from_obj_meta(context, tao.tbl_def, {elem = self.msg_elem_name, elem_ns = self.msg_ns});
    for n,v in pairs(extra_columns) do
        colmap[n] = n;
    end

    out.entity_state = '1';
    if (obj.entity_state ~= nil) then
        obj.entity_state = '1';
    end

    local upd_obj = {};
    for n,v in pairs(out) do
        upd_obj[n] = v;
    end
    for n,v in pairs(extra_columns) do
        upd_obj[n] = v;
    end

    --local flg, msg, ret = tao:update_using_meta(context, obj, {elem = self.msg_elem_name, elem_ns = self.msg_ns}, columns);
    local flg, msg, ret = tao:update(context, upd_obj, colmap);
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

    local new_colmap = tao_factory.get_column_map_from_obj_meta(context, tao.tbl_def, {elem = self.msg_elem_name, elem_ns = self.msg_ns});
    upd_auto_columns(context, tao.tbl_def, obj, upd_obj, new_colmap);

    return true, nil, 0;
end

single_crud.approve = function (self, context, obj, extra_columns)
    if (extra_columns == nil) then extra_columns = {}; end
    local tao = tao_factory.open(context, self.db_name, self.tbl_name);
    assert(tao.tbl_def.col_props.entity_state_field == true);
    assert(obj.entity_state ~= nil)

    local colmap = tao_factory.get_column_map_from_obj_meta(context, tao.tbl_def, {elem = self.msg_elem_name, elem_ns = self.msg_ns});
    for n,v in pairs(extra_columns) do
        colmap[n] = n;
    end

    local key_params, key_count = get_key_params(tao, obj);
    local out, msg = tao:select(context, table.unpack(key_params));
    if (out == nil) then
        local key_param_str = get_key_params_str(tao, obj);
        local msg = messages:format('RECORD_NOT_FOUND', key_param_str);
        error_handler.raise_error(404, msg);
        return false, nil;
    end

    if (out.entity_state ~= '0' and out.entity_state ~= '2') then
        local key_params_str = get_key_params_str(tao, obj);
        local msg = messages:format('INVALID_OPERATION', key_params_str);
        error_handler.raise_error(400, msg);
        return false, msg, -1;
    end

    if (out.entity_state == '2') then
        if (out.version) then
            obj[colmap.version] = out.version;
        end
    end

    obj.entity_state = '1';

    local upd_obj = {};
    for n,v in pairs(out) do
        upd_obj[n] = v;
    end
    for n,v in pairs(obj) do
        upd_obj[n] = v;
    end
    for n,v in pairs(extra_columns) do
        upd_obj[n] = v;
    end

    --local flg, msg, ret = tao:update_using_meta(context, obj, {elem = self.msg_elem_name, elem_ns = self.msg_ns});
    local flg, msg, ret = tao:update(context, upd_obj, colmap);
    if (not flg) then
        if (ret == 0) then
            local key_params_str = get_key_params_str(tao, obj);
            local msg = messages:format('RECORD_NOT_FOUND', key_params_str);
            error_handler.raise_error(404, msg);
            return false, msg, ret;
        else
            print(debug.getinfo(1).source, debug.getinfo(1).currentline);
            require 'pl.pretty'.dump(upd_obj);
            require 'pl.pretty'.dump(colmap);
            print(debug.getinfo(1).source, debug.getinfo(1).currentline);
            error_handler.raise_error(500, msg);
            return false, msg, ret;
        end
    end

    local new_colmap = tao_factory.get_column_map_from_obj_meta(context, tao.tbl_def, {elem = self.msg_elem_name, elem_ns = self.msg_ns});
    upd_auto_columns(context, tao.tbl_def, obj, upd_obj, new_colmap);

    return true, nil, 0;
end

single_crud.dependent_action = function (self, context, obj, options, extra_columns)
    if (options == nil) then options = {}; end
    local tao = tao_factory.open(context, self.db_name, self.tbl_name);

    local vercol = 'version';
    local delcol = "deleted";
    local colmap = tao_factory.get_column_map_from_obj_meta(context, tao.tbl_def, {elem = self.msg_elem_name, elem_ns = self.msg_ns});
    if (colmap.version ~= nil) then vercol = colmap.version; end
    if (colmap.deleted ~= nil) then delcol = colmap.deleted; end

    local action = 'NO_ACTION';
    if (obj[vercol] == nil) then
        if (obj[delcol] ~= true) then
            action = 'INSERT';
            if (tao.tbl_def.col_props.update_fields == false) then
                action = 'UPSERT'
            end
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
            return false, nil, nil;
        end

        if (out.version) then
            obj[vercol] = out.version;
        end
    end

    if (action == 'INSERT') then
        return self:add(context, obj, extra_columns);
    elseif (action == 'UPDATE') then
        return self:modify(context, obj, extra_columns);
    elseif (action == 'DELETE') then
        if (options.physical_delete == true) then
            return self:phydel(context, obj, extra_columns);
        else
            return self:delete(context, obj, extra_columns);
        end
    elseif (action == 'UPSERT') then
        local key_params, key_count = get_key_params(tao, obj);
        local out, msg = tao:select(context, table.unpack(key_params));
        if (out ~= nil) then
            local stat, msg, ret = self:phydel(context, obj, extra_columns);
            assert(stat, msg);
        end
        return self:add(context, obj, extra_columns);
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
        return false, nil, nil;
    end

    -- remove creation_uid, creation_time, update_uid, update_time from the table
    if out ~= nil and out.creation_uid ~= nil then out.creation_uid = nil end
    if out ~= nil and out.creation_time ~= nil then out.creation_time = nil end
    if out ~= nil and out.update_uid ~= nil then out.update_uid = nil end
    if out ~= nil and out.update_time ~= nil then out.update_time = nil end

    local obj = mapper.copy_elements(self.msg_ns, self.msg_elem_name, out);

    return true, obj, ret;
end

single_crud.initiate_amendment = function (self, context, obj, extra_columns)
    if (extra_columns == nil) then extra_columns = {}; end
    local tao = tao_factory.open(context, self.db_name, self.tbl_name);
    assert(tao.tbl_def.col_props.entity_state_field == true);

    local key_params, key_count = get_key_params(tao, obj);
    local out, msg = tao:select(context, table.unpack(key_params));
    if (out == nil or out.version ~= obj.version) then
        local key_param_str = get_key_params_str(tao, obj);
        local msg = messages:format('RECORD_NOT_FOUND', key_param_str);
        error_handler.raise_error(404, msg);
        return false, nil, nil;
    end

    if (out.entity_state ~= '1' and out.entity_state ~= '2') then
        local key_params_str = get_key_params_str(tao, obj);
        local msg = messages:format('INVALID_OPERATION', key_params_str);
        error_handler.raise_error(400, msg);
        return false, msg, -1;
    end

    local colmap = tao_factory.get_column_map_from_obj_meta(context, tao.tbl_def, {elem = self.msg_elem_name, elem_ns = self.msg_ns});
    for n,v in pairs(extra_columns) do
        colmap[n] = n;
    end

    out.entity_state = '2';
    if (obj.entity_state ~= nil) then
        obj.entity_state = '2';
    end

    local upd_obj = {};
    for n,v in pairs(out) do
        upd_obj[n] = v;
    end
    for n,v in pairs(extra_columns) do
        upd_obj[n] = v;
    end

    --local flg, msg, ret = tao:update_using_meta(context, obj, {elem = self.msg_elem_name, elem_ns = self.msg_ns}, columns);
    local flg, msg, ret = tao:update(context, upd_obj, colmap);
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

    local new_colmap = tao_factory.get_column_map_from_obj_meta(context, tao.tbl_def, {elem = self.msg_elem_name, elem_ns = self.msg_ns});
    upd_auto_columns(context, tao.tbl_def, obj, upd_obj, new_colmap);

    return true, nil, ret;
end


return crud_factory;

