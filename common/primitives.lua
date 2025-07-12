local primitives = {};

primitives.new_numeric = function (type_name, default)
	assert(type(type_name) == 'string', "Invalid type name");
	if (default == nil) then default = "0" end
	assert(type(default) == 'string', "Invalid default");
	assert(tonumber(default) ~= nil, "Invalid default :".. default);

	local atom = require('org.w3.2001.XMLSchema.'..type_name..'_handler'):instantiate();

	return atom:new(default);
end

primitives.new = function (type_name, default)
	assert(type(type_name) == 'string', "Invalid type name");
	assert(type(default) == 'string', "Invalid default");

	local atom = require('org.w3.2001.XMLSchema.'..type_name..'_handler'):instantiate();

	return atom:new(default);
end

primitives.int_0 = primitives.new_numeric("int", "0");
primitives.uint_0 = primitives.new_numeric("unsignedInt", "0");
primitives.long_0 = primitives.new_numeric("long", "0");
primitives.ulong_0 = primitives.new_numeric("unsignedLong", "0");

return primitives;
