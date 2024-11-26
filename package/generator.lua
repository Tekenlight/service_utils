local basic_file = require("rockspec");
local stringx = require("pl.stringx");

function folder_exists(folder)
	local ret = (os.execute("[ -d "..folder.." ] && exit 0"));
	if(ret == true) then
		return true
	else
		return false
	end
end

function include_files(directory)
	local i, t = 0, {};
	local pfile = io.popen('ls -1 '..directory)
	local formatted_directory_parts = stringx.split(directory,"/");
	local formatted_directory = '';
	local j = 1;
	while(j <= #formatted_directory_parts) do
		if(formatted_directory == '') then
			formatted_directory = formatted_directory_parts[j];
		else
			formatted_directory = formatted_directory.."."..formatted_directory_parts[j];
		end
		j = j + 1;
	end
	for filename in pfile:lines() do
		i = i + 1;
		t[i] = filename;
		local mapping = require(formatted_directory.."."..filename:gsub(".lua",""));
		for i, v in pairs(mapping) do
			mapping = "[\""..i.."\"] = ".."\""..v.."\"";
			table.insert(basic_file.build.modules, mapping);	
		end
	end
    pfile:close()
end

function include_src_files(directory, submodule)
	local dir;
	local package_name;
	if(submodule ~= nil) then
		package_name = basic_file.package.."."..submodule;
		dir = submodule.."/";
	else 
		package_name = basic_file.package;
		dir = "";
	end
    local i, t = 0, {}
    local pfile = io.popen([[ls -1 ]]..directory..[[ |grep '.lua']]);
	for filename in pfile:lines() do
        i = i + 1
        t[i] = filename;
		local src_mapping;
		if (basic_file.product ~= nil) then
			src_mapping = '[\"'..basic_file.product..'.'..
				package_name.."."..filename:gsub("%.lua", "").."\"] = ".."\""..dir.."src/"..filename.."\"";
		else
			src_mapping = '[\"'..
				package_name.."."..filename:gsub("%.lua", "").."\"] = ".."\""..dir.."src/"..filename.."\"";
		end
        table.insert(basic_file.build.modules, src_mapping);
    end
    pfile:close()
end

local function write_rockspec(basic_file, filename)
	local file = io.open(filename,"w+");
	--Write rockspec file with basic info
	--file:write("rockspec_format = \"3.0\"\n");
	file:write("package = \""..basic_file.package.."\"\n");
	file:write("version = \""..basic_file.version.."\"\n");
	file:write("\ndescription = {\n");
	file:write("\tsummary = \""..basic_file.description.summary.."\",\n");
	file:write("\tdetailed = [[\n"..basic_file.description.detailed.."]],\n");
	file:write("\tlicense = \""..basic_file.description.license.."\",\n");
	file:write("\thomepage = \""..basic_file.description.homepage.."\"\n}\n\n");
	file:write("dependencies = {\n");
	for i,v in ipairs(basic_file.dependencies) do
		if (i == 1) then
			file:write("\t\""..v.."\"\n");
		else
			file:write("\t,\""..v.."\"\n");
		end
	end
	file:write("}\n\n");
    if (basic_file.external_dependencies ~= nil) then
        file:write("external_dependencies = {\n");
        local __i__ = 1;
        for n,v in pairs(basic_file.external_dependencies) do
            if (__i__ == 1) then
                __i__ = __i__ + 1;
                file:write("\t[\""..n.."\"] = {\n");
            else
                file:write("\t,[\""..n.."\"] = {\n");
            end
            local __ii__ = 1;
            for nn,vv in pairs(v) do
                if (__ii__ == 1) then
                    __ii__ = __ii__ + 1;
                    file:write("\t\t[\""..nn.."\"] = \""..vv.."\"\n");
                else
                    file:write("\t\t,[\""..nn.."\"] = \""..vv.."\"\n");
                end
            end
            file:write("\t}\n"); -- }
        end
        file:write("}\n\n");
    end
	file:write("source = {\n\turl = \""..basic_file.source.url.."\",\n");
	file:write("\ttag = \""..basic_file.source.tag.."\",\n}\n\n");
	file:write("build = {\n");
	file:write("\ttype = \""..basic_file.build.type.."\",\n");
	file:write("\tmodules = {\n");
	--Write the appended modules part to the rockspec file
	local j = 1;
    for i, v in pairs(basic_file.build.modules) do
		if(j < #basic_file.build.modules) then
			file:write("\t\t"..v..",\n");
		elseif(j == #basic_file.build.modules) then
			file:write("\t\t"..v);
		end
		j=j+1;
	end

	file:write("\n  }\n}");
  
	print("Rockspec created "..filename);
	return;
end

if(folder_exists("build/output_files/idl") == true) then
	include_files("build/output_files/idl");
end

if(folder_exists("build/output_files/xsd") == true) then
	include_files("build/output_files/xsd");
end

if(folder_exists("build/output_files/val") == true) then
	include_files("build/output_files/val");
end

if(folder_exists("build/output_files/ddl") == true) then
	include_files("build/output_files/ddl");
end

if(folder_exists("build/src") == true) then
	include_src_files("build/src");
end

if(basic_file.list_of_submodules ~= nil) then
    for i=1, #basic_file.list_of_submodules do
        file_path = "build/"..basic_file.list_of_submodules[i].."/src";
		include_src_files(file_path, basic_file.list_of_submodules[i]);
    end
end


local File=arg[1];


write_rockspec(basic_file, File);


return;


