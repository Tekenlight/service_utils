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
					for i,v in ipairs(val.argument) do
						--error_handler.push_element('['..i..']');
						error_handler.push_element(i);
						do
							local flg = val.val_func(context, val.argument[i], val.addnl_argument);
							if (not flg) then
								status = flg;
							end
						end
						error_handler.pop_element();
					end
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
					for i,v in ipairs(val.argument) do
						--error_handler.push_element('['..i..']');
						error_handler.push_element(i);
						do
							local flg = val.val_func(context, val.argument[i], val.addnl_argument);
							if (not flg) then
								error_handler.pop_element();
								if (val.ref_element ~= nil) then error_handler.pop_element(); end
								return false;
							end
						end
						error_handler.pop_element();
					end
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

