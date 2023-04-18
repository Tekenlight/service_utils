local transaction = {}

transaction.enable_org_refresh = function (context, name, org_id)
    assert(context.dml_ops[name] ~= nil and type(context.dml_ops[name]) == 'table');
    assert(context.dml_ops[name].enable_audit == true);
    assert(context.dml_ops[name].generic_refresh == false);
    assert(org_id ~= nil);
    context.dml_ops[name].org_refresh = true;
    context.dml_ops[name].refresh_org_id = org_id;
end

transaction.enable_generic_refresh = function (context, name)
    assert(context.dml_ops[name] ~= nil and type(context.dml_ops[name]) == 'table');
    assert(context.dml_ops[name].enable_audit == true);
    assert(context.dml_ops[name].org_refresh == false);
    assert(context.dml_ops[name].refresh_org_id == nil);
    context.dml_ops[name].generic_refresh = true;
end

transaction.enable_audit = function (context, name, callback_function)
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
    context.dml_ops[name].refresh_org_id = nil;
end

transaction.begin_transaction = function(context, name)
    if context.dml_ops == nil then
        context.dml_ops = {};
    end

    if context.dml_ops[name] == nil then
        context.dml_ops[name] = {};
        context.dml_ops[name].enable_audit = false;
        context.dml_ops[name].org_refresh = false;
        context.dml_ops[name].generic_refresh = false;
        context.dml_ops[name].refresh_org_id = nil;
    end

    assert(context.dml_ops[name] ~= nil and type(context.dml_ops[name]) == 'table');
    assert(context.dml_ops[name].enable_audit ~= nil and type(context.dml_ops[name].enable_audit) == 'boolean');
    assert(context.dml_ops[name].org_refresh ~= nil and type(context.dml_ops[name].org_refresh) == 'boolean');
    assert(context.dml_ops[name].generic_refresh ~= nil and type(context.dml_ops[name].generic_refresh) == 'boolean');
    if context.dml_ops[name].refresh_org_id ~= nil then
        assert(type(context.dml_ops[name].refresh_org_id) == 'string');
    end
    context.dml_ops[name].changes = {};
    context.db_connections[name].conn:begin();
end

transaction.commit_transaction = function(context, name, conn)
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
