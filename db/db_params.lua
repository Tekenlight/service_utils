local db_params = {};

local mt = { __index = db_params }

function db_params.new(params)
	local dbp = {};
	dbp.db_params = {};
	for n,v in pairs(params) do
		dbp.db_params[n] = params[n];
	end
	dbp = setmetatable(dbp, mt);
	return dbp;
end
function db_params:get_params(...)
	local dbs = {...}
	local params = {};
	for i, v in ipairs(dbs) do
		params[v] = self.db_params[v];
	end
	return params;
end

return db_params;

