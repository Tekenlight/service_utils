local error_handler = require('lua_schema.error_handler');

local validate_map = {};

validate_map.run = function(context, map, data, additional_data)
	-- Fist pass for independent validations
	local status = true;
	for i, val in ipairs(map) do
		if (val.type == 'independent') then
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
							ae_val = (val.ae_condition(context, i, val.argument, val.addnl_argument) == true);
						end
						error_handler.push_element(i);
						if (ae_val == true) then
							local flg = val.val_func(context, val.argument[i], val.addnl_argument);
							if (not flg) then
								status = flg;
							end
						end
						error_handler.pop_element();
					end
					assert(num_elements == #(val.argument));
				else
					local flg = val.val_func(context, val.argument, val.addnl_argument);
					if (not flg) then
						status = flg;
					end
				end
				if (val.ref_element ~= nil) then error_handler.pop_element(); end
			end
		end
	end
	if (not status) then
		return false;
	end

	-- Second pass for dependent validations
	for i, val in ipairs(map) do
		if (val.type == 'dependent') then
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
							ae_val = (val.ae_condition(context, i, val.argument, val.addnl_argument) == true);
						end
						error_handler.push_element(i);
						if (ae_val == true) then
							local flg = val.val_func(context, val.argument[i], val.addnl_argument);
							if (not flg) then
								error_handler.pop_element();
								if (val.ref_element ~= nil) then error_handler.pop_element(); end
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
						return false;
					end
				end
				if (val.ref_element ~= nil) then error_handler.pop_element(); end
			end
		end
	end

	return true;
end

return validate_map;

