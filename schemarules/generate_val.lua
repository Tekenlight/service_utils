local stringx = require("pl.stringx");
local xmlua = require("xmlua")
local schema_processor = require("schema_processor")
local xsd = xmlua.XSD.new();
local xml = xmlua.XML;

local app_info_xml_name = arg[1];
local ref_common_module_name = arg[2];
local build_mode = (arg[3] ~= nil and arg[3] ~= "0");
local code_output = {};

local function write_to_file(code_output)
	for package, package_content in pairs(code_output) do
		local package_parts = package_content.package_parts;
		assert(#package_parts > 0);
		local n = #package_parts;
		local local_path = "";
		local i = 1;
		while (i < n) do
			if(local_path == "") then
			local_path = package_parts[i];
		    else
			local_path = local_path..'/'..package_parts[i];;
		    end
			i = i+1;
		end
		local command ='mkdir -p '..local_path;
        os.execute(command);
		local file_path = local_path..'/'..package_parts[n]..'.lua';
		local file = io.open(file_path, "w+");
		file:write(package_content.top_portion);
		for i,v in ipairs(package_content.functions) do
			file:write(v);
		end
		file:write(package_content.footer);

		file:close();
	end

	return;
end

function returnfile(path)
    local parts = stringx.split(path, "/");
    return parts[#parts]
end

local function write_target_file(code_output)
	 local c, header, footer, package_parts;
     for package, package_content in pairs(code_output) do
        package_parts = package_content.package_parts;
        assert(#package_parts > 0);
        local n = #package_parts;
        local local_path = "";
        local i = 1;
        while (i < n) do
			if(local_path == "") then
				local_path = package_parts[i]
			else
            	local_path = local_path..'/'..package_parts[i];
			end
            i = i+1;
        end
        local file_path = local_path..'/'..package_parts[n]..'.lua';
        local file_path_parts = stringx.split(file_path, "/");
        local j = 1;
        local file_path1 = "";
        while(j <= #file_path_parts) do
        	if(file_path1 == "") then
        		file_path1 = file_path_parts[j];
    		else
        		file_path1 = file_path1.."."..file_path_parts[j];
    		end
    		j = j + 1;
		end
		file_path1 = file_path1:gsub("%.lua$","");

		header = "local build_mappings = {\n"
		footer = '\n}'.."\n\nreturn build_mappings;"
	    if(c ~= nil) then
       		 c = c..",\n"..'\t["'..file_path1..'"]'..' = '..'"'..file_path..'"';
	    else
	    	c = '\t["'..file_path1..'"]'..' = '..'"'..file_path..'"';
	    end
	end

	local out_file = app_info_xml_name:gsub("%.%.","");
	out_file = app_info_xml_name:gsub(".xml$","");
    out_file = returnfile(out_file);
	if (build_mode) then
		os.execute("mkdir -p output_files/val")
		local target_file_path = "output_files/val/"..out_file.."_xml.lua";
		local final = header..c..footer;
		local tfile = io.open(target_file_path, "w+");
		tfile:write(final);
		tfile:close();
	end
	return;
end


local function generate_validation_routine(rule_set, ref_common_module_name, code_output)
	local package_parts = stringx.split(rule_set._attr.package, ".");
	assert(#package_parts > 0);
	local n = #package_parts;
	local package = rule_set._attr.package;
	local function_name = rule_set._attr.rule_set_name;
	if (code_output[rule_set._attr.package] == nil) then -- {
		code_output[rule_set._attr.package] = {};
		code_output[rule_set._attr.package].package_parts = package_parts;
		code_output[rule_set._attr.package].package_name = rule_set._attr.package;
		local code = [=[
local validate_map = require('service_utils.validation.validate_map');
local master_db_params = require('db_params');
local ffi = require('ffi');
local messages = require(']=]..ref_common_module_name..[=[.literals');
local error_handler = require("lua_schema.error_handler");

local ]=]..package_parts[n]..[=[ = {};

]=];
		code_output[rule_set._attr.package].top_portion = code;
		code = [=[

return ]=]..package_parts[n]..[=[;

]=];
		code_output[rule_set._attr.package].footer = code;
		code_output[rule_set._attr.package].functions = {};
	end -- }

	local code = [=[
]=]..package_parts[n]..'.'..rule_set._attr.rule_set_name..[=[ = function(context, obj, addnl_obj)
	local validations_array = {};
	local j = 1;

]=];
	for i,v in ipairs(rule_set.rule) do -- {
		if (v.assertion ~= nil) then -- {
			if (v.assertion._attr ~= nil and v.assertion._attr.condition ~= nil) then -- {
				code = code .. [=[
	if (]=] .. v.assertion._attr.condition..[=[) then
		validations_array[j] = {};
		validations_array[j].val_func = function(context, obj, addnl_obj)
			if (not (]=]..v.assertion._contained_value..[=[)) then
]=];
				local error_msg_inp_elements = '';
				if (v.error_def.input ~= nil) then -- {
					for i,v in ipairs(v.error_def.input) do -- {
						error_msg_inp_elements = error_msg_inp_elements..', tostring('..v..')';
					end --}
				end --}
				code = code ..[=[
				local msg = nil;
]=];
				if (v.error_def.error_code ~= nil) then -- {
					code = code .. [=[
				msg = messages:format(']=]..v.error_def.error_code..[=[']=]..error_msg_inp_elements..[=[);
]=];
				else --} {
					code = code .. [=[
				local msg1 = ']=].. v.error_def.error_message..[=[';
				msg = messages:format_with_string(msg1]=]..error_msg_inp_elements..[=[);
]=];
				end --}
				code = code..[=[
				error_handler.raise_validation_error(-1, msg, debug.getinfo(1));
				return false;
]=];
				code = code ..[=[
			end
			return true;
		end
]=];
				if (v._attr.ref_element ~= nil) then --{
					code = code ..[=[
		validations_array[j].ref_element = ']=]..tostring(v._attr.ref_element)..[=[';
]=];
				else -- } {
					code = code .. [=[
		validations_array[j].ref_element = ]=]..tostring(v._attr.ref_element)..[=[;
]=];
				end --}
				code = code ..[=[
		validations_array[j].type = ']=]..tostring(v._attr.type)..[=[';
		validations_array[j].argument = obj;
		validations_array[j].argument_type = 'scalar';
		validations_array[j].addnl_argument = addnl_obj;
		j = j+1;
	end

]=];
			else -- } {
				code = code .. [=[
	validations_array[j] = {};
	validations_array[j].val_func = function(context, obj, addnl_obj)
		if (not (]=]..v.assertion._contained_value..[=[)) then
]=];
				local error_msg_inp_elements = '';
				if (v.error_def.input ~= nil) then --{
					for i,v in ipairs(v.error_def.input) do --{
						error_msg_inp_elements = error_msg_inp_elements..', tostring('..v..')';
					end --}
				end --}
				code = code ..[=[
			local msg = nil;
]=];
				if (v.error_def.error_code ~= nil) then --{
					code = code .. [=[
			msg = messages:format(']=]..v.error_def.error_code..[=[']=]..error_msg_inp_elements..[=[);
]=];
				else -- } {
					code = code .. [=[
			msg = ']=].. v.error_def.error_message..[=[';
]=];
				end --}
				code = code..[=[
			error_handler.raise_validation_error(-1, msg, debug.getinfo(1));
			return false;
]=];
				code = code ..[=[
		end
		return true;
	end
]=];
				if (v._attr.ref_element ~= nil) then --{
					code = code ..[=[
	validations_array[j].ref_element = ']=]..tostring(v._attr.ref_element)..[=[';
]=];
				else -- } {
					code = code .. [=[
	validations_array[j].ref_element = ]=]..tostring(v._attr.ref_element)..[=[;
]=];
				end --}
				code = code ..[=[
	validations_array[j].type = ']=]..tostring(v._attr.type)..[=[';
	validations_array[j].argument = obj;
	validations_array[j].argument_type = 'scalar';
	validations_array[j].addnl_argument = addnl_obj;
	j = j+1;

]=];
			end --}
		else -- } {
			if (v.validation._attr ~= nil and v.validation._attr.condition ~= nil) then --{
				code = code..[=[
	do
		local argument_obj = ]=]..tostring(v.validation._attr.argument)..[=[;
		if (]=] .. v.validation._attr.condition..[=[) then
			validations_array[j] = {};
]=];
				if (v._attr.ref_element ~= nil) then --{
					code = code ..[=[
			validations_array[j].ref_element = ']=]..tostring(v._attr.ref_element)..[=[';
]=];
				else -- } {
					code = code .. [=[
			validations_array[j].ref_element = ]=]..tostring(v._attr.ref_element)..[=[;
]=];
				end --}
				code = code ..[=[
			validations_array[j].type = ']=]..tostring(v._attr.type)..[=[';
			local package = require(']=]..v.validation._attr.package..[=[');
			validations_array[j].val_func = package[']=]..v.validation._attr.method..[=['];
			if (validations_array[j].val_func == nil) then
				error("Function []=]..v.validation._attr.method..[=[] not found in package []=]..v.validation._attr.package..[=[]");
			end
			validations_array[j].argument_type = ']=]..tostring(v.validation._attr.argument_type)..[=[';
			validations_array[j].argument = ]=]..tostring(v.validation._attr.argument)..[=[;
			validations_array[j].main_obj = obj;
			validations_array[j].addnl_argument = ]=]..tostring(v.validation._attr.addnl_argument)..[=[;
]=]
				if (v.validation._attr.ae_condition ~= nil) then --{
					if (v.validation._attr.argument_type ~= 'array') then -- {
						error("ae_condtions are applicable only for array type of arguments");
					end -- }
					code = code ..[=[
			validations_array[j].ae_condition = function(context, i, argument_obj, obj, addnl_obj)
				return (]=]..tostring(v.validation._attr.ae_condition)..[=[);
			end;
]=]
				end --}
				code = code ..[=[
			j = j+1;
		end
	end

]=];
			else -- } {
				code = code .. [=[
	do
		local argument_obj = ]=]..tostring(v.validation._attr.argument)..[=[;
		validations_array[j] = {};
]=];
				if (v._attr.ref_element ~= nil) then --{
					code = code ..[=[
		validations_array[j].ref_element = ']=]..tostring(v._attr.ref_element)..[=[';
]=];
				else -- } {
					code = code .. [=[
		validations_array[j].ref_element = ]=]..tostring(v._attr.ref_element)..[=[;
]=];
				end --}
				code = code ..[=[
		validations_array[j].type = ']=]..tostring(v._attr.type)..[=[';
		local package = require(']=]..v.validation._attr.package..[=[');
		validations_array[j].val_func = package[']=]..v.validation._attr.method..[=['];
		if (validations_array[j].val_func == nil) then
			error("Function []=]..v.validation._attr.method..[=[] not found in package []=]..v.validation._attr.package..[=[]");
		end
		validations_array[j].argument_type = ']=]..tostring(v.validation._attr.argument_type)..[=[';
		validations_array[j].argument = ]=]..tostring(v.validation._attr.argument)..[=[;
		validations_array[j].main_obj = obj;
		validations_array[j].addnl_argument = ]=]..tostring(v.validation._attr.addnl_argument)..[=[;
]=]
				if (v.validation._attr.ae_condition ~= nil) then --{
					if (v.validation._attr.argument_type ~= 'array') then -- {
						error("ae_condtions are applicable only for array type of arguments");
					end -- }
					code = code ..[=[
		validations_array[j].ae_condition = function(context, i, argument_obj, obj, addnl_obj)
			return (]=]..tostring(v.validation._attr.ae_condition)..[=[);
		end;
]=]
				end --}
				code = code ..[=[
		j = j+1;
	end

]=];
			end --}
		end --}
	end --}
	code = code..  [=[

	return validate_map.run(context, validations_array, obj, addnl_obj);

end

]=];
	local count = #code_output[rule_set._attr.package].functions;
	code_output[rule_set._attr.package].functions[count+1] = code;
end

-- Main()

--if (#arg ~= 2) then
--	error("Usage generate_schema <app_info_xml_file> <ref_common_module_name>");
--	os.exit(-1);
--end

assert(app_info_xml_name ~= nil and type(app_info_xml_name) == 'string');
local app_info_xml_file = io.open(app_info_xml_name, "r");
assert(app_info_xml_file ~= nil);

local app_info_xml_string = app_info_xml_file:read("a");
app_info_xml_file:close();

local app_info_msg_handler = schema_processor:get_message_handler("app_info", "http://evpoco.tekenlight.org/message_rules");
local app_info, msg = app_info_msg_handler:from_xml(app_info_xml_string);

if (app_info == nil) then
	error(msg);
end

if (app_info.rule_set ~= nil) then
	for i, rule_set in ipairs(app_info.rule_set) do
		generate_validation_routine(rule_set, ref_common_module_name, code_output);
	end
end


write_to_file(code_output);
write_target_file(code_output);
