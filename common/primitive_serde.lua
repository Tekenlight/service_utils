local ffi = require("ffi");
local bc = require("bigdecimal");
local du = require('lua_schema.date_utils');
local cu = require('lua_schema.core_utils');
local types = require('service_utils.db.ev_types');
local xmlua = require("lua_schema.xmlua");
local nu = require("lua_schema.number_utils");

local xml_date_utils = xmlua.XMLDateUtils.new();

local primitive_serde = {};

primitive_serde.serialize = function(v)
	local tn ;
	local sv ;
	local sz;
	assert(v ~= nil);

	if (type(v) == 'cdata') then
		if (cu.is_binary_buffer(v)) then
			sv = cu.base64_encode(v);
			tn = cu.binary_buffer_name;
			sz = tonumber(v.size);
		elseif (ffi.istype("dt_s_type", v)) then
			local var_type = types.name_to_id[du.tid_name_map[v.type]];
			sv = tostring(v);
			if (var_type == ffi.C.ev_lua_date) then
				tn = "date";
				sz = 4;
			elseif (var_type == ffi.C.ev_lua_time) then
				tn = "time";
				sz = 8;
			else
				tn = "dateTime";
				sz = 8;
			end
		elseif (ffi.istype("dur_s_type", v)) then
			tn = 'duration';
			sv = tostring(v.value);
			sz = ffi.C.strlen(v.value);
		elseif ( ffi.istype("float", v)) then
			tn = "float"
			sv = tostring(v);
			sz = 4;
		elseif (ffi.istype("int8_t", v) ) then
			tn = "int8_t"
			sv = string.format("%d", tonumber(v));
			sz = 1;
		elseif (ffi.istype("uint8_t", v) ) then
			tn = "uint8_t"
			sv = string.format("%d", tonumber(v));
			sz = 1;
		elseif ( ffi.istype("int16_t", v)) then
			tn = "int16_t"
			sv = string.format("%d", tonumber(v));
			sz = 2;
		elseif (ffi.istype("uint16_t", v) ) then
			tn = "uint16_t"
			sv = string.format("%d", tonumber(v));
			sz = 2;
		elseif ( ffi.istype("int32_t", v)) then
			tn = "int32_t"
			sv = string.format("%d", tonumber(v));
			sz = 4;
		elseif (ffi.istype("uint32_t", v) ) then
			tn = "uint32_t"
			sv = string.format("%d", tonumber(v));
			sz = 4;
		elseif ( ffi.istype("int64_t", v)) then
			tn = "int64_t"
			sv = string.format("%d", tonumber(v));
			sz = 8;
		elseif (ffi.istype("uint64_t", v) ) then
			tn = "uint64_t"
			sv = string.format("%d", tonumber(v));
			sz = 8;
		else
			error("Datatype not supported");
		end
	elseif (type(v) == 'userdata' and v.__name == 'bc bignumber') then
		sv = tostring(v);
		tn = "decimal";
		sz = #sv;
	elseif (type(v) == 'string') then
		sv = v;
		tn = "string";
		sz = #sv;
	elseif (type(v) == 'boolean') then
		sv = v;
		tn = "boolean";
		sz = 8;
	elseif (type(v) == 'number') then
		sv = v;
		tn = "number";
		sz = 8;
	else
		error("Datatype not supported");
	end

	return {sz = sz, sv = sv, tn = tn}
end

primitive_serde.deserialize = function(sv, tn, sz)
	assert(type(sv) == 'string' or type(sv) == 'boolean' or type(sv) == 'number');
	assert(type(sz) == 'number');
	assert(type(tn) == 'string');

	local value;

	if (tn == cu.binary_buffer_name) then
		value = cu.base64_decode(sv);
	elseif (tn == "date") then
		value = du.from_xml_date_field(xml_date_utils.value_type.XML_SCHEMAS_DATE, sv);
	elseif (tn == "time") then
		value = du.from_xml_date_field(xml_date_utils.value_type.XML_SCHEMAS_TIME, sv);
	elseif (tn == "dateTime") then
		value = du.from_xml_date_field(xml_date_utils.value_type.XML_SCHEMAS_DATETIME, sv);
	elseif (tn == "dur_s_type") then
		value = du.from_xml_duration(sv);
	elseif (tn ==  "float") then
		local n = nu.to_double(sv);
		value = ffi.new("float", n);
	elseif (tn == "int8_t") then
		local n = math.tointeger(sv);
		value = ffi.cast("int8_t", n);
	elseif (tn == "uint8_t") then
		local n = math.tointeger(sv);
		value = ffi.cast("uint8_t", n);
	elseif (tn ==  "int16_t") then
		local n = math.tointeger(sv);
		value = ffi.cast("int16_t", n);
	elseif (tn == "uint16_t") then
		local n = math.tointeger(sv);
		value = ffi.cast("uint16_t", n);
	elseif (tn ==  "int32_t") then
		local n = math.tointeger(sv);
		value = ffi.cast("int32_t", n);
	elseif (tn == "uint32_t") then
		local n = math.tointeger(sv);
		value = ffi.cast("uint32_t", n);
	elseif (tn ==  "int64_t") then
		local n = math.tointeger(sv);
		value = ffi.cast("int64_t", n);
	elseif (tn == "uint64_t") then
		local n = math.tointeger(sv);
		value = ffi.cast("uint64_t", n);
	elseif (tn == "decimal") then
		value = bc.new(sv);
	elseif (tn == 'string') then
		value = sv;
	elseif (tn == 'boolean') then
		value = sv;
	elseif (tn == 'number') then
		value = sv;
	else
		error("Datatype not supported");
	end
	return value;
end


return primitive_serde;
