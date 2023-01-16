local rest_sample = {};

rest_sample.fetch = function (self, context, query_params)
	local data = { name = "Sherlock Holmes" , address = "221B, Baker Street, London" }
	return true, data;
end

rest_sample.add = function (self, context, query_params, rest_sample_struct)
	print(debug.getinfo(1).source, debug.getinfo(1).currentline);
	require 'pl.pretty'.dump(rest_sample_struct);
	print(debug.getinfo(1).source, debug.getinfo(1).currentline);
    return true;

end

return rest_sample; 

