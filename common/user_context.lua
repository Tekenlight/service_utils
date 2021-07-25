local user_context = {};

function user_context:add_db_connection(name, conn)
	if (name == nil or type(name) ~= 'string') then
		error("INVALID INPUTS");
	elseif (conn == nil) then
		error("INVALID INPUTS");
	end
	self.db_connections[name] = conn;
end

function user_context:get_db_connetion(name)
	if (name == nil or type(name) ~= 'string') then
		error("INVALID INPUTS");
	end
	return self.db_connections[name];
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

