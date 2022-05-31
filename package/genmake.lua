local stringx = require('pl.stringx');
local basic_file = require('rockspec');
local basic_stuff = require("lua_schema.basic_stuff");
local xmlua = require("xmlua");
local xsd = xmlua.XSD.new();
local all_targets = {};
local all_sources = {};
local val_targets = {};
local val_sources = {};
local ddl_targets = {};
local ddl_sources = {};
local src_targets = {};
local src_sources = {};
local sql_targets = {};
local sql_sources = {};
local idl_targets = {};
local idl_sources = {};
local xsd_targets = {};

function folder_exists(folder)
    local ret = (os.execute("[ -d "..folder.." ] && exit 0"));
    if(ret == true) then
        return true
    else
        return false
    end
end
function file_exists(file)
    local ret = (os.execute("[ -f "..file.." ] && exit 0"));
    if(ret == true) then
        return true
    else
        return false
    end
end

function add_xsd_targets(directory)
    local i, t, popen = 0, {}, io.popen;
	local pfile,pfile1;
	pfolder = popen('ls -1 '..directory)
	for xsd_file in pfolder:lines() do
		local schema = xsd:parse(directory.."/"..xsd_file);
		local elems = schema:get_element_decls();
		for _,v in ipairs(elems) do
			local module = basic_stuff.package_name_from_uri(v.ns):gsub("com.biop.","")
			local target = "build/com/biop/"..module.."/"..v.name.."_xml.lua ";
			table.insert(xsd_targets, target);
		end
	end
end

function write_xsd_make(directory, file)
    local i, t, popen = 0, {}, io.popen;
	local pfile,pfile1;
	pfolder = popen('ls -1 '..directory)
	for xsd_file in pfolder:lines() do
		local schema = xsd:parse(directory.."/"..xsd_file);
		local elems = schema:get_element_decls();
		for _,v in ipairs(elems) do
			local module = basic_stuff.package_name_from_uri(v.ns):gsub("com.biop.","")
			local target = "build/com/biop/"..module.."/"..v.name.."_xml.lua ";
			file:write(target);
		end
	file:write(" : xsd/"..xsd_file.."\n\t~/.luarocks/bin/gxsd xsd/"..xsd_file.." build\n\n")
	end
end

function add_targets(directory)
    local i, t, popen = 0, {}, io.popen;
	local pfile;
	if(directory == "val/" or directory == "ddl/") then
    	pfile = popen('ls -a '..directory..' |grep .xml')
    	for filename in pfile:lines() do
        	i = i + 1
        	t[i] = filename;
			if(directory == "val/") then
				local source_filename = directory..filename;
				local target_filename = "build/biop/registrar/"..directory..filename:gsub("%.xml", "").."idations_xml.lua";
				table.insert(val_targets, target_filename);
				table.insert(val_sources, source_filename);
			elseif(directory == "ddl/") then
				local source_filename = directory..filename;
				local target_filename = "build/biop/registrar/tbl/"..filename:gsub("%.xml", "").."_xml.lua";
				table.insert(ddl_targets, target_filename);
				table.insert(ddl_sources, source_filename);
			end
		end
	elseif(directory == "src/") then
    	pfile = popen('ls -a '..directory..' |grep .lua')
    	for filename in pfile:lines() do
        	i = i + 1
        	t[i] = filename;
			local source_filename = directory..filename;
			local target_filename = "build/"..directory..filename;
			table.insert(src_targets, target_filename);
			table.insert(src_sources, source_filename);
		end
    elseif(directory == 'idl/') then
		local pfile1;
    	pfile = popen('ls -1 '..directory)
        for modules in pfile:lines() do
			modules = modules.."/"
			pfile1 = popen('ls -1 '..directory.."/"..modules) 
			for filename in pfile1:lines() do
				local source_filename = directory..modules..filename;
				local target_filename = "build/biop"..directory:gsub("idl", "")..modules.."idl/"..filename:gsub(".xml","").."_interface_xml.lua";
				table.insert(idl_targets, target_filename);
				table.insert(idl_sources, source_filename);
			end
		end
	end
    pfile:close()
    return;
end

function add_leftout_targets(directory)
	local i, t, popen = 0, {}, io.popen;
	local pfile = popen('ls -a '..directory..' |grep .sql');
	for filename in pfile:lines() do 
		i = i + 1;
		t[i] = filename;
		local source_filename = directory..filename;
		local target_filename = "build/sql/"..filename;
		table.insert(sql_targets, target_filename);
		table.insert(sql_sources, source_filename);
	end
	pfile:close()
	return;
end

if(folder_exists("val/")==true) then
	add_targets("val/");
	table.insert(all_targets, val_targets);
end

if(folder_exists("ddl/")==true) then
	add_targets("ddl/");
	table.insert(all_targets, ddl_targets);
end

if(folder_exists("src/")==true) then
	add_targets("src/");
	table.insert(all_targets, src_targets);
end

if(folder_exists("ddl/")==true) then
	add_leftout_targets("ddl/");
	table.insert(all_targets, sql_targets);
end

if(folder_exists("idl/") == true) then
	add_targets("idl/");
	table.insert(all_targets, idl_targets);
end

if(folder_exists("xsd/") == true) then
	add_xsd_targets("xsd/");
	table.insert(all_targets, xsd_targets);
end

function write_makefile()
 	local file = io.open("Makefile", "w+");
	file:write("all_targets :");
	for i, v in pairs(all_targets) do
		for k, l in pairs(v) do
			file:write("  "..l.." \\\n");
		end
	end
	file:write("  build/rockspec.out\n\nall: $(all_targets)\n\n");
	if(folder_exists("val/") == true) then
		file:write("#generating validation lua files in build/biop/registrar \n\n");
		for a,source in pairs(val_sources) do
			local target = "build/biop/registrar/"..source:gsub("%.xml","").."idations_xml.lua";
			file:write(target.." : "..source.."\n\t~/.luarocks/bin/gval "..source.." biop/registrar build\n\n")
    	end
    end

	if(folder_exists("xsd/") == true) then
		file:write("#generating xsd files in build/com/biop/ \n\n");
		write_xsd_make("xsd", file);
    end

	if(folder_exists("ddl/") == true) then
		file:write("#generating ddl lua files in build/biop/registrar/tbl\n\n");
		for a,source in pairs(ddl_sources) do
			local source_file = source:gsub("ddl/","");
			local target = "build/biop/registrar/tbl/"..source_file:gsub("%.xml","").."_xml.lua";
			file:write(target.." : "..source.."\n\t~/.luarocks/bin/gtbl "..source.." biop/registrar build\n\n")
		end
    end
	if(folder_exists("src/") == true) then
		file:write("#Copying handcoded services into build/src\n\n")
		for a,source in pairs(src_sources) do
			local target = "build/"..source;
			file:write(target.." : "..source.."\n\tmkdir -p build/src\n\tcp "..source.." "..target.."\n\n")
		end
    end
    if(folder_exists("ddl/") == true) then
		file:write("#Copying sql files into build/sql\n\n")
		for a,source in pairs(sql_sources) do
			local formatted_source = (source:gsub("ddl/", ""));
			local target = "build/sql/"..formatted_source;
			file:write(target.." : "..source.."\n\tmkdir -p build/sql\n\tcp "..source.." "..target.."\n\n")
		end
    end
    if(folder_exists("idl/") == true) then
		file:write("#Generating idl files in build/biop/\n\n")
		for a,source in pairs(idl_sources) do
			local formatted_source = source:gsub("idl/", "");
			local parts = stringx.split(formatted_source, "/");
			local target = "build/biop/"..parts[1].."/idl/"..parts[2]:gsub(".xml","").."_interface_xml.lua";
			file:write(target.." : "..source.."\n\t~/.luarocks/bin/gidl "..source.." build\n\n")
		end
    end
	file:write("build/rockspec.out :\n\tlua ~/.luarocks/share/lua/5.3/generator.lua build/"..basic_file.package.."-"..basic_file.version..".rockspec".."\n\ttouch build/rockspec.out\n\nclean :\n\trm -f $(all_targets)");
end

write_makefile();
