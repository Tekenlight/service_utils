local msf = require('service_utils.common.msg_literal');
local literals = {
	RECORD_NOT_FOUND = "Record not found for: [%s]"
	,DUPLICATE_RECORD_FOUND = "Duplicate record found for : [%s]"
};

return msf.new(literals);
