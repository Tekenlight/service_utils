local ffi = require("ffi")
local serde = require("service_utils.common.primitive_serde");
local cjson = require("cjson.safe");
local issue_savepoint_sql = [[SAVEPOINT ADT_TRANSACTION_SAVEPOINT]]
local rollback_savepoint_sql = [[ROLLBACK TO SAVEPOINT ADT_TRANSACTION_SAVEPOINT]]

local transaction = {}

local function current_timestamp()
    local date_utils = require("lua_schema.date_utils");
    local time = date_utils.now(false);
    local dto_time, tzo = date_utils.date_obj_from_dtt(time);
    return dto_time:fmt('%Y%m%d%H%M%S%e');
end

local function add_zeros(id, length)
    id = string.rep('0', length-#(string.format("%d", id)))..id
    return id
end

local function prepare_audit_data(context, i, transaction_number, name)
    local tables_to_be_ignored = { "BIOP_AUDIT", "BIOP_REFRESH", "BIOP_SUBSCRIBER_REFRESH" };
    local audit_entry_required = true;

    local raw_data = context.dml_ops[name].changes[i];
    local table_name = raw_data.table_name;

    for n,tn in pairs(tables_to_be_ignored) do
        if table_name == tn then
            audit_entry_required = false;
        end
    end

    if audit_entry_required then
        local biop_audit = {}
        biop_audit["transaction_number"] = transaction_number;
        biop_audit["serial_no"] = ffi.cast("int32_t", i);
        biop_audit["table_name"] = table_name;
        biop_audit["action"] = tostring(raw_data.table_ops);

        local data = {};
        for n,v in pairs(raw_data.data) do
            local ser = serde.serialize(v);
            data[n] = ser;
        end
        biop_audit["data"] = cjson.encode(data);

        local keys = {};
        if raw_data.keys ~= nil then
            for n,v in pairs(raw_data.keys) do
                local ser = serde.serialize(v);
                keys[n] = ser;
            end
        end
        biop_audit["table_key"] = cjson.encode(keys);

        print("=================================== audit  data ===================================");
        require 'pl.pretty'.dump(biop_audit);
        print("===================================================================================");
        return biop_audit;
    end

    return nil;
end

local function insert_data(conn, stmt, count, inputs)
    if (conn:get_in_transaction()) then conn:prepare(issue_savepoint_sql):execute(); end
	local flg, msg = stmt:vexecute(count, inputs, true)
	if (not flg) then
		if (conn:get_in_transaction()) then
			conn:prepare(rollback_savepoint_sql):execute();
			conn:reset_connection_error();
		end
		local ret = 0;
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

	return true, msg, ret;
end

local function audit_insert (context, data, name, table_name)
	assert(context ~= nil and type(context) == 'table');
	assert(data ~= nil and type(data) == 'table');

    local conn = context:get_connection(name);
	assert(conn ~= nil);

	local tbl_def_class_name = context.module_path..".tbl."..table_name;
	local tbl_def = require(tbl_def_class_name);

	local stmt = conn:prepare(tbl_def.insert_stmt);
	local now = conn:get_systimestamp();

	local inputs = {};
	local auto_columns = {};
	if (tbl_def.col_props.creation_fields == true) then
		auto_columns.creation_uid = context.uid
		auto_columns.creation_time = now;
	end

	local count = 0;
	for i, col in ipairs(tbl_def.declared_col_names) do
		count = count + 1;
		inputs[count] = data[col];
	end

	for i, col in ipairs(tbl_def.auto_col_names) do
		count = count + 1;
		inputs[count] = auto_columns[col];
	end

    return insert_data(conn, stmt, count, inputs);

end

local function add_refresh_entity(context, transaction_number, org_id, is_subscriber)
    assert(context ~= nil and type(context) == 'table');
    assert(transaction_number ~= nil and type(transaction_number) == 'string');

    local table_name = "biop_subscriber_refresh";
    if (org_id == nil) then
        table_name = "biop_refresh";
    end

    local tbl_def_class_name = context.module_path..".tbl."..table_name;
	local tbl_def = require(tbl_def_class_name);

	local conn = context:get_connection("REGISTRAR");
	assert(conn ~= nil);

	local stmt = conn:prepare(tbl_def.insert_stmt);

    if (org_id == nil) then
        -- generic insert
        local inputs = {};
        inputs[1] = transaction_number;
        return insert_data(conn, stmt, 1, inputs);
    else
        print("Adding subscriber daata");
        -- query over biop_companies and get the list of org_id for which data entry is to be created.
        local sel_stmt = conn:prepare([[SELECT parent_org_id FROM BIOP_ADMIN.BIOP_PARTNERS
                                WHERE deleted = false
                                and org_id = ?]]);
        
        require 'pl.pretty'.dump(sel_stmt);
        sel_stmt:execute(org_id);
        
        local result = sel_stmt:fetch_result();
        require 'pl.pretty'.dump(result);
        if (result ~= nil) then
            for i = 1, #result, 1 do
                local parent_org_id = result[i]["parent_org_id"];
                local inputs = {};
                inputs[1] = parent_org_id;
                inputs[2] = transaction_number;
                local flg, msg, ret = insert_data(conn, stmt, 2, inputs);
                if ~flg then
                    return flg, msg, ret;
                end
            end
        end
        if (is_subscriber) then
            local inputs = {};
            inputs[1] = org_id;
            inputs[2] = transaction_number;
            return insert_data(conn, stmt, 2, inputs);         
        end
        return true, nil, nil
    end

end

transaction.enable_org_refresh = function (context, name, org_id, is_subscriber)
    assert(context.dml_ops[name] ~= nil and type(context.dml_ops[name]) == 'table');
    assert(context.dml_ops[name].enable_audit == true);
    assert(context.dml_ops[name].generic_refresh == false);
    assert(org_id ~= nil);
    context.dml_ops[name].org_refresh = true;
    context.dml_ops[name].refresh_org_id = org_id;
    context.dml_ops[name].org_id_is_subscriber = is_subscriber;
end

transaction.enable_generic_refresh = function (context, name)
    assert(context.dml_ops[name] ~= nil and type(context.dml_ops[name]) == 'table');
    assert(context.dml_ops[name].enable_audit == true);
    assert(context.dml_ops[name].org_refresh == false);
    assert(context.dml_ops[name].org_id_is_subscriber == false);
    assert(context.dml_ops[name].refresh_org_id == "");
    context.dml_ops[name].generic_refresh = true;
end

transaction.enable_audit = function (context, name)
    assert(context ~= nil and type(context) == 'table');
	assert(name ~= nil and type(name) == 'string');
    if (context.dml_ops == nil) then
        context.dml_ops = {};
    end
    if context.dml_ops[name] == nil then
        context.dml_ops[name] = {};
    end
    context.dml_ops[name].enable_audit = true;
    context.dml_ops[name].org_refresh = false;
    context.dml_ops[name].generic_refresh = false;
    context.dml_ops[name].org_id_is_subscriber = false;
    context.dml_ops[name].refresh_org_id = "";
end

transaction.begin_transaction = function(context, name)
    -- TODO For testing purpose, writing this code
        -- transaction.enable_audit(context, name);
        -- transaction.enable_org_refresh(context, name, "0000000001", true);
        -- if name ~= "REGISTRAR" then
        --     context.dml_ops[name].enable_audit = false;
        -- end
    -- TODO remove the code within the upper limit


    assert(context.dml_ops[name] ~= nil and type(context.dml_ops[name]) == 'table');
    assert(context.dml_ops[name].enable_audit ~= nil and type(context.dml_ops[name].enable_audit) == 'boolean');
    assert(context.dml_ops[name].org_refresh ~= nil and type(context.dml_ops[name].org_refresh) == 'boolean');
    assert(context.dml_ops[name].generic_refresh ~= nil and type(context.dml_ops[name].generic_refresh) == 'boolean');
    assert(context.dml_ops[name].refresh_org_id ~= nil and type(context.dml_ops[name].refresh_org_id) == 'string');
    assert(context.dml_ops[name].org_id_is_subscriber ~= nil and type(context.dml_ops[name].org_id_is_subscriber) == 'boolean');
    context.dml_ops[name].changes = {};
    context.db_connections[name].conn:begin();
end

transaction.commit_transaction = function(context, name, conn)
    print("===================================================================================");
    print("============================== Comitting transaction ==============================");
    require 'pl.pretty'.dump(context.dml_ops);
    require 'pl.pretty'.dump(name);
    if (name == nil) then
        name = "REGISTRAR";
        print("name found to be nil, defaulting it to "..name);
    end

    local count = 1;
    local transaction_number = current_timestamp().."."..add_zeros(count, 10);

    print("===================================================================================");
    print("=============================== transaction  number ===============================");
    print(transaction_number);
    print("===================================================================================");    
    if (context.dml_ops[name] ~= nil and context.dml_ops[name].enable_audit) then
        for i=1, #context.dml_ops[name].changes, 1
        do
            local biop_audit = prepare_audit_data(context, i, transaction_number, name);
            local ret, flg, msg=0, false, "";
            if biop_audit ~= nil then
                repeat
                    flg, msg, ret = audit_insert(context, biop_audit, name, "BIOP_AUDIT");

                    if (flg == false and nil ~= string.match(msg, 'duplicate key value violates unique constraint')) then
                        ret = -1
                        print("=============================== transaction  number ===============================");
                        print(transaction_number);
                        print("===================================================================================");    
                        count = count + 1;
                        transaction_number = current_timestamp().."."..add_zeros(count, 10);
                        biop_audit = prepare_audit_data(context, i, transaction_number, name);
                    end
                    if (ret ~= 1 and ret ~= -1) then
                        return false, "SOMETHING TERRIBLE HAS HAPPENED", ret;
                    end
                until (ret == 1);

                -- once data is inserted if the table is subscriber specific, fetch the sub ids that needs to be updated and create entry in subscriber_refresh
                -- if generic add data to generic table
                if context.dml_ops[name].org_refresh then
                    add_refresh_entity(context, transaction_number, context.dml_ops[name].refresh_org_id, context.dml_ops[name].org_id_is_subscriber);
                elseif context.dml_ops[name].generic_refresh then
                    add_refresh_entity(context, transaction_number, nil, false);
                end
            end
        end
    end
    if nil == conn then
        context.db_connections[name].conn:commit();
    else
        pcall(conn.commit, conn);
    end
    context.dml_ops = {}
end

transaction.rollback_transaction = function(context, name, conn)
    if nil == conn then
        context.db_connections[name].conn:rollback();
    else
        pcall(conn.rollback, conn);
    end
    context.dml_ops = {};
end

transaction.append_to_ops_list = function(context, table_name, operation, data, key_columns, name)
    -- table_ops = {
	--	0: Insert
	--	1: Update
	--	2: Delete
	--  3: logdel
	--  4: undelete
	-- }
	assert(table_name ~= nil and type(table_name) == 'string');
	assert(operation ~= nil and type(operation) == 'number');
	assert(data ~= nil and type(data) == 'table');
    assert(type(name) == 'string')

    local new_index = #(context.dml_ops[name].changes) + 1;

	context.dml_ops[name].changes[new_index] = {};
	context.dml_ops[name].changes[new_index].table_name = table_name;
	context.dml_ops[name].changes[new_index].table_ops = operation;
	context.dml_ops[name].changes[new_index].data = data;
    context.dml_ops[name].changes[new_index].keys = key_columns;

end

return transaction
