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

function include_xsd_files(directory)
	local directory_parts = stringx.split(directory, "/");
	local root_path = '';
	local count = 1;
	while(count <= #directory_parts) do
		root_path = root_path..directory_parts[count]..".";
		count = count + 1;
	end
	local i, t, popen = 0, {}, io.popen
	local pfile = popen('ls -1 '..directory)
		for folder in pfile:lines() do
		    local pfile1 = popen('ls -1 '..directory..folder..' |grep _xml.lua');
		    for filename in pfile1:lines() do
				i = i + 1;
				t[i] = filename;
				filename = filename:gsub(".lua","");
				local output_file_path = root_path..folder.."."..filename;
				local mapping = require(output_file_path);
				for i, v in pairs(mapping) do
					xsd_mapping = "[\""..i.."\"] = ".."\""..v.."\"";
					table.insert(basic_file.build.modules, xsd_mapping);
				end
			end
		end
end

function include_idl_files(directory)
	local i, t, popen = 0, {}, io.popen
    local pfile = popen('ls -1 '..directory)
    for folder in pfile:lines() do
		local pfile1 = popen('ls -1 '..directory.."/"..folder.."| grep .xml")
		for filename in pfile1:lines() do
		print(filename);
        	i = i + 1
			t[i] = filename;
			print(filename);
			filename = filename:gsub("%.xml","");
			filename = filename.."_interface_xml";
			local mapping = require("build.biop."..folder..".idl."..filename);
			for i, v in pairs(mapping) do
            	idl_mapping = "[\""..i.."\"] = ".."\""..v.."\"";
            	table.insert(basic_file.build.modules, idl_mapping);
        	end
    	end
	end
end

function include_val_files(directory)
    local i, t, popen = 0, {}, io.popen
    local pfile = popen('ls -a '..directory..' |grep .xml')
    for filename in pfile:lines() do
        i = i + 1
        t[i] = filename;
		local mapping = require("build.biop.registrar.val."..filename:gsub("%.xml", "").."idations_xml");
		for i, v in pairs(mapping) do
			val_mapping = "[\""..i.."\"] = ".."\""..v.."\"";
		    table.insert(basic_file.build.modules, val_mapping);
	    end
    end
    pfile:close()
end

function include_ddl_files(directory)
    local i, t, popen = 0, {}, io.popen
    local pfile = popen('ls -a '..directory..' |grep .xml');
    for filename in pfile:lines() do
        i = i + 1
        t[i] = filename;
        local mapping = require("build.biop.registrar.tbl."..filename:gsub("%.xml", "").."_xml");
		for i, v in pairs(mapping) do
			ddl_mapping = "[\""..i.."\"] = ".."\""..v.."\"";
        	table.insert(basic_file.build.modules, ddl_mapping);
		end
    end
    pfile:close()
end

function include_src_files(directory)
    local i, t, popen = 0, {}, io.popen
    local pfile = popen('ls -a '..directory..' |grep .lua');
    for filename in pfile:lines() do
        i = i + 1
        t[i] = filename;
		local src_mapping = '[\"biop.registrar.'..filename:gsub("%.lua", "").."\"] = ".."\"src/"..filename.."\"";
        table.insert(basic_file.build.modules, src_mapping);
    end
    pfile:close()
end

if(folder_exists("idl/") == true) then
	include_idl_files("idl");
end

if(folder_exists("build/com/biop") == true) then
	include_xsd_files("build/com/biop/");
end

if(folder_exists("val") == true) then
	include_val_files("val/");
end

if(folder_exists("ddl") == true) then
	include_ddl_files("ddl/");
end

if(folder_exists("src") == true) then
	include_src_files("src/");
end

function write_rockspec(basic_file, filename)
	local file = io.open(filename,"w+");
	--Write rockspec file with basic info
	file:write("package = \""..basic_file.package.."\"\nversion = \""..basic_file.version.."\"\n\ndescription = {\n\tsummary = \""..basic_file.description.summary.."\",\n\tdetailed = [[\n"..basic_file.description.detailed.."]],\n\tlicense = \""..basic_file.description.license.."\",\n\thomepage = \""..basic_file.description.homepage.."\"\n}\n\ndependencies = {\n\t\""..basic_file.dependencies[1].."\"\n}\n\nsource = {\n\turl = \""..basic_file.source.url.."\",\n\ttag = \""..basic_file.source.tag.."\",\n}\n\nbuild = {\n\ttype = \""..basic_file.build.type.."\",\n\tmodules = {\n");
	--Write the appended modules part to the rockspec file
	local j = 1;
    for i, v in pairs(basic_file.build.modules) do
		j=j+1;
		if(j < #basic_file.build.modules) then
			file:write("\t\t"..v..",\n");
		else if(j == #basic_file.build.modules) then
			file:write("\t\t"..v);
		end
	end
end
	file:write("\n  }\n}");
  
  print("Rockspec created "..filename);
  return;
end

local File=arg[1];


write_rockspec(basic_file, File);
