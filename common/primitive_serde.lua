local ffi = require("ffi");
local bc = require("bigdecimal");
local du = require('lua_schema.date_utils');
local cu = require('lua_schema.core_utils');
local types = require('service_utils.db.ev_types');
local xmlua = require("xmlua");
local nu = require("lua_schema.number_utils");

local xml_date_utils = xmlua.XMLDateUtils.new();

local primitive_serde = {};

primitive_serde.serialize = function(v)
	local type_name ;
	local serialized_value ;
	local size;
	assert(v ~= nil);

	if (type(v) == 'cdata') then
		if (ffi.istype("hex_data_s_type", v)) then
			serialized_value = cu.base64_encode(v);
			type_name = "binary";
			size = tonumber(v.size);
		elseif (ffi.istype("dt_s_type", v)) then
			local var_type = types.name_to_id[du.tid_name_map[v.type]];
			serialized_value = tostring(v);
			if (var_type == ffi.C.ev_lua_date) then
				type_name = "date";
				size = 4;
			elseif (var_type == ffi.C.ev_lua_time) then
				type_name = "time";
				size = 8;
			else
				type_name = "dateTime";
				size = 8;
			end
		elseif (ffi.istype("dur_s_type", v)) then
			local bind_var = ffi.new("lua_bind_variable_s", 0);
			type_name = 'duration';
			serialized_value = tostring(v.value);
			size = ffi.C.strlen(v.value);
		elseif ( ffi.istype("float", v)) then
			type_name = "float"
			serialized_value = tostring(v);
			bind_var.size = 4;
		elseif (ffi.istype("int8_t", v) ) then
			type_name = "int8_t"
			serialized_value = string.format("%d", tonumber(v));
			size = 1;
		elseif (ffi.istype("uint8_t", v) ) then
			type_name = "uint8_t"
			serialized_value = string.format("%d", tonumber(v));
			size = 1;
		elseif ( ffi.istype("int16_t", v)) then
			type_name = "int16_t"
			serialized_value = string.format("%d", tonumber(v));
			size = 2;
		elseif (ffi.istype("uint16_t", v) ) then
			type_name = "uint16_t"
			serialized_value = string.format("%d", tonumber(v));
			size = 2;
		elseif ( ffi.istype("int32_t", v)) then
			type_name = "int32_t"
			serialized_value = string.format("%d", tonumber(v));
			size = 4;
		elseif (ffi.istype("uint32_t", v) ) then
			type_name = "uint32_t"
			serialized_value = string.format("%d", tonumber(v));
			size = 4;
		elseif ( ffi.istype("int64_t", v)) then
			type_name = "int64_t"
			serialized_value = string.format("%d", tonumber(v));
			size = 8;
		elseif (ffi.istype("uint64_t", v) ) then
			type_name = "uint64_t"
			serialized_value = string.format("%d", tonumber(v));
			size = 8;
		else
			error("Datatype not supported");
		end
	elseif (type(v) == 'userdata' and v.__name == 'bc bignumber') then
		serialized_value = tostring(v);
		type_name = "decimal";
		size = #serialized_value;
	elseif (type(v) == 'string') then
		serialized_value = v;
		type_name = "string";
		size = #serialized_value;
	elseif (type(v) == 'boolean') then
		serialized_value = v;
		type_name = "boolean";
		size = 8;
	elseif (type(v) == 'number') then
		serialized_value = v;
		type_name = "number";
		size = 8;
	else
		error("Datatype not supported");
	end

	return {size = size, serialized_value = serialized_value, type_name = type_name}
end

primitive_serde.deserialize = function(serialized_value, type_name, size)
	assert(type(serialized_value) == 'string' or type(serialized_value) == 'boolean' or type(serialized_value) == 'number');
	assert(type(size) == 'number');
	assert(type(type_name) == 'string');

	local value;

	if (type_name == "hex_data_s_type") then
		value = cu.base64_decode(serialized_value);
	elseif (type_name == "date") then
		value = du.from_xml_date_field(xml_date_utils.value_type.XML_SCHEMAS_DATE, serialized_value);
	elseif (type_name == "time") then
		value = du.from_xml_date_field(xml_date_utils.value_type.XML_SCHEMAS_TIME, serialized_value);
	elseif (type_name == "dateTime") then
		value = du.from_xml_date_field(xml_date_utils.value_type.XML_SCHEMAS_DATETIME, serialized_value);
	elseif (type_name == "dur_s_type") then
		value = du.from_xml_duration(serialized_value);
	elseif (type_name ==  "float") then
		local n = nu.to_double(serialized_value);
		value = ffi.new("float", n);
	elseif (type_name == "int8_t") then
		local n = math.tointeger(serialized_value);
		value = ffi.cast("int8_t", n);
	elseif (type_name == "uint8_t") then
		local n = math.tointeger(serialized_value);
		value = ffi.cast("uint8_t", n);
	elseif (type_name ==  "int16_t") then
		local n = math.tointeger(serialized_value);
		value = ffi.cast("int16_t", n);
	elseif (type_name == "uint16_t") then
		local n = math.tointeger(serialized_value);
		value = ffi.cast("uint16_t", n);
	elseif (type_name ==  "int32_t") then
		local n = math.tointeger(serialized_value);
		value = ffi.cast("int32_t", n);
	elseif (type_name == "uint32_t") then
		local n = math.tointeger(serialized_value);
		value = ffi.cast("uint32_t", n);
	elseif (type_name ==  "int64_t") then
		local n = math.tointeger(serialized_value);
		value = ffi.cast("int64_t", n);
	elseif (type_name == "uint64_t") then
		local n = math.tointeger(serialized_value);
		value = ffi.cast("uint64_t", n);
	elseif (type_name == "decimal") then
		value = bc.new(serialized_value);
	elseif (type_name == 'string') then
		value = serialized_value;
	elseif (type_name == 'boolean') then
		value = serialized_value;
	elseif (type_name == 'number') then
		value = serialized_value;
	else
		error("Datatype not supported");
	end
	return value;
end


return primitive_serde;
