local schema_processor = require("schema_processor");
local mapping_util = {};

mapping_util.copy_elements = function(ns, element, from_obj)
	assert(ns ~= nil and type(ns) == 'string');
	assert(element ~= nil and type(element) == 'string');
	assert(from_obj ~= nil and type(from_obj) == 'table');

	local out_obj = {};
	local elem_handler = schema_processor:get_message_handler(element, ns);
	local elems = elem_handler.properties.generated_subelements;
	for n,v in pairs(elems) do
		if (v.properties.content_type == 'S') then
			out_obj[n] = from_obj[n];
		end
	end

	return out_obj;
end


return mapping_util;
