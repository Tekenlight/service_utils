local user_context = {};

function user_context:commit(db_name)
	assert(self ~= nil and type(self) == 'table');
	assert(db_name ~= nil and type(db_name) == 'string');
	local conn = self.db_connections[db_name].conn;
	local flg, msg = conn:commit();
	if (not flg) then
		error(msg);
	end
	return;
end

function user_context:rollback(db_name)
	assert(self ~= nil and type(self) == 'table');
	assert(db_name ~= nil and type(db_name) == 'string');
	local conn = self.db_connections[db_name].conn;
	local flg, msg = conn:rollback();
	if (not flg) then
		error(msg);
	end
	return;
end

local mt = { __index = user_context };
local factory = {};

function factory.new()
	local uc = {};
	uc.db_connections = {};
	uc = setmetatable(uc, mt);
	return uc;
end

return factory;

