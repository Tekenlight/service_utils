local client_params = {};

local mt = { __index = client_params }

function client_params.new(params)
	local client_params = {};
	client_params.client_params = {};
	for n,v in pairs(params) do
		client_params.client_params[n] = params[n];
	end
	client_params = setmetatable(client_params, mt);
	return client_params;
end
function client_params:get_params(...)
	local clients = {...}
	local params = {};
	for i, v in ipairs(clients) do
		params[v] = self.client_params[v];
	end
	return params;
end

return client_params;

