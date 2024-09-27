local error_handler = require('lua_schema.error_handler');

local validate_map = {};
local depth = 0;
local val_debug = false;

local get_tabs = function()
	local s_tabs = "";
	for i = 1, depth do
		s_tabs = s_tabs .. "	";
	end
	return s_tabs;
end

validate_map.run = function(context, map, data, additional_data)
	-- Fist pass for independent validations
	local status = true;
	depth = depth + 1;
	if (depth == 1) then
		--print("BEGIN MAIN_VAL {");
	end
	local tabs = get_tabs();
	for i, val in ipairs(map) do
		if (val.type == 'independent') then
			local flg = true;;
			--print("BEGIN VAL index="..i.." {")
			--require 'pl.pretty'.dump(val);
			if (val.argument ~= nil) then
				if (val.ref_element ~= nil) then error_handler.push_element(val.ref_element); end
				if (val.argument_type == 'array') then
					assert(type(val.argument) == 'table');
					local num_elements = 0;
					for i,v in pairs(val.argument) do
						num_elements = num_elements + 1;
						assert(type(i) == 'number');
						--error_handler.push_element('['..i..']');
						local ae_val = true;
						if (val.ae_condition ~= nil) then
							ae_val = (val.ae_condition(context, i, val.argument, val.main_obj, val.addnl_argument) == true);
						end
						error_handler.push_element(i);
						if (ae_val == true) then
							flg = val.val_func(context, val.argument[i], val.addnl_argument);
							if (not flg) then
                                if (val_debug) then
                                    print(debug.getinfo(1).source, debug.getinfo(1).currentline);
                                    print("falied validation");
                                    require 'pl.pretty'.dump(val)
                                    print(debug.getinfo(1).source, debug.getinfo(1).currentline);
                                end
								status = flg;
							end
						end
						error_handler.pop_element();
					end
					assert(num_elements == #(val.argument));
				else
					flg = val.val_func(context, val.argument, val.addnl_argument);
					if (not flg) then
                        if (val_debug) then
                            print(debug.getinfo(1).source, debug.getinfo(1).currentline);
                            print("falied validation");
                            require 'pl.pretty'.dump(val)
                            print(debug.getinfo(1).source, debug.getinfo(1).currentline);
                        end
						status = flg;
					end
				end
				if (val.ref_element ~= nil) then error_handler.pop_element(); end
			end
			--print("VAL status ["..tostring(flg)..", "..tostring(status).."] }");
		end
	end
	if (not status) then
		if (depth == 1) then
			--print("END MAIN_VAL ["..tostring(status).."] }");
		end
		depth = depth - 1;
		return false;
	end

	-- Second pass for dependent validations
	for i, val in ipairs(map) do
		if (val.type == 'dependent') then
			--print("BEGIN VAL index="..i.." {")
			--require 'pl.pretty'.dump(val);
			if (val.argument ~= nil) then
				if (val.ref_element ~= nil) then error_handler.push_element(val.ref_element); end
				if (val.argument_type == 'array') then
					assert(type(val.argument) == 'table');
					local num_elements = 0;
					for i,v in pairs(val.argument) do
						num_elements = num_elements + 1;
						assert(type(i) == 'number');
						--error_handler.push_element('['..i..']');
						local ae_val = true;
						if (val.ae_condition ~= nil) then
							ae_val = (val.ae_condition(context, i, val.argument, val.main_obj, val.addnl_argument) == true);
						end
						error_handler.push_element(i);
						if (ae_val == true) then
							local flg = val.val_func(context, val.argument[i], val.addnl_argument);
							if (not flg) then
								error_handler.pop_element();
								if (val.ref_element ~= nil) then error_handler.pop_element(); end
								if (depth == 1) then
									--print("END MAIN_VAL ["..tostring(status).."] }");
								end
								depth = depth - 1;
                                if (val_debug) then
                                    print(debug.getinfo(1).source, debug.getinfo(1).currentline);
                                    print("falied validation");
                                    require 'pl.pretty'.dump(val)
                                    print(debug.getinfo(1).source, debug.getinfo(1).currentline);
                                end
								return false;
							end
						end
						error_handler.pop_element();
					end
					assert(num_elements == #(val.argument));
				else
					local flg = val.val_func(context, val.argument, val.addnl_argument);
					if (not flg) then
						if (val.ref_element ~= nil) then error_handler.pop_element(); end
						if (depth == 1) then
							--print("END MAIN_VAL ["..tostring(status).."] }");
						end
                        if (val_debug) then
                            print(debug.getinfo(1).source, debug.getinfo(1).currentline);
                            print("falied validation");
                            require 'pl.pretty'.dump(val)
                            print(debug.getinfo(1).source, debug.getinfo(1).currentline);
                        end
						return false;
					end
				end
				if (val.ref_element ~= nil) then error_handler.pop_element(); end
			end
			--print("VAL status ["..tostring(status).."] }");
		end
	end

	if (depth == 1) then
		--print("END MAIN_VAL ["..tostring(status).."] }");
	end
	depth = depth - 1;
	return true;
end

return validate_map;

