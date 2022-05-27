local stringx = require('pl.stringx');
local basic_file = require('rockspec');
local basic_stuff = require("lua_schema.basic_stuff");
local xmlua = require("xmlua");
local xsd = xmlua.XSD.new();
local all_target = {};
local all_source = {};
local val_target = {};
local val_source = {};
local ddl_target = {};
local ddl_source = {};
local src_target = {};
local src_source = {};
local sql_target = {};
local sql_source = {};
local idl_target = {};
local idl_source = {};
local registrar_xsd_target = {};
local registrar_xsd_source = {};
local aaa_xsd_target = {};
local aaa_xsd_source = {};

function exists(file)
   local ok, err, code = os.rename(file, file)
   if not ok then
      if code == 13 then
         -- Permission denied, but it exists
         return true
      end
   end
   return ok, err
end

function add_xsd_target(xsd_file_name)
   local schema = xsd:parse(xsd_file_name);
   local elems = schema:get_element_decls();
   local types = schema:get_type_defs();
   for _,v in ipairs(elems) do
	   local source_filename = '';
	   if(basic_stuff.package_name_from_uri(v.ns):gsub("com.biop.","") == 'registrar') then
		   source_filename = 'registrar_data_structures.xsd';
		   table.insert(registrar_xsd_source, source_filename);
	   elseif(basic_stuff.package_name_from_uri(v.ns):gsub("com.biop.","") == 'aaa') then
		   source_filename = 'aaa_data_structures.xsd';
		   table.insert(aaa_xsd_source, source_filename);
	   end
	   local formatted_path_parts = stringx.split(basic_stuff.package_name_from_uri(v.ns), ".");
	   local i = 1;
	   local formatted_path = '';
	   while(i <= #formatted_path_parts) do
		   if(i == #formatted_path_parts) then
			   formatted_path = formatted_path..formatted_path_parts[i];
	    	else
				formatted_path = formatted_path..formatted_path_parts[i].."/";
			end
			i = i+1;
	    end
		local target_filename = "build/"..formatted_path.."/"..v.name.."_xml.lua";
		if(basic_stuff.package_name_from_uri(v.ns):gsub("com.biop.","") == 'registrar') then
			table.insert(registrar_xsd_target, target_filename);
		elseif(basic_stuff.package_name_from_uri(v.ns):gsub("com.biop.","") == 'aaa') then
			table.insert(aaa_xsd_target, target_filename);
		end
   end
end

if(exists("xsd/")==true) then
	add_xsd_target("xsd/registrar_data_structures.xsd")
	add_xsd_target("xsd/aaa_data_structures.xsd")
end

function add_target(directory)
    local i, t, popen = 0, {}, io.popen;
	local pfile;
	if(directory == "val/" or directory == "ddl/" or directory == 'idl/aaa/' or directory == 'idl/registrar/') then
    	pfile = popen('ls -a '..directory..' |grep .xml')
	elseif(directory == "src/") then
    	pfile = popen('ls -a '..directory..' |grep .lua')
	end
    for filename in pfile:lines() do
        i = i + 1
        t[i] = filename;
		if(directory == "val/") then
			local source_filename = directory..filename;
			local target_filename = "build/biop/registrar/"..directory..filename:gsub("%.xml", "").."idations_xml.lua";
			table.insert(val_target, target_filename);
			table.insert(val_source, source_filename);
		elseif(directory == "ddl/") then
			local source_filename = directory..filename;
			local target_filename = "build/biop/registrar/tbl/"..filename:gsub("%.xml", "").."_xml.lua";
			table.insert(ddl_target, target_filename);
			table.insert(ddl_source, source_filename);
	    elseif(directory == "src/") then
			local source_filename = directory..filename;
			local target_filename = "build/"..directory..filename;
			table.insert(src_target, target_filename);
			table.insert(src_source, source_filename);
		elseif(directory == "idl/aaa/" or directory == "idl/registrar/") then
			local source_filename = directory..filename;
			local target_filename = "build/biop"..directory:gsub("idl", "").."idl/"..filename:gsub(".xml","").."_interface_xml.lua";
			table.insert(idl_target, target_filename);
			table.insert(idl_source, source_filename);
		end
    end
    pfile:close()
    return;
end
function add_leftout_target(directory)
	local i, t, popen = 0, {}, io.popen;
	local pfile = popen('ls -a '..directory..' |grep .sql');
	for filename in pfile:lines() do 
		i = i + 1;
		t[i] = filename;
		local source_filename = directory..filename;
		local target_filename = "build/sql/"..filename;
		table.insert(sql_target, target_filename);
		table.insert(sql_source, source_filename);
	end
	pfile:close()
	return;
end

if(exists("val/")==true) then
	add_target("val/");
end

if(exists("ddl/")==true) then
	add_target("ddl/");
end

if(exists("src/")==true) then
	add_target("src/");
end

if(exists("ddl/")==true) then
	add_leftout_target("ddl/");
end

if(exists("idl/") == true) then
	add_target("idl/aaa/");
	add_target("idl/registrar/");
end

table.insert(all_target, val_target);
table.insert(all_target, ddl_target);
table.insert(all_target, src_target);
table.insert(all_target, sql_target);
table.insert(all_target, idl_target);
table.insert(all_target, registrar_xsd_target);
table.insert(all_target, aaa_xsd_target);


function write_makefile()
 	local file = io.open("Makefile", "w+");
	file:write("all_target :");
	for i, v in pairs(all_target) do
		for k, l in pairs(v) do
			file:write("  "..l.." \\\n");
		end
	end
	file:write("  build/rockspec.out\n\nall: $(all_target)\n\n");
	if(exists("val/") == true) then
	file:write("#generating validation lua files in build/biop/registrar \n\n");
	for a,source in pairs(val_source) do
		local target = "build/biop/registrar/"..source:gsub("%.xml","").."idations_xml.lua";
		file:write(target.." : "..source.."\n\t~/.luarocks/bin/gval "..source.." biop/registrar build\n\n")
    end
    end

	if(exists("xsd/registrar_data_structures.xsd") == true) then
	file:write("#generating xsd files in build/com/biop/registrar/ \n\n");
	local all_target = '';
	local source = "xsd/registrar_data_structures.xsd";
	for a,target in pairs(registrar_xsd_target) do
		all_target = all_target..target.." ";
    end
		file:write(all_target.." : "..source.."\n\t~/.luarocks/bin/gxsd "..source.." build\n\n")
    end

	if(exists("xsd/aaa_data_structures.xsd") == true) then
	file:write("#generating xsd files in build/com/biop/aaa/ \n\n");
	local all_target = '';
	local source = "xsd/aaa_data_structures.xsd";
	for a,target in pairs(aaa_xsd_target) do
		all_target = all_target..target.." ";
    end
		file:write(all_target.." : "..source.."\n\t~/.luarocks/bin/gxsd "..source.." build\n\n")
    end

	if(exists("ddl/") == true) then
	file:write("#generating ddl lua files in build/biop/registrar/tbl\n\n");
	for a,source in pairs(ddl_source) do
		local source_file = source:gsub("ddl/","");
		local target = "build/biop/registrar/tbl/"..source_file:gsub("%.xml","").."_xml.lua";
		file:write(target.." : "..source.."\n\t~/.luarocks/bin/gtbl "..source.." biop/registrar build\n\n")
	end
    end
	if(exists("src/") == true) then
	file:write("#Copying handcoded services into build/src\n\n")
	for a,source in pairs(src_source) do
		local target = "build/"..source;
		file:write(target.." : "..source.."\n\tmkdir -p build/src\n\tcp "..source.." "..target.."\n\n")
	end
    end
    if(exists("ddl/") == true) then
	file:write("#Copying sql files into build/sql\n\n")
	for a,source in pairs(sql_source) do
		local formatted_source = (source:gsub("ddl/", ""));
		local target = "build/sql/"..formatted_source;
		file:write(target.." : "..source.."\n\tmkdir -p build/sql\n\tcp "..source.." "..target.."\n\n")
	end
    end
    if(exists("idl") == true) then
	file:write("#Generating idl files in build/biop/\n\n")
	for a,source in pairs(idl_source) do
		local formatted_source = source:gsub("idl/", "");
		local parts = stringx.split(formatted_source, "/");
		local target = "build/biop/"..parts[1].."/idl/"..parts[2]:gsub(".xml","").."_interface_xml.lua";
		file:write(target.." : "..source.."\n\t~/.luarocks/bin/gidl "..source.." build\n\n")
	end
    end
	file:write("build/rockspec.out :\n\tlua ~/.luarocks/share/lua/5.3/generator.lua build/"..basic_file.package.."-"..basic_file.version..".rockspec".."\n\ttouch build/rockspec.out\n\nclean :\n\trm -f $(all_target)");
end

write_makefile();
