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

local function prepare_audit_data(context, i, index, name)
    -- assert(context.dml_ops ~= nil);
    -- assert(context.dml_ops[i].table_name ~= nil and type(context.dml_ops[i].table_name) == "string");

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
        biop_audit["transaction_number"] = current_timestamp().."."..index;
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

        print("==================================================================================");
        print(debug.getinfo(1).source, debug.getinfo(1).currentline);
        require 'pl.pretty'.dump(biop_audit);
        print(debug.getinfo(1).source, debug.getinfo(1).currentline);
        print("==================================================================================");

        return biop_audit;
    end

    return nil;
end

-- self, context, data
-- self will contain the db name and tbl def
-- context will contain the data
-- data will contain the actual data to be stored
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

transaction.begin_transaction = function(context, name)
    context.dml_ops = {};
    context.dml_ops[name] = {};
    -- TODO remove this piece after testing and set the default flag to false.
    if (name == "REGISTRAR") then
        context.dml_ops[name].enable_audit = true;
    else
        context.dml_ops[name].enable_audit = false;
    end
    -- context.dml_ops[name].enable_audit = false;
    context.dml_ops[name].changes = {};
    context.db_connections[name].conn:begin();
end

transaction.commit_transaction = function(context, name, conn)
    print("==================================================================================");
    print(debug.getinfo(1).source, debug.getinfo(1).currentline, "Comitting transaction for "..name);
    require 'pl.pretty'.dump(context.dml_ops);
    if (name == nil) then
        name = "REGISTRAR";
        print(debug.getinfo(1).source, debug.getinfo(1).currentline, "name found to be nil, defaulting it to "..name);
    end
    print("==================================================================================");
    
    if (context.dml_ops[name] ~= nil and context.dml_ops[name].enable_audit) then
        print("==================================================================================");
        print(debug.getinfo(1).source, debug.getinfo(1).currentline, "Creating audit entries for "..name);
        require 'pl.pretty'.dump(context.dml_ops[name]);
        print("==================================================================================");
        for i=1, #context.dml_ops[name].changes, 1
        do
            local count = 1;
            local biop_audit = prepare_audit_data(context, i, add_zeros(count, 10), name);
            local ret, flg, msg=0, false, "";
            if biop_audit ~= nil then
                repeat
                    flg, msg, ret = audit_insert(context, biop_audit, name, "BIOP_AUDIT");
                    
                    if (flg == false and nil ~= string.match(msg, 'duplicate key value violates unique constraint')) then
                        ret = -1
                    end
                    if (ret ~= 1 and ret ~= -1) then
                        return false, "SOMETHING TERRIBLE HAS HAPPENED", ret;
                    end
                    count = count + 1;
                until (ret == 1);
            end
            -- create a table which is equivalent of audit table in ROC
            -- create instance of single crud
            -- invoke single crud add
            -- once data is inserted if the table is subscriber specific, fetch the sub ids that needs to be updated and create entry in subscriber_refresh
            -- if generic add data to generic table
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
