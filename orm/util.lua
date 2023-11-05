local util = {}


function util.get_key_params(tao, obj)
	local key_params = {};
	local count = 0;
	local key_col_names = tao.tbl_def.key_col_names;
	for i, col in ipairs(key_col_names) do
		count = count + 1;
		key_params[i] = obj[col];
	end
	return key_params, count;
end

function util.get_key_params_str(tao, obj)
	local key_param_str = '';
	local key_col_names = tao.tbl_def.key_col_names;
	for i, col in ipairs(key_col_names) do
		if (i == 1) then
			key_param_str = key_param_str .. col.." = " ..tostring(obj[col]);
		else
			key_param_str = key_param_str ..", ".. col .. " = " .. tostring(obj[col]);
		end
	end
	return key_param_str;
end



return util
