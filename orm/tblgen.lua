local schema_processor = require("schema_processor");
local stringx = require("pl.stringx");

local reserved_column_names = {
	["id"] = 1,
	["deleted"] = 1,
	["creation_uid"] = 1,
	["creation_time"] = 1,
	["update_uid"] = 1,
	["update_time"] = 1,
	["version"] = 1,
	["entity_state"] = 1,
}



local tbl_file_name = arg[1];
local common_ref_module = arg[2];

assert(tbl_file_name ~= nil and type(tbl_file_name) == 'string');
local tbl_file = io.open(tbl_file_name, "r");
assert(tbl_file ~= nil);

local xml_string = tbl_file:read("a");

tbl_file:close();

local tbl_msg_handler = schema_processor:get_message_handler("tbldef", "http://evpoco.tekenlight.org/tbl_spec");

local tbl_struct, msg = tbl_msg_handler:from_xml(xml_string);

if (tbl_struct == nil) then
	error(msg);
end

local tbl_def = {};

tbl_def.tbl_props = tbl_struct._attr;
tbl_def.col_props = tbl_struct.columns._attr;
tbl_def.declared_col_names = {};
tbl_def.auto_col_names = {};
tbl_def.declared_columns = {};
tbl_def.auto_columns = {};
tbl_def.key_col_names = {};
tbl_def.non_key_col_names = {};

for i, v in ipairs(tbl_struct.columns.column) do
	if (reserved_column_names[v._attr.name] ~= nil) then
		error("Column name '".. v._attr.name.. "': not allowed");
	end
	tbl_def.declared_col_names[i] = v._attr.name;
	tbl_def.declared_columns[v._attr.name] = {};
	tbl_def.declared_columns[v._attr.name].datatype = v._attr.type
	tbl_def.declared_columns[v._attr.name].default_value = v._attr.default_value
	if (v._attr.key_column ~= nil and v._attr.key_column) then
		local n = #tbl_def.key_col_names;
		tbl_def.key_col_names[n+1] = v._attr.name;
	else
		local n = #(tbl_def.non_key_col_names);
		tbl_def.non_key_col_names[n+1] = v._attr.name;
	end
end
if (tbl_def.col_props.internal_id) then
	tbl_def.id_column_name = 'id';
	tbl_def.id_column = { ['datatype'] = 'record_id_type'};
end
if (tbl_def.col_props.soft_del) then
	tbl_def.auto_col_names[#tbl_def.auto_col_names+1] = 'deleted';
	tbl_def.auto_columns.deleted = { ['datatype'] = 'boolean'};
end
if (tbl_def.col_props.creation_fields) then
	tbl_def.auto_col_names[#tbl_def.auto_col_names+1] = 'creation_uid'
	tbl_def.auto_col_names[#tbl_def.auto_col_names+1] = 'creation_time'
	tbl_def.auto_columns.creation_uid = { ['datatype'] = 'record_id_type'};
	tbl_def.auto_columns.creation_time = { ['datatype'] = 'timestamp'};
end
if (tbl_def.col_props.update_fields) then
	tbl_def.auto_col_names[#tbl_def.auto_col_names+1] = 'update_uid';
    tbl_def.auto_col_names[#tbl_def.auto_col_names+1] = 'update_time';
    tbl_def.auto_col_names[#tbl_def.auto_col_names+1] = 'version';
	tbl_def.auto_columns.update_uid = { ['datatype'] = 'record_id_type'};
	tbl_def.auto_columns.update_time = { ['datatype'] = 'timestamp'};
	tbl_def.auto_columns.version = { ['datatype'] = 'version_num_type'};
end

if (tbl_def.col_props.entity_state_field) then
    tbl_def.auto_col_names[#tbl_def.auto_col_names+1] = 'entity_state';
    tbl_def.auto_columns.entity_state = {
        ['datatype'] = 'entity_state_type',
        ['default_value'] = '0'
    };
end


tbl_def.indexes = {};
if (tbl_def.col_props.internal_id) then
	tbl_def.auto_sequence = {};
	tbl_def.auto_sequence.name = tbl_def.tbl_props.database_schema.."."..tbl_def.tbl_props.name.."_ID_SEQ"
	tbl_def.auto_sequence.datatype = "bigint";
	tbl_def.auto_sequence.incr_by = 1;
	tbl_def.auto_sequence.start_with = 1;
	tbl_def.auto_sequence.drop_stmt = "DROP SEQUENCE IF EXISTS "..tbl_def.auto_sequence.name;
	tbl_def.auto_sequence.create_stmt = "CREATE SEQUENCE IF NOT EXISTS "..tbl_def.auto_sequence.name..
							" AS "..tbl_def.auto_sequence.datatype.." INCREMENT BY "..tbl_def.auto_sequence.incr_by..
							" START WITH "..tbl_def.auto_sequence.start_with;
	tbl_def.auto_sequence.grant_stmt = "GRANT USAGE, SELECT, UPDATE ON "..tbl_def.auto_sequence.name.. " TO GEN";
	local n = #tbl_def.indexes+1;
	tbl_def.indexes[n] = {};
	tbl_def.indexes[n].name = 'IDX_PRIMARY_'..tbl_def.tbl_props.name;
	tbl_def.indexes[n].unique = true;
	tbl_def.indexes[n].tablespace = tbl_def.tbl_props.tablespace;
	tbl_def.indexes[n].columns = {};
	tbl_def.indexes[n].columns[1] = 'id';
end
if (#tbl_def.key_col_names > 0) then
	local n = #tbl_def.indexes+1;
	tbl_def.indexes[n] = {};
	tbl_def.indexes[n].name = 'IDX_PRIMARY_KEY_'..tbl_def.tbl_props.name;
	tbl_def.indexes[n].unique = true;
	tbl_def.indexes[n].tablespace = tbl_def.tbl_props.tablespace;
	tbl_def.indexes[n].columns = {};
	for i,v in ipairs(tbl_def.key_col_names) do
		tbl_def.indexes[n].columns[i] = v;
	end
end
if (tbl_struct.indexes and tbl_struct.indexes.index) then
	for i,v in ipairs(tbl_struct.indexes.index) do
		local j = #(tbl_def.indexes) + 1;
		tbl_def.indexes[j] = v._attr;
		tbl_def.indexes[j].columns = {};
		for p,q in ipairs(v.index_column) do
			tbl_def.indexes[j].columns[p] = q._attr.name;
		end
	end
end

local stmt = nil;
tbl_def.selected_col_names = {};
do
	stmt = "SELECT";
	local flg = false;
	for i, col in ipairs(tbl_def.declared_col_names) do
		tbl_def.selected_col_names[#(tbl_def.selected_col_names)+1] = col;
		flg = true;
		if (i ~= 1) then
			stmt = stmt..", "..col;
		else
			stmt = stmt.." "..col;
		end
	end
	for i, col in ipairs(tbl_def.auto_col_names) do
		tbl_def.selected_col_names[#(tbl_def.selected_col_names)+1] = col;
		if (flg) then
			stmt = stmt..", "..col;
		else
			stmt = stmt.." "..col;
		end
	end
	if (tbl_def.col_props.internal_id) then
		tbl_def.selected_col_names[#(tbl_def.selected_col_names)+1] = 'id';
		if (flg) then
			stmt = stmt..", id";
		else
			stmt = stmt.." id";
		end
	end
	stmt = stmt .. "\n";
	stmt = stmt .. "FROM " .. tbl_def.tbl_props.database_schema .. "." .. tbl_def.tbl_props.name .. "\n";
	stmt = stmt .. "WHERE";

	for i, col in ipairs(tbl_def.key_col_names) do
		if (i ~= 1) then
			stmt = stmt.." AND "..col.."=?";
		else
			stmt = stmt.." "..col.."=?";
		end
	end
end
tbl_def.select_stmt = stmt;

local stmt = nil;
do
	stmt = "SELECT";
	local flg = false;
	for i, col in ipairs(tbl_def.declared_col_names) do
		flg = true;
		if (i ~= 1) then
			stmt = stmt..", "..col;
		else
			stmt = stmt.." "..col;
		end
	end
	for i, col in ipairs(tbl_def.auto_col_names) do
		if (flg) then
			stmt = stmt..", "..col;
		else
			stmt = stmt.." "..col;
		end
	end
	if (tbl_def.col_props.internal_id) then
		if (flg) then
			stmt = stmt..", id";
		else
			stmt = stmt.." id";
		end
	end
	stmt = stmt .. "\n";
	stmt = stmt .. "FROM " .. tbl_def.tbl_props.database_schema .. "." .. tbl_def.tbl_props.name .. "\n";
	stmt = stmt .. "WHERE";

	for i, col in ipairs(tbl_def.key_col_names) do
		if (i ~= 1) then
			stmt = stmt.." AND "..col.."=?";
		else
			stmt = stmt.." "..col.."=?";
		end
	end

	stmt = stmt .. "\n";
	stmt = stmt .. " FOR UPDATE"
end
tbl_def.selupd_stmt = stmt;

stmt = nil;
do
	stmt = "INSERT INTO " .. tbl_def.tbl_props.database_schema .. "." .. tbl_def.tbl_props.name .. "\n";
	stmt = stmt.."(";
	local flg = false;
	for i, col in ipairs(tbl_def.declared_col_names) do
		flg = true;
		if (i ~= 1) then
			stmt = stmt..", "..col;
		else
			stmt = stmt..col;
		end
	end
	for i, col in ipairs(tbl_def.auto_col_names) do
		if (flg) then
			stmt = stmt..", "..col;
		else
			stmt = stmt.." "..col;
		end
	end
	stmt = stmt .. ")\n";
	stmt = stmt .. "VALUES (";
	for i, col in ipairs(tbl_def.declared_col_names) do
		flg = true;
		if (i ~= 1) then
			stmt = stmt..", ".."?";
		else
			stmt = stmt.."?";
		end
	end
	for i, col in ipairs(tbl_def.auto_col_names) do
		if (flg) then
			stmt = stmt..", ".."?";
		else
			stmt = stmt.." ".."?";
		end
	end
	stmt = stmt..")";

end
tbl_def.insert_stmt = stmt;

stmt = nil;
do
	stmt = "UPDATE " .. tbl_def.tbl_props.database_schema .. "." .. tbl_def.tbl_props.name .. "\n";
	stmt = stmt.."SET ";
	local flg = false;
	for i, col in ipairs(tbl_def.declared_col_names) do
		flg = true;
		if (i ~= 1) then
			stmt = stmt..", "..col .. "=?";
		else
			stmt = stmt..col .. "=?";
		end
	end
	for i, col in ipairs(tbl_def.auto_col_names) do
		if (flg) then
			stmt = stmt..", "..col .. "=?";
		else
			stmt = stmt.." "..col .. "=?";
		end
	end
	stmt = stmt .. "\n";
	stmt = stmt .. "WHERE";

	flg = false;
	for i, col in ipairs(tbl_def.key_col_names) do
		flg = true;
		if (i ~= 1) then
			stmt = stmt.." AND "..col.."=?";
		else
			stmt = stmt.." "..col.."=?";
		end
	end
	if (tbl_def.col_props.update_fields) then
		if (flg) then
			stmt = stmt.." AND version" .. "=?";
		else
			stmt = stmt.." version" .. "=?";
		end
	end

end

tbl_def.update_stmt = nil;
stmt = nil;

do
	stmt = "DELETE FROM " .. tbl_def.tbl_props.database_schema .. "." .. tbl_def.tbl_props.name .. "\n";
	stmt = stmt .. "WHERE";

	local flg = false;
	flg = false;
	for i, col in ipairs(tbl_def.key_col_names) do
		flg = true;
		if (i ~= 1) then
			stmt = stmt.." AND "..col.."=?";
		else
			stmt = stmt.." "..col.."=?";
		end
	end
	if (tbl_def.col_props.update_fields) then
		if (flg) then
			stmt = stmt.." AND version" .. "=?";
		else
			stmt = stmt.." version" .. "=?";
		end
	end

end
tbl_def.delete_stmt = stmt;

stmt = nil;
if (tbl_def.col_props.soft_del) then
	stmt = "UPDATE " .. tbl_def.tbl_props.database_schema .. "." .. tbl_def.tbl_props.name .. "\n";
	stmt = stmt.."SET deleted=?";

	if (tbl_def.col_props.update_fields) then
		stmt = stmt..", update_uid=?";
		stmt = stmt..", update_time=?";
		stmt = stmt..", version=?";
	end
	stmt = stmt .. "\n";
	stmt = stmt .. "WHERE";

	local flg = false;
	for i, col in ipairs(tbl_def.key_col_names) do
		flg = true;
		if (i ~= 1) then
			stmt = stmt.." AND "..col.."=?";
		else
			stmt = stmt.." "..col.."=?";
		end
	end
	if (flg) then
		stmt = stmt.." AND deleted=?";
	else
		stmt = stmt.." deleted=?";
	end
	if (tbl_def.col_props.update_fields) then
		if (flg) then
			stmt = stmt.." AND version=?";
		else
			stmt = stmt.." version=?";
		end
	end


end
tbl_def.logdel_stmt = stmt;
tbl_def.undelete_stmt = stmt;

stmt = nil;

local package_parts = stringx.split(tbl_struct._attr.package, ".");
assert(#package_parts > 0);

local n = #package_parts;
local local_path = ""; 
local i = 1;

function returnfile(path)
    local parts = stringx.split(path, "/");
    local filename = parts[#parts]
    return filename;
end

while (i <= n) do
	if(local_path == "") then
 		local_path = package_parts[i];
    else
		local_path = local_path.."/"..package_parts[i];
	end
    i = i+1;
end
local command ='mkdir -p '..local_path;
os.execute(command);
local table_name = tbl_struct._attr.name;
local generated_file_name = tbl_file_name:gsub("%.%.","");
generated_file_name = generated_file_name:gsub(".xml$","");
generated_file_name = returnfile(generated_file_name);
local file_path = local_path..'/'..generated_file_name..'.lua';
local module_path = local_path..'/'..table_name..'.lua';
local module_path_parts = stringx.split(module_path, "/");
local j = 1;
local module_path1 = "";
while(j <= #module_path_parts) do
	if(module_path1 == "") then
		module_path1 = module_path1..module_path_parts[j];
	else
		module_path1 = module_path1.."."..module_path_parts[j];
	end
	j = j + 1;
end	
module_path1 = module_path1:gsub(".lua$","");
local file = io.open(file_path, "w+");

local tbldef_str = require 'pl.pretty'.write(tbl_def);
local code = 'local tbldef = ' .. tbldef_str..';';
code = code ..[=[

return tbldef;

]=]


file:write(code);

file:close();

--[[
-- Here we are generating the output file with mappings necessary
-- for luarocks.
--]]
do
	os.execute("mkdir -p output_files/ddl")
	local target_file_path = "output_files/ddl/"..generated_file_name.."_xml.lua";
	local file1 = io.open(target_file_path, "w+");
	local c = "local build_mappings = {\n"..'\t["'..module_path1..'"]'..' = '..'"'..file_path..'"\n}'.."\n\nreturn build_mappings;";
	file1:write(c);
	file1:close();
end

code = '';

for i,index in ipairs(tbl_def.indexes) do
	code = code .. [=[
DROP INDEX IF EXISTS ]=] .. index.name..[=[;
]=]
end
code = code .. [=[

]=];

code = code ..[=[
DROP TABLE IF EXISTS ]=]..tbl_def.tbl_props.database_schema.."."..table_name..[=[;
]=];

if (tbl_def.auto_sequence ~= nil)  then
	code = code .. [=[
]=]..tbl_def.auto_sequence.drop_stmt..[=[;
]=]
end
code = code..[=[

]=]
if (tbl_def.auto_sequence ~= nil)  then
	code = code ..[=[
]=]..tbl_def.auto_sequence.create_stmt..[=[;
]=]..tbl_def.auto_sequence.grant_stmt..[=[;

]=]
end

local first_column_created = false;

code = code .. [=[
CREATE TABLE ]=]..tbl_def.tbl_props.database_schema.."."..table_name..[=[ (
]=]
if (tbl_def.col_props.internal_id) then
	code = code ..[=[
    id record_id_type NOT NULL DEFAULT NEXTVAL(']=]..tbl_def.auto_sequence.name..[=[')]=]
	first_column_created = true;
end
local j = 0;
for i,name in ipairs(tbl_def.declared_col_names) do
	if (i ~= 1 or first_column_created) then
		code = code .. [=[,
]=]
	end
	code = code ..[=[
    ]=]..name..[=[ ]=]..tbl_def.declared_columns[name].datatype..[=[]=]
	if (tbl_def.declared_columns[name].default_value ~= nil) then
		code = code .. [=[ DEFAULT ]=]..tbl_def.declared_columns[name].default_value;
	end
end
if (tbl_def.col_props.soft_del) then
	code = code ..[=[,
    deleted boolean]=]
end
if (tbl_def.col_props.creation_fields) then
	code = code ..[=[,
    creation_uid record_id_type,
    creation_time timestamp]=]
end
if (tbl_def.col_props.update_fields) then
	code = code ..[=[,
    update_uid record_id_type,
    update_time timestamp,
    version version_num_type]=]
end
if (tbl_def.col_props.entity_state_field) then
	code = code ..[=[,
    entity_state entity_state_type DEFAULT '0']=]
end

code = code ..[=[

) TABLESPACE ]=]..tbl_def.tbl_props.tablespace..[=[;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLE ]=]..tbl_def.tbl_props.database_schema.."."..table_name..[=[ TO GEN;
]=]
if (tbl_def.auto_sequence) then
	code = code ..[=[ALTER SEQUENCE ]=]..tbl_def.auto_sequence.name..[=[ OWNED BY ]=]..tbl_def.tbl_props.database_schema.."."..table_name..".id"..[=[;
]=]
end
code = code..[=[

]=]
for i,index in ipairs(tbl_def.indexes) do
	code = code .."CREATE "
	if (index.unique) then
		code = code .. "UNIQUE ";
	end
	code = code .. "INDEX IF NOT EXISTS "..index.name..[=[ ON ]=]
	..tbl_def.tbl_props.database_schema.."."..table_name..[=[(]=]
	for p,idx_col_name in ipairs(index.columns) do
		if (p==1) then
			code = code .. idx_col_name;
		else
			code = code .. ", "..idx_col_name;
		end
	end
	code = code .. [=[) TABLESPACE ]=] ..index.tablespace..[=[;
]=]
end
code = code .. [=[

]=]

local command =  'mkdir -p ddl_scripts';
os.execute(command);
local file_path = 'ddl_scripts/'..table_name..'.sql'
local file = io.open(file_path, "w+");
file:write(code);
file:close();

