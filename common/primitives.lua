local primitives = {};

primitives.new_numeric = function (type_name, default)
	assert(type(type_name) == 'string', "Invalid type name");
	if (default == nil) then default = "0" end
	assert(type(default) == 'string', "Invalid default");
	assert(tonumber(default) ~= nil, "Invalid default :".. default);

	local atom = require('org.w3.2001.XMLSchema.'..type_name..'_handler'):instantiate();

	return atom:new(default);
end



return primitives;
