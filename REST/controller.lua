local URI_CLASS = require("uri");
local util = require('uri._util');
local cjson = require('cjson.safe');
local schema_processor = require("schema_processor");
local error_handler = require("lua_schema.error_handler");
local properties_funcs = platform.properties_funcs();
local tao_factory = require('service_utils.orm.tao_factory');
local jwt = require('service_utils.jwt.luajwt')

local rest_controller = {};

local supported_http_methods = { GET = 1, PUT = 1, POST = 1, DELETE = 1 };

local function isempty(s)
	return s == nil or s == '';
end

function split_path(uri_obj)
	local url_parts = {};
	local i = 0;
	local j = 0;

	for i,v in ipairs((require "pl.stringx".split(uri_obj:path(), '/'))) do
		if (i ~= 1) then
			url_parts[i-1] = v;
		end
	end
	return url_parts;
end

local function get_interface_class_path(url_parts)
	if (#url_parts < 2) then
		return nil;
	end
	local interface_path = nil;
	local n = #url_parts;
	local i = 0;
	while (i < (n-2)) do
		i = i + 1;
		if (interface_path == nil) then
			interface_path = url_parts[i];
		else
			interface_path = interface_path.."."..url_parts[i];
		end
	end
	if (i>0) then
		interface_path = interface_path..".".."idl";
	else
		interface_path = "idl";
	end
	i = i + 1;
	interface_path = interface_path.."."..url_parts[i].."_interface";
	local app_base_path = properties_funcs.get_string_property("service_utils.REST.controller.appBasePath");
	if (app_base_path ~= nil) then
		interface_path = app_base_path.."."..interface_path;
	end

	return interface_path;
end

local function get_module_path(url_parts)
	if (#url_parts < 2) then
		return nil;
	end
	local path = nil;
	local n = #url_parts;
	local i = 0;
	while (i < (n-2)) do
		i = i + 1;
		if (path == nil) then
			path = url_parts[i];
		else
			path = path.."."..url_parts[i];
		end
	end

	local app_base_path = properties_funcs.get_string_property("service_utils.REST.controller.appBasePath");
	if (app_base_path ~= nil) then
		path = app_base_path.."."..path;
	end

	return path;
end

local function deduce_action(url_parts, qp)
	if (#url_parts < 2) then
		return nil;
	end
	local path = nil;
	local n = #url_parts;
	local i = 0;
	while (i < (n-1)) do
		i = i + 1;
		if (path == nil) then
			path = url_parts[i];
		else
			path = path.."."..url_parts[i];
		end
	end

	local app_base_path = properties_funcs.get_string_property("service_utils.REST.controller.appBasePath");
	if (app_base_path ~= nil) then
		path = app_base_path.."."..path;
	end

	return path, url_parts[n];
end

local function make_db_connections(params)
	db_connections = {};
	for n, v in pairs(params) do
		local db_access = require(v.handler);
		local conn = db_access.open_connetion(table.unpack(v.params));
		db_connections[n] = { client_type = v.client_type, conn = conn, handler = db_access };
	end
	return db_connections;
end

local function begin_trans(uc)
	for n, v in pairs(uc.db_connections) do
		if (v.client_type == 'rdbms') then
			v.conn:begin();
		end
	end
end

local function reset_db_connections(uc)
	for n, v in pairs(uc.db_connections) do
		if (v.client_type == 'rdbms') then
			if (v.conn.exec) then v.conn:end_tran(); end
		end
	end
end

local function begin_transaction(req_processor_interface, func, uc)
	local flg = false;
	if (req_processor_interface.methods[func].transactional ~= nil
		and req_processor_interface.methods[func].transactional ~= nil
		and req_processor_interface.methods[func].transactional == true) then

		local i = 0;
		local name = nil;
		for n,v in pairs(uc.db_connections) do
			i = i + 1;
			if (i == 1) then
				name = n;
			else
				break;
			end
		end
		if (i == 1) then
			uc.db_connections[name].conn:begin();
			flg = true;
		elseif (i>1) then
			if (req_processor_interface.methods[func].db_schema_name == nil) then
				error("CONNECTION NAME MUST BE SPECIFIED FOR "..func.." IF TRANSACTIONA CONTROL IS REQUIRED");
				return false;
			else
				uc.db_connections[req_processor_interface.methods[func].db_schema_name].conn:begin();
				flg = true;
			end
		end
	end
	return flg;
end

local function end_transaction(req_processor_interface, func, uc, status)
	local flg = false;

	local i = 0;
	local name = nil;
	for n,v in pairs(uc.db_connections) do
		i = i + 1;
		if (i == 1) then
			name = n;
		else
			break;
		end
	end
	if (i == 1) then
		uc.db_connections[name].conn:close_open_cursors();
		if (req_processor_interface.methods[func].transactional == true) then
			if (status) then
				uc.db_connections[name].conn:commit();
			else
				uc.db_connections[name].conn:rollback();
			end
		end
		flg = true;
	elseif (i>1) then
		if (req_processor_interface.methods[func].db_schema_name == nil) then
			error("CONNECTION NAME MUST BE SPECIFIED FOR "..func.." IF TRANSACTIONA CONTROL IS REQUIRED");
			return false
		else
			uc.db_connections[req_processor_interface.methods[func].db_schema_name].conn:close_open_cursors();
			if (req_processor_interface.methods[func].transactional == true) then
				if (status) then
					uc.db_connections[req_processor_interface.methods[func].db_schema_name].conn:commit();
					flg = true;
				else
					uc.db_connections[req_processor_interface.methods[func].db_schema_name].conn:rollback();
					flg = true;
				end
			end
		end
	end

	return flg;
end

local function does_request_need_auth(request, url_parts)
	local json_parser = cjson.new();
	local prop_str = properties_funcs.get_string_property("service_utils.REST.controller.noAuthUrls");
	if (prop_str == nil) then
		return true;
	end
	local obj, msg = json_parser.decode(prop_str);
	if (obj == nil) then
		return true;
	end
	local url = (URI_CLASS:new(request:get_uri())):path();
	for i,v in ipairs(obj.urls) do
		if (v == url) then
			return false;
		end
	end

	return true;
end

local function prepare_uc(request, url_parts)
	local uc = require('service_utils.common.user_context').new();

	local key = properties_funcs.get_string_property("platform.jwtSignatureKey");

	local hdr_flds = request:get_hdr_fields();
	local jwt_token = hdr_flds['X-Auth'];
	local offset = 1;

	--[[
	--jwt.decode does the auth as well
	-- It basically decodes the token as well as verifies the signature
	-- The bearer of the token is the authorized user
	--]]
	local token, msg = jwt.decode(jwt_token, key, true);
	if (token ~= nil) then
		token.exp_time = os.date('%Y-%m-%d %T', token.exp);
		token.nbf_time = os.date('%Y-%m-%d %T', token.nbf);
		uc.uid = ffi.cast("int64_t", tonumber(token.uid));
		uc.token = token;
		local now = os.time();
	else
		if (does_request_need_auth(request, url_parts)) then
			return nil, msg;
		else
			uc.uid = 0;
		end
	end

	--[[
	-- More functionality in terms of whether the user has permission to 
	-- perform a specific action or if the user has access to the 
	-- database that the request is trying to access etc...
	-- Are to be implemented here.
	--]]

	uc.module_path = get_module_path(url_parts);
	uc.access_token = jwt_token;

	return uc;
end

local invoke_func = function(request, req_processor_interface, req_processor, func, url_parts, qp, obj)
	local proc_stat, status, out_obj, flg;
	local http_method = request:get_method();
	local ret = 200;

	local uc, msg = prepare_uc(request, url_parts);
	if (uc == nil) then
		if (msg == nil) then
			out_obj = { error_message = 'Bad Request: Invalid Access token or Access Token not present' };
		else
			out_obj = { error_message = 'Bad Request: Invalid Access token or Access Token not present: '..msg };
		end
		return false, out_obj, 401;
	end

	if (supported_http_methods[http_method] == nil) then
		out_obj = { error_message = 'Unsupported HTTP method' };
		return false, out_obj, 400;
	end
	tao_factory.init(uc);
	local db_init_done = false;
	if (nil ~= req_processor_interface.get_db_connection_params) then
		local db_params = req_processor_interface:get_db_connection_params();
		if (nil ~= db_params) then
			uc.db_connections = make_db_connections(db_params);
			if (false == begin_transaction(req_processor_interface, func, uc)) then
				--begin_trans(uc);
			else
				db_init_done = true;
			end
		end
	end
	do
		error_handler.init();
		if (obj == nil) then
			proc_stat, status, out_obj = pcall(req_processor[func], req_processor, uc, qp);
		else
			proc_stat, status, out_obj = pcall(req_processor[func], req_processor, uc, qp, obj);
		end
	end
	local message_validation_context = error_handler.reset_init();
	if (not proc_stat) then
		-- since there is a fatal error, it is a panic and thus
		-- this error will override any other error that was previously generated.
		message_validation_context.status.success = false;
		message_validation_context.status.error_no = -1;
		message_validation_context.status.error_message = status; -- pcall returns the message as second return value
		status = false;
	end
	if (db_init_done) then
		local flg = end_transaction(req_processor_interface, func, uc, status);
		reset_db_connections(uc);
	end
	if (not status) then
		print(debug.getinfo(1).source, debug.getinfo(1).currentline);
		require 'pl.pretty'.dump(message_validation_context);
		print(debug.getinfo(1).source, debug.getinfo(1).currentline);
		out_obj = {};
		out_obj.error_message = message_validation_context.status.error_message;
		if (message_validation_context.status.field_path ~= nil and
			message_validation_context.status.field_path ~= '') then
			out_obj.field_path = message_validation_context.status.field_path;
		end
	end
	if ((not proc_stat) or (not status)) then ret = 500; end
	return status, out_obj, ret;
end

local get_query_params = function(query)
	local qp = {};
	local i = 0;

	if (query == nil) then
		return qp;
	end

	local q = util.uri_decode(query);

	for i,v in ipairs((require "pl.stringx".split(q, '&'))) do
		for p, q in string.gmatch(v, "([^=]+)=([^=]+)") do
			qp[p] = q;
		end
	end
	return qp;
end

local function validate_query_params(req_processor_interface, qp, func)
	local new_qp = {};
	local query_params = req_processor_interface.methods[func].message.query_params;
	for n,v in pairs(query_params) do
		local msg_handler = schema_processor:get_message_handler(v.name, v.ns);
		local value = qp[v.name];
		if (value ~= nil) then
			value = msg_handler.type_handler:to_type(nil, qp[v.name]);
			if (value == nil) then
				return flg, msg;
			end
			local flg, msg = msg_handler:validate(value);
			if (not flg) then
				return flg, msg;
			end
			new_qp[v.name] = value;
		else
			if (v.mandatory ~= nil and v.mandatory) then
				msg = 'Field {'..v.name..'} must be present in query params';
				return false, msg;
			end
		end
	end
	--[[
	--We can put a hack here for all other query param values
	--present in qp for unit testing
	--]]

	return true, new_qp;
end

rest_controller.handle_request = function (request, response)
	local json_output, msg;
	local flg, json_input = pcall(request.get_message_body_str, request);
	local uri = URI_CLASS:new(request:get_uri());
	local url_parts = split_path(uri);
	local qp = get_query_params(uri:query());

	response:set_hdr_field("Access-Control-Allow-Origin", "*");
	response:set_hdr_field("Access-Control-Allow-Methods", "*");
	response:set_hdr_field("Access-Control-Allow-Headers", "*");
	response:set_hdr_field("Access-Control-Allow-Credentials", "true");

	--[[ In case of CORS browsers send an empty request with the below headers first.
	--It is expected that the server responds 200 Ok if the request is acceptable
	--subsequent requenst will have content
	local hdr_flds = request:get_hdr_fields();
	if ((request:get_method() == "OPTIONS") and
		((hdr_flds["Access-Control-Request-Headers"] ~= nil or hdr_flds["Access-Control-Request-Method"] ~= nil)) ) then
		response:set_status(200);
		response:set_chunked_trfencoding(true);
		response:set_content_type("application/json");
		response:send();
		response:write("");
		return;
	end
	--]]

	local output_obj = {};

	local json_parser = cjson.new();
	if (json_input == nil or json_input == '') then
		json_input = nil;
	end
	local class_name, func = deduce_action(url_parts, qp);
	if (class_name == nil or func == nil) then
		local err = 'Unable to deduce Controller class name and/or method';
		response:set_status(400);
		response:set_chunked_trfencoding(true);
		response:set_content_type("application/json");
		response:send();
		output_obj.message = err;
		local flg, json_output, err = pcall(json_parser.encode, output_obj);
		response:write(json_output);
		response:write('\n');
		return ;
	end

	local req_processor = require(class_name);
	local interface_class_name = get_interface_class_path(url_parts);
	local req_processor_interface = require(interface_class_name);


	local obj, msg;
	local error_cond = 0;
	do --{
		--if (req_processor.message[func] == nil) then
		if (req_processor_interface.methods[func] == nil) then
			flg = false;
			obj = nil;
			msg = "Invalid function "..func;
			error_cond = 1;
		elseif (req_processor_interface.methods[func].message == nil) then
			flg = false;
			obj = nil;
			msg = "Invalid function "..func;
			error_cond = 2;
		else
			--local t = req_processor.message[func][1];
			flg, qp = validate_query_params(req_processor_interface, qp, func);
			if (not flg) then
				flg = false;
				obj = nil;
				msg = qp;
				error_cond = 3;
			else
				local t = req_processor_interface.methods[func].message.in_out[1];
				if (json_input ~= nil) then
					if (t ~= nil) then
						local msg_handler = schema_processor:get_message_handler(t.name, t.ns);
						if (msg_handler == nil) then
							flg = false;
							obj = nil;
							msg = "Unable to find message schema handler";
							error_cond = 4;
						else
							flg = true;
							obj, msg = msg_handler:from_json(json_input);
							if (obj == nil) then
								flg = false;
								error_cond = 6;
							end
						end
					else
						--[[
						--
						-- We can put a hack here for unit testing
						--
						--]]
						flg = false;
						obj = nil;
						msg = "Unable to derserialize JSON, schema not specified";
						error_cond = 7;
					end
				else
					if (t ~= nil) then
						flg = false;
						msg = "NULL Message received, while expecting one";
						error_cond = 8;
					else
						flg = true;
					end
					obj = nil;
				end
			end
		end
	end --}
	local successfully_processed = false;
	if (not flg) then
		output_obj.error_message = msg;
		local flg, json_output, err = pcall(json_parser.encode, output_obj);
		local status = 400;
		response:set_status(status);
		response:set_chunked_trfencoding(true);
		response:set_content_type("application/json");
		response:set_hdr_field("X-msg", json_output);
		response:send();
		response:write(json_output);
	else
		--[[
		local hdr_flds = request:get_hdr_fields();
		print(debug.getinfo(1).source, debug.getinfo(1).currentline);
		require 'pl.pretty'.dump(hdr_flds);
		print(debug.getinfo(1).source, debug.getinfo(1).currentline);
		--]]
		local status, table_output, ret = invoke_func(request, req_processor_interface, req_processor, func, url_parts, qp, obj)
		if (type(ret) ~= 'number' or ret < 200 or ret > 550) then
			error('Invalid error code returned '..ret);
		end
		if (not status) then
			response:set_status(ret);
			local out = table_output
			if (out == nil) then
				output_obj.error_message = "Unknown processing error";
			else
				output_obj = table_output;
			end
			response:set_status(ret);
			response:set_chunked_trfencoding(true);
			response:set_content_type("application/json");
			response:send();
			local flg, json_output, out = pcall(json_parser.encode, output_obj);
			response:set_hdr_field("X-msg", json_output);
			response:write(json_output);
		else
			successfully_processed = true;
			response:set_status(200);
			--if (req_processor.message[func][2] ~= nil) then
			if (req_processor_interface.methods[func].message.in_out[2] ~= nil) then
				if (table_output ~= nil) then
					local t = req_processor_interface.methods[func].message.in_out[2];
					local msg_handler = schema_processor:get_message_handler(t.name, t.ns);
					json_output, msg = msg_handler:to_json(table_output);
					if (json_output ~= nil) then
						successfully_processed = false;
					end
				else
					-- OOPS function returned outut in an unexpected format
					local msg = [=[Invalid output from function {]=]..class_name.."."..func..[=[}]=];
					output_obj.error_message = msg;
					msg = nil;
					flg, json_output, msg = pcall(json_parser.encode, output_obj);
					response:set_status(500);
					successfully_processed = false;
				end
			else
				if (table_output ~= nil) then
					flg, json_output, msg = pcall(json_parser.encode, table_output);
					if (not flg) then successfully_processed = false; end
				end
			end
			if (msg ~= nil) then
				output_obj.error_message = msg;
				flg, json_output, msg = pcall(json_parser.encode, output_obj);
			end
			if (json_output == nil or json_output == '') then
				json_output = '{}';
			end
			response:set_chunked_trfencoding(true);
			response:set_content_type("application/json");
			response:send();
			response:write(json_output);
		end
	end
	response:write('\n');
	if (successfully_processed) then
		--[[
		-- POST_PROCESSING
		--
		-- THIS IS THE PLACE WHERE WE HAVE SENT RESPONSE FOR SUCCESSFUL PROCESSING
		-- HERE IS WHERE WE SHOULD CARRYOUT POST PROCESSING EXECUTION, IT IT IS SET
		--
		--]]
	end

	return ;
end


return rest_controller;
