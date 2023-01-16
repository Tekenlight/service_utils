local error_handler = require("lua_schema.error_handler");

local rest_sample_interface = {};

rest_sample_interface.get_db_connection_params = function(self)
	local master_db_params = require("db_params");
	return master_db_params:get_params();
end

rest_sample_interface.methods = {};

rest_sample_interface.methods.fetch = {};
rest_sample_interface.methods.fetch.http_method = "GET";
rest_sample_interface.methods.fetch.transactional = false;
rest_sample_interface.methods.fetch.message = {};

rest_sample_interface.methods.fetch.message.query_params = {};
rest_sample_interface.methods.fetch.message.in_out = {};

rest_sample_interface.methods.fetch.message.query_params.query_param = {};
rest_sample_interface.methods.fetch.message.query_params.query_param.ns = '';
rest_sample_interface.methods.fetch.message.query_params.query_param.name = 'query_param';

rest_sample_interface.methods.fetch.message.in_out[1] = nil;

rest_sample_interface.methods.fetch.message.in_out[2] = {};
rest_sample_interface.methods.fetch.message.in_out[2].ns = '';
rest_sample_interface.methods.fetch.message.in_out[2].name = 'rest_sample_struct';


rest_sample_interface.methods.add = {};
rest_sample_interface.methods.add.http_method = "POST";
rest_sample_interface.methods.add.transactional = true;
rest_sample_interface.methods.add.message = {};

rest_sample_interface.methods.add.message.query_params = {};
rest_sample_interface.methods.add.message.in_out = {};

rest_sample_interface.methods.add.message.in_out[1] = {};
rest_sample_interface.methods.add.message.in_out[1].ns = '';
rest_sample_interface.methods.add.message.in_out[1].name = 'rest_sample_struct';

rest_sample_interface.methods.add.message.in_out[2] = nil;


return rest_sample_interface;

