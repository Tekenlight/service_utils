local ev_database = {};

function ev_database.make_db_connection(db_name)
	assert(db_name ~= nil and type(db_name) == 'string');
	local master_db_params = require("db_params");
	local db_attributes = master_db_params:get_params(db_name)[db_name];
	local conn = (require(db_attributes.handler)).open_connetion(table.unpack(db_attributes.params));

	return conn;
end

return ev_database;

