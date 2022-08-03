local user_context = {};

local function get_conn(uc, db_name)
	assert(uc ~= nil and type(uc) == 'table');
	assert(db_name ~= nil and type(db_name) == 'string');
	assert(uc.db_connections ~= nil);
	assert(uc.db_connections[db_name] ~= nil);
	assert(uc.db_connections[db_name].conn ~= nil);
	local conn = uc.db_connections[db_name].conn;
	assert(conn ~= nil)

	return conn;
end

function user_context:get_req_frame_num()
	local req_frame_num = 1;
	assert(self ~= nil and type(self) == 'table');
	if (self.req_frame_num ~= nil) then
		req_frame_num = self.req_frame_num;
	end
	return req_frame_num;
end

function user_context:get_req_num_recs_per_frame()
	local req_num_recs_per_frame = 1000;
	assert(self ~= nil and type(self) == 'table');
	if (self.req_num_recs_per_frame ~= nil) then
		req_num_recs_per_frame = self.req_num_recs_per_frame;
	end
	return req_num_recs_per_frame;
end

function user_context:get_num_recs_per_frame()
	assert(self ~= nil and type(self) == 'table');
end

function user_context:get_connection(db_name)
	return get_conn(self, db_name);
end

function user_context:commit(db_name)
	assert(self ~= nil and type(self) == 'table');
	assert(db_name ~= nil and type(db_name) == 'string');
	local conn = get_conn(self, db_name);
	local flg, msg = conn:commit();
	if (not flg) then
		error(msg);
	end
	return;
end

function user_context:rollback(db_name)
	assert(self ~= nil and type(self) == 'table');
	assert(db_name ~= nil and type(db_name) == 'string');
	local conn = get_conn(self, db_name);
	local flg, msg = conn:rollback();
	if (not flg) then
		error(msg);
	end
	return;
end

function user_context:get_seq_nextval(db_name, seq_name)
	assert(self ~= nil and type(self) == 'table');
	assert(db_name ~= nil and type(db_name) == 'string');
	assert(seq_name ~= nil and type(seq_name) == 'string');

	local conn = get_conn(self, db_name);
	return conn:get_seq_nextval(seq_name);
end

function user_context:get_systimestamp(db_name)
	assert(self ~= nil and type(self) == 'table');
	assert(db_name ~= nil and type(db_name) == 'string');

	local conn = get_conn(self, db_name);
	return conn:get_systimestamp();
end

function user_context:get_sysdate(db_name)
	assert(self ~= nil and type(self) == 'table');
	assert(db_name ~= nil and type(db_name) == 'string');

	local conn = get_conn(self, db_name);
	return conn:get_sysdate();
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

