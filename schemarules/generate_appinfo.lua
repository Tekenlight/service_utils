local stringx = require("pl.stringx");
local xmlua = require("xmlua")
local mhf = require("schema_processor")
local xsd = xmlua.XSD.new();
local xml = xmlua.XML;

_G.handler_cache = {};

local get_path_and_class = function(package)
	local package_parts = stringx.split(package, ".");
	assert(#package_parts > 0);
	local n = #package_parts;
	local local_path = '.';
	local i = 1;
	local function_name = string.sub(rule_set._attr.package, stringx.rfind(rule_set._attr.package,'.')+1);
	local package_name = string.sub(rule_set._attr.package, 1, stringx.rfind(rule_set._attr.package,'.')-1);

	return package_name, function_name;
end

local function write_to_file(code_output)
	for package, package_content in pairs(code_output) do
		local package_parts = package_content.package_parts;
		assert(#package_parts > 0);
		local n = #package_parts;
		local local_path = '.';
		local i = 1;
		while (i < n) do
			local_path = local_path..'/'..package_parts[i];;
			local command = 'test ! -d '..local_path..' && mkdir '..local_path;
			os.execute(command);
			i = i+1;
		end
		file_path = local_path..'/'..package_parts[n]..'.lua';
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

local function generate_validation_routine(rule_set, module_name, code_output)
	local package_parts = stringx.split(rule_set._attr.package, ".");
	assert(#package_parts > 0);
	local n = #package_parts;
	local package = rule_set._attr.package;
	local function_name = rule_set._attr.rule_set_name;
	if (code_output[rule_set._attr.package] == nil) then
		code_output[rule_set._attr.package] = {};
		code_output[rule_set._attr.package].package_parts = package_parts;
		code_output[rule_set._attr.package].package_name = rule_set._attr.package;
		local code = [=[
local validate_map = require('service_utils.validation.validate_map');
local master_db_params = require('db_params');
local ffi = require('ffi');
local messages = require(']=]..module_name..[=[.literals');
local error_handler = require("lua_schema.error_handler");

local ]=]..package_parts[n]..[=[ = {};

]=];
		code_output[rule_set._attr.package].top_portion = code;
		code = [=[

return ]=]..package_parts[n]..[=[;

]=];
		code_output[rule_set._attr.package].footer = code;
		code_output[rule_set._attr.package].functions = {};
	end

	local code = [=[
]=]..package_parts[n]..'.'..rule_set._attr.rule_set_name..[=[ = function(context, obj, addnl_obj)
	local validations_array = {};
	local j = 1;

]=];
	for i,v in ipairs(rule_set.rule) do
		if (v.assertion ~= nil) then
			if (v.assertion._attr ~= nil and v.assertion._attr.condition ~= nil) then
				code = code .. [=[
	if (]=] .. v.assertion._attr.condition..[=[) then
		validations_array[j] = {};
		validations_array[j].val_func = function(context, obj, addnl_obj)
			if (not (]=]..v.assertion._contained_value..[=[)) then
]=];
				local error_msg_inp_elements = '';
				if (v.error_def.input ~= nil) then
					for i,v in ipairs(v.error_def.input) do
						error_msg_inp_elements = error_msg_inp_elements..', tostring('..v..')';
					end
				end
				code = code ..[=[
				local msg = nil;
]=];
					if (v.error_def.error_code ~= nil) then
						code = code .. [=[
				msg = messages:format(']=]..v.error_def.error_code..[=[']=]..error_msg_inp_elements..[=[);
]=];
					else
						code = code .. [=[
				local msg1 = ']=].. v.error_def.error_message..[=[';
				msg = messages:format_with_string(msg1]=]..error_msg_inp_elements..[=[);
]=];
					end
					code = code..[=[
				error_handler.raise_validation_error(-1, msg, debug.getinfo(1));
				return false;
]=];
				code = code ..[=[
			end
			return true;
		end
]=];
		if (v._attr.ref_element ~= nil) then
			code = code ..[=[
		validations_array[j].ref_element = ']=]..tostring(v._attr.ref_element)..[=[';
]=];
		else
			code = code .. [=[
		validations_array[j].ref_element = ]=]..tostring(v._attr.ref_element)..[=[;
]=];
		end
		code = code ..[=[
		validations_array[j].type = ']=]..tostring(v._attr.type)..[=[';
		validations_array[j].argument = obj;
		validations_array[j].argument_type = 'scalar';
		validations_array[j].addnl_argument = addnl_obj;
		j = j+1;
	end

]=];
			else
				code = code .. [=[
	validations_array[j] = {};
	validations_array[j].val_func = function(context, obj, addnl_obj)
		if (not (]=]..v.assertion._contained_value..[=[)) then
]=];
				local error_msg_inp_elements = '';
				if (v.error_def.input ~= nil) then
					for i,v in ipairs(v.error_def.input) do
						error_msg_inp_elements = error_msg_inp_elements..', tostring('..v..')';
					end
				end
				code = code ..[=[
			local msg = nil;
]=];
					if (v.error_def.error_code ~= nil) then
						code = code .. [=[
			msg = messages:format(']=]..v.error_def.error_code..[=[']=]..error_msg_inp_elements..[=[);
]=];
					else
						code = code .. [=[
			msg = ']=].. v.error_def.error_message..[=[';
]=];
					end
					code = code..[=[
			error_handler.raise_validation_error(-1, msg, debug.getinfo(1));
			return false;
]=];
				code = code ..[=[
		end
		return true;
	end
]=];
		if (v._attr.ref_element ~= nil) then
			code = code ..[=[
	validations_array[j].ref_element = ']=]..tostring(v._attr.ref_element)..[=[';
]=];
		else
			code = code .. [=[
	validations_array[j].ref_element = ]=]..tostring(v._attr.ref_element)..[=[;
]=];
		end
		code = code ..[=[
	validations_array[j].type = ']=]..tostring(v._attr.type)..[=[';
	validations_array[j].argument = obj;
	validations_array[j].argument_type = 'scalar';
	validations_array[j].addnl_argument = addnl_obj;
	j = j+1;

]=];
			end
		else
			if (v.validation._attr ~= nil and v.validation._attr.condition ~= nil) then
				code = code..[=[
	if (]=] .. v.validation._attr.condition..[=[) then
		validations_array[j] = {};
]=];
		if (v._attr.ref_element ~= nil) then
			code = code ..[=[
		validations_array[j].ref_element = ']=]..tostring(v._attr.ref_element)..[=[';
]=];
		else
			code = code .. [=[
		validations_array[j].ref_element = ]=]..tostring(v._attr.ref_element)..[=[;
]=];
		end
		code = code ..[=[
		validations_array[j].type = ']=]..tostring(v._attr.type)..[=[';
		local package = require(']=]..v.validation._attr.package..[=[');
		validations_array[j].val_func = package[']=]..v.validation._attr.method..[=['];
		validations_array[j].argument_type = ']=]..tostring(v.validation._attr.argument_type)..[=[';
		validations_array[j].argument = ]=]..tostring(v.validation._attr.argument)..[=[;
		validations_array[j].addnl_argument = ]=]..tostring(v.validation._attr.addnl_argument)..[=[;
		j = j+1;
	end

]=];
			else
				code = code .. [=[
	validations_array[j] = {};
]=];
		if (v._attr.ref_element ~= nil) then
			code = code ..[=[
	validations_array[j].ref_element = ']=]..tostring(v._attr.ref_element)..[=[';
]=];
		else
			code = code .. [=[
	validations_array[j].ref_element = ]=]..tostring(v._attr.ref_element)..[=[;
]=];
		end
		code = code ..[=[
	validations_array[j].type = ']=]..tostring(v._attr.type)..[=[';
	local package = require(']=]..v.validation._attr.package..[=[');
	validations_array[j].val_func = package[']=]..v.validation._attr.method..[=['];
	validations_array[j].argument_type = ']=]..tostring(v.validation._attr.argument_type)..[=[';
	validations_array[j].argument = ]=]..tostring(v.validation._attr.argument)..[=[;
	validations_array[j].addnl_argument = ]=]..tostring(v.validation._attr.addnl_argument)..[=[;
	j = j+1;

]=];
			end
		end
	end
	code = code..  [=[

	return validate_map.run(context, validations_array, obj, addnl_obj);

end

]=];
	local count = #code_output[rule_set._attr.package].functions;
	code_output[rule_set._attr.package].functions[count+1] = code;
end

local function generate_appinfo_for_typedef(typedef, module_name, code_output)
	require 'pl.pretty'.dump(typedef);
	local annot = typedef.annot;
	if (annot and annot ~= ffi.NULL) then
		local nss = { ns = 'http://www.w3.org/2001/XMLSchema', ns1 = 'http://evpoco.tekenlight.org/message_rules' }
		local annot_doc = xml.document_from_subtree(annot.content);
		local roots = annot_doc:search("/ns:annotation/ns:appinfo/ns1:app_info", nss);
		if (roots ~= nil and roots[1] ~= nil) then
			local appinfo_doc = xml.document_from_subtree(roots[1].node);
			local app_info_xml = (appinfo_doc:to_xml());
			local mhf = require("schema_processor")
			local ah = mhf:get_message_handler("app_info", "http://evpoco.tekenlight.org/message_rules")
			local app_info, msg = ah:from_xml(app_info_xml);
			if (app_info == nil) then
				--error(msg);
				print(msg);
				return;
			end
			if (app_info.rule_set ~= nil) then
				for i, rule_set in ipairs(app_info.rule_set) do
					generate_validation_routine(rule_set, module_name, code_output);
				end
			end
		else
			--error("Path ".."/ns:annotation/ns:appinfo/ns1:app_info".." not present in the document");
			print("Path ".."/ns:annotation/ns:appinfo/ns1:app_info".." not present in the document");
			return;
		end
	end

end

local function generate_appinfo_for_element(element, module_name, code_output)
	require 'pl.pretty'.dump(element);
	local annot = element.annot;
	if (annot and annot ~= ffi.NULL) then
		local nss = { ns = 'http://www.w3.org/2001/XMLSchema', ns1 = 'http://evpoco.tekenlight.org/message_rules' }
		local annot_doc = xml.document_from_subtree(annot.content);
		local roots = annot_doc:search("/ns:annotation/ns:appinfo/ns1:app_info", nss);
		if (roots ~= nil and roots[1] ~= nil) then
			local appinfo_doc = xml.document_from_subtree(roots[1].node);
			local app_info_xml = (appinfo_doc:to_xml());
			local mhf = require("schema_processor")
			local ah = mhf:get_message_handler("app_info", "http://evpoco.tekenlight.org/message_rules")
			local app_info, msg = ah:from_xml(app_info_xml);
			if (app_info == nil) then
				--error(msg);
				print(msg);
				return;
			end
			if (app_info.rule_set ~= nil) then
				for i, rule_set in ipairs(app_info.rule_set) do
					generate_validation_routine(rule_set, module_name, code_output);
				end
			end
		else
			--error("Path ".."/ns:annotation/ns:appinfo/ns1:app_info".." not present in the document");
			print("Path ".."/ns:annotation/ns:appinfo/ns1:app_info".." not present in the document");
			return;
		end
	end
end

local function generate_appinfo_for_mgd(mgr_def, module_name, code_output)
	require 'pl.pretty'.dump(mgr_def);
	local annot = mgr_def.annot;
	if (annot and annot ~= ffi.NULL) then
		local nss = { ns = 'http://www.w3.org/2001/XMLSchema', ns1 = 'http://evpoco.tekenlight.org/message_rules' }
		local annot_doc = xml.document_from_subtree(annot.content);
		local roots = annot_doc:search("/ns:annotation/ns:appinfo/ns1:app_info", nss);
		if (roots ~= nil and roots[1] ~= nil) then
			local appinfo_doc = xml.document_from_subtree(roots[1].node);
			local app_info_xml = (appinfo_doc:to_xml());
			local mhf = require("schema_processor")
			local ah = mhf:get_message_handler("app_info", "http://evpoco.tekenlight.org/message_rules")
			local app_info, msg = ah:from_xml(app_info_xml);
			if (app_info == nil) then
				--error(msg);
				print(msg);
				return;
			end
			if (app_info.rule_set ~= nil) then
				for i, rule_set in ipairs(app_info.rule_set) do
					generate_validation_routine(rule_set, module_name, code_output);
				end
			end
		else
			--error("Path ".."/ns:annotation/ns:appinfo/ns1:app_info".." not present in the document");
			print("Path ".."/ns:annotation/ns:appinfo/ns1:app_info".." not present in the document");
			return;
		end
	end
end

-- Main()
--
if (#arg ~= 2) then
	error("Usage generate_schema <xsd_file> <module_name>");
	os.exit(-1);
end
local xsd_name = arg[1];
local module_name = arg[2];
local db_schema_user = arg[3];

local code_output = {};

local schema = xsd:parse(xsd_name);

local elems = schema:get_element_decls();
if (elems ~= nil) then
	for _, v in ipairs(elems) do
		generate_appinfo_for_element(v, module_name, code_output);
	end
end

local types = schema:get_type_defs();
if (types ~= nil) then
	for _, v in ipairs(types) do
		generate_appinfo_for_typedef(v, module_name, code_output);
	end
end

local mgr_defs = schema:get_model_group_defs();
if (mgr_defs ~= nil) then
	for _, v in ipairs(mgr_defs) do
		generate_appinfo_for_mgd(v, module_name, code_output);
	end
end

write_to_file(code_output);

_G.handler_cache = nil;
