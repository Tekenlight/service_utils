local stringx = require('pl.stringx');
local schema_processor = require("schema_processor")
local basic_file = require('rockspec');
local basic_stuff = require("lua_schema.basic_stuff");
local all_targets_tbl = {};
local val_targets_tbl = {};
local val_sources_tbl = {};
local ddl_targets_tbl = {};
local ddl_sources_tbl = {};
local src_targets_tbl = {};
local csrc_targets_tbl = {};
local src_sources_tbl = {};
local csrc_sources_tbl = {};
local sql_targets_tbl = {};
local sql_sources_tbl = {};
local idl_targets_tbl = {};
local idl_sources_tbl = {};
local xsd_targets_tbl = {};
local xsd_sources_tbl = {};

function folder_exists(folder)
    local ret = (os.execute("[ -d " .. folder .. " ] && exit 0"));
    if (ret == true) then
        return true
    else
        return false
    end
end

function file_exists(file)
    local ret = (os.execute("[ -f " .. file .. " ] && exit 0"));
    if (ret == true) then
        return true
    else
        return false
    end
end

function add_xsd_targets(directory)
    local i, t = 0, {};
    local pfile, pfile1;
    pfolder = io.popen('ls -1 ' .. directory)
    for xsd_file in pfolder:lines() do
        local target = "build/output_files/xsd/" .. xsd_file:gsub(".xsd$", "") .. "_xsd.lua";
        local source = directory .. xsd_file
        table.insert(xsd_targets_tbl, target);
        table.insert(xsd_sources_tbl, source);
    end
end

function add_val_targets(directory)
    local i, t = 0, {};
    local pfile = io.popen([[ls -1 ]] .. directory .. [[ |grep '\.xml$']])
    for filename in pfile:lines() do
        i = i + 1
        t[i] = filename;
        local source_filename = directory .. filename;
        local target_filename = "build/output_files/val/".. filename:gsub(".xml$", "") .. "_xml.lua"
        table.insert(val_targets_tbl, target_filename);
        table.insert(val_sources_tbl, source_filename);
    end
    pfile:close()
end

function add_ddl_targets(directory)
    local i, t = 0, {};
    local pfile = io.popen([[ls -1 ]] .. directory .. [[ |grep '\.xml$']])
    for filename in pfile:lines() do
        i = i + 1
        t[i] = filename;
        local source_filename = directory .. filename;
        local target_filename = "build/output_files/ddl/" .. filename:gsub(".xml$", "") .. "_xml.lua"
        table.insert(ddl_targets_tbl, target_filename);
        table.insert(ddl_sources_tbl, source_filename);
    end
    pfile:close()
	return;
end

function add_src_targets(directory)
    local i, t = 0, {};
    local pfile = io.popen([[ls -1 ]] .. directory .. [[ |grep '\.lua$']])
    for filename in pfile:lines() do
        i = i + 1
        t[i] = filename;
        local source_filename = directory .. filename;
        local target_filename = "build/" .. directory .. filename;
        table.insert(src_targets_tbl, target_filename);
        table.insert(src_sources_tbl, source_filename);
    end
    pfile:close()
	return;
end

function add_csrc_targets(directory)
    local i, t = 0, {};
    local pfile = io.popen([[ls -1 ]] .. directory .. [[ |grep -E '\.c|\.h|\.cc|\.hh|\.cpp|\.cxx|\.hxx|\.hpp|\.H$']])
    for filename in pfile:lines() do
        i = i + 1
        t[i] = filename;
        local source_filename = directory .. filename;
        local target_filename = "build/" .. directory .. filename;
        table.insert(csrc_targets_tbl, target_filename);
        table.insert(csrc_sources_tbl, source_filename);
    end
    pfile:close()
	return;
end

function add_idl_targets(directory)
	local i, t = 0,{};
	local pfile1;
    local pfile = io.popen('ls -1 ' .. directory)
    for modules in pfile:lines() do
		modules = modules .. "/"
        pfile1 = io.popen([[ls -1 ]] .. directory .. [[/]] .. modules .. [[ | grep '\.xml$']]);
        for filename in pfile1:lines() do
            local source_filename = directory .. modules .. filename;
            local target_filename = "build/output_files/idl/" .. filename:gsub(".xml$", "") .. "_xml.lua";
            table.insert(idl_targets_tbl, target_filename);
            table.insert(idl_sources_tbl, source_filename);
        end
    end
    pfile:close()
    pfile1:close()
	return;
end

function add_sql_targets(directory)
    local i, t = 0, {};
    local pfile = io.popen([[ls -1 ]] .. directory .. [[ |grep '\.sql$']]);
    for filename in pfile:lines() do
        i = i + 1;
        t[i] = filename;
        local source_filename = directory .. filename;
        local target_filename = "build/" .. directory .. filename;
		target_filename = target_filename:gsub("ddl","sql");
        table.insert(sql_targets_tbl, target_filename);
        table.insert(sql_sources_tbl, source_filename);
    end
    pfile:close()
    return;
end

function add_targets(directory)
	if(directory == nil) then
		directory=""
	end
	if (folder_exists(directory.."val/") == true) then
	    add_val_targets(directory.."val/");
   		table.insert(all_targets_tbl, val_targets_tbl);
	end

	if (folder_exists(directory.."ddl/") == true) then
    	add_ddl_targets(directory.."ddl/");
    	table.insert(all_targets_tbl, ddl_targets_tbl);
    	add_sql_targets(directory.."ddl/");
    	table.insert(all_targets_tbl, sql_targets_tbl);
	end

	if (folder_exists(directory.."src/") == true) then
    	add_src_targets(directory.."src/");
    	table.insert(all_targets_tbl, src_targets_tbl);
	end

	if (folder_exists(directory.."csrc/") == true) then
    	add_csrc_targets(directory.."csrc/");
    	table.insert(all_targets_tbl, csrc_targets_tbl);
	end

	if (folder_exists(directory.."idl/") == true) then
    	add_idl_targets(directory.."idl/");
    	table.insert(all_targets_tbl, idl_targets_tbl);
	end

	if (folder_exists(directory.."xsd/") == true) then
	    add_xsd_targets(directory.."xsd/");
	    table.insert(all_targets_tbl, xsd_targets_tbl);
	end

end	

add_targets();

if(basic_file.list_of_submodules ~= nil) then
	for i=1, #basic_file.list_of_submodules do
		add_targets(basic_file.list_of_submodules[i].."/")
	end
end

function returnpath(directory)
    local parts = stringx.split(directory, "/");
    local path = directory:gsub(parts[#parts], "");
    return path;
end

function returnfile(path)
    local parts = stringx.split(path, "/");
    return parts[#parts]
end


function write_makefile()
    local file = io.open("Makefile", "w+");
    file:write("all_targets :");
    for i, v in ipairs(all_targets_tbl) do
        for k, l in ipairs(v) do
            file:write("  " .. l .. " \\\n");
        end
    end
    file:write("  build/" .. basic_file.package .. "-" .. basic_file.version .. ".rockspec\n\n");

    file:write("all: $(all_targets)\n\n");

    if (folder_exists("val/") == true) then
        file:write("#generating validation lua files in build \n\n");
        for i, source in ipairs(val_sources_tbl) do
			local filename = returnfile(source);
			filename = filename:gsub(".xml$","") .. "_xml.lua";
            local target = "build/output_files/val/" .. filename;
            file:write(target .. " : " .. source .. "\n");
            assert(basic_file.ref_common ~= nil);
            file:write("\tgval " .. source .. " " .. basic_file.ref_common .. " build\n")
            file:write("\ttouch build/rockspec.out\n\n");
        end
    end

    if (folder_exists("xsd/") == true) then
        file:write("#generating xsd files in build \n\n");
        for i, source in ipairs(xsd_sources_tbl) do
            local target = "build/output_files/" .. source:gsub(".xsd", "") .. "_xsd.lua";
            file:write(target .. " : " .. source .. "\n\tgxsd  -b 1 -d build " .. source .. "\n")
            file:write("\ttouch build/rockspec.out\n\n");
        end
    end

    if (folder_exists("ddl/") == true) then
        file:write("#generating ddl lua files in build \n\n");
        for i, source in ipairs(ddl_sources_tbl) do
			local filename = returnfile(source);
			filename = filename:gsub(".xml$","") .. "_xml.lua";
            local target = "build/output_files/ddl/" .. filename;
            file:write(target .. " : " .. source .. "\n\tgentbl " .. source .. " " .. basic_file.ref_common .. " build\n")
            file:write("\ttouch build/rockspec.out\n\n");
        end
    end
    if (folder_exists("src/") == true) then
        file:write("#Copying handcoded services into build\n\n")
        for i, source in ipairs(src_sources_tbl) do
            local target = "build/" .. source;
			local t_path = returnpath(target)
            file:write(target .. " : " .. source .. "\n\tmkdir -p "..t_path.."\n");
            file:write("\tluac -o " .. target .. " " .. source .. "\n")
            file:write("\ttouch build/rockspec.out\n\n");
        end
    end
    if (folder_exists("csrc/") == true) then
        file:write("#Copying handcoded C sources into build\n\n")
        for i, source in ipairs(csrc_sources_tbl) do
            local target = "build/" .. source;
			local t_path = returnpath(target)
            file:write(target .. " : " .. source .. "\n\tmkdir -p " ..t_path .."\n");
            file:write("\tcp " .. source .. " " .. target .. "\n")
            file:write("\ttouch build/rockspec.out\n\n");
        end
    end
    if (folder_exists("ddl/") == true) then
        file:write("#Copying sql files into build \n\n")
        for i, source in ipairs(sql_sources_tbl) do
            local target = "build/" .. source;
			target = target:gsub("ddl","sql");
			local t_path = returnpath(target)
            file:write(target .. " : " .. source .. "\n\tmkdir -p " ..t_path .."\n");
            file:write("\tcp " .. source .. " " .. target .. "\n")
            file:write("\ttouch build/rockspec.out\n\n");
        end
    end
    if (folder_exists("idl/") == true) then
        file:write("#Generating idl files in build \n\n")
        for i, source in ipairs(idl_sources_tbl) do
            local parts = stringx.split(source, "/");
            local target = "build/output_files/" .. parts[1] .. "/" .. parts[3]:gsub(".xml$", "") .. "_xml.lua";
            file:write(target .. " : " .. source .. "\n");
            file:write("\tgidl " .. source .. " -b 1 -d build\n")
            file:write("\ttouch build/rockspec.out\n\n");
        end
    end
    file:write("build/" .. basic_file.package .. "-" .. basic_file.version .. ".rockspec : build/rockspec.out\n");
    file:write("\tgrockspec build/" .. basic_file.package .. "-" .. basic_file.version .. ".rockspec" .. "\n\n");
    file:write("clean :\n");
    file:write("\trm -f $all_targets)");
end

write_makefile();
