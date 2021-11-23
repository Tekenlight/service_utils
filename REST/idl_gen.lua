local schema_processor = require("schema_processor");
local stringx = require("pl.stringx");



local idl_file_name = arg[1];
assert(idl_file_name ~= nil and type(idl_file_name) == 'string');
local idl_file = io.open(idl_file_name, "r");
assert(idl_file ~= nil);

local xml_string = idl_file:read("a");

idl_file:close();

local idl_msg_handler = schema_processor:get_message_handler("interface", "http://evpoco.tekenlight.org/idl_spec");

local idl_struct, msg = idl_msg_handler:from_xml(xml_string);

if (idl_struct == nil) then
	error(msg);
end

local class_name = idl_struct._attr.name..'_interface';

local code = '';

code = code ..[=[
local error_handler = require("lua_schema.error_handler");

local ]=]..class_name..[=[ = {};

]=]..class_name..[=[.get_db_connection_params = function(self)
	local master_db_params = require("db_params");
	return master_db_params:get_params(']=]..idl_struct._attr.db_schema_name..[=[');
end

]=]..class_name..[=[.methods = {};

]=]

for i, method in ipairs(idl_struct.method) do
	code = code .. [=[
]=]..[=[
]=]..class_name..[=[.methods]=]..[=[.]=]..method._attr.name..[=[ = {};
]=]..class_name..[=[.methods]=]..[=[.]=]..method._attr.name..[=[.transactional = ]=]..tostring(method._attr.transactional)..[=[;
]=]..class_name..[=[.methods]=]..[=[.]=]..method._attr.name..[=[.message = {};

]=]..class_name..[=[.methods]=]..[=[.]=]..method._attr.name..[=[.message.query_params = {};
]=]..class_name..[=[.methods]=]..[=[.]=]..method._attr.name..[=[.message.in_out = {};

]=]
	if (method.query_param ~= nil) then
		for j, qp in ipairs(method.query_param) do
		code = code ..[=[
]=]..class_name..[=[.methods]=]..[=[.]=]..method._attr.name..[=[.message.query_params.]=]..qp._attr.name..[=[ = {};
]=]..class_name..[=[.methods]=]..[=[.]=]..method._attr.name..[=[.message.query_params.]=]..qp._attr.name..[=[.ns = ']=]..qp._attr.namespace..[=[';
]=]..class_name..[=[.methods]=]..[=[.]=]..method._attr.name..[=[.message.query_params.]=]..qp._attr.name..[=[.name = ']=]..qp._attr.decl_name..[=[';

]=]
		end
	end

	if (method.input ~= nil) then
		code = code ..[=[
]=]..class_name..[=[.methods]=]..[=[.]=]..method._attr.name..[=[.message.in_out[1] = {};
]=]..class_name..[=[.methods]=]..[=[.]=]..method._attr.name..[=[.message.in_out[1].ns = ']=]..method.input._attr.namespace..[=[';
]=]..class_name..[=[.methods]=]..[=[.]=]..method._attr.name..[=[.message.in_out[1].name = ']=]..method.input._attr.name..[=[';
]=]..class_name..[=[.methods]=]..[=[.]=]..method._attr.name..[=[.message.in_out[1].decl_name = ']=]..method.input._attr.decl_name..[=[';

]=]
	else
		code = code ..[=[
]=]..class_name..[=[.methods]=]..[=[.]=]..method._attr.name..[=[.message.in_out[1] = nil;

]=]
	end

	if (method.output ~= nil) then
		code = code ..[=[
]=]..class_name..[=[.methods]=]..[=[.]=]..method._attr.name..[=[.message.in_out[2] = {};
]=]..class_name..[=[.methods]=]..[=[.]=]..method._attr.name..[=[.message.in_out[2].ns = ']=]..method.output._attr.namespace..[=[';
]=]..class_name..[=[.methods]=]..[=[.]=]..method._attr.name..[=[.message.in_out[2].decl_name = ']=]..method.output._attr.decl_name..[=[';

]=]
	else
		code = code ..[=[
]=]..class_name..[=[.methods]=]..[=[.]=]..method._attr.name..[=[.message.in_out[2] = nil;

]=]
	end
	code = code ..[=[

]=]
end

code = code ..[=[
return ]=]..class_name..[=[;

]=]


local package_parts = stringx.split(idl_struct._attr.package, ".");
assert(#package_parts > 0);

local n = #package_parts;
local local_path = '.';
local i = 1;
while (i <= n) do
	local_path = local_path..'/'..package_parts[i];;
	local command = 'test ! -d '..local_path..' && mkdir '..local_path;
	os.execute(command);
	i = i+1;
end
local file_path = local_path..'/'..class_name..'.lua';
local file = io.open(file_path, "w+");

file:write(code);

file:close();





