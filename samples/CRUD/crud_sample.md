This is sample implementation of a REST API which achieves CRUD of a table called BIOP\_COMPANY\_ADDRESS

More modules and setup are necessary to make this code work completely. However the below is an illustration
of the kind of code that will be written when using the evpoco and service\_utils modules.

The crux is event drive IO is achieved without any promises or callbacks


### BIOP\_COMPANY\_ADDRESS.xml
```
<?xml version="1.0" encoding="UTF-8"?>
<ns:tbldef xmlns:ns="http://evpoco.tekenlight.org/tbl_spec"
				name="BIOP_COMPANY_ADDRESS" database_schema="BIOP_ADMIN" tablespace="master" package="biop.registrar.tbl">
	<columns soft_del="true" creation_fields="true" update_fields="true" internal_id="true">
		<column name="org_id" type="org_id_type">
			<doc/>
		</column>
		<column name="address_id" type="address_id_type" key_column="true">
			<doc/>
		</column>
		<column name="address_line_1" type="address_line_type">
			<doc/>
		</column>
		<column name="address_line_2" type="address_line_type">
			<doc/>
		</column>
		<column name="city" type="ref_code_type">
			<doc/>
		</column>
		<column name="state" type="ref_code_type">
			<doc/>
		</column>
		<column name="cntry" type="ref_code_type">
			<doc/>
		</column>
		<column name="zip_code" type="zip_code_type">
			<doc/>
		</column>
	</columns>
	<indexes>
		<index name="IDX_COMPANY_ADDRESS" unique="false" tablespace="master">
			<index_column name="org_id"/>
		</index>
	</indexes>
</ns:tbldef>

```


### company\_address.xsd
```
<xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema" targetNamespace="http://composites.biop.com">

	<xsd:import namespace="http://primitives.biop.com" schemaLocation="primitive_data_structures.xsd"/>

	<xsd:group name="address_elements">
		<xsd:annotation>
			<xsd:documentation>
				<description></description>
			</xsd:documentation>
		</xsd:annotation>
		<xsd:sequence>
			<xsd:element name="address_line_1" type="ns1:address_line_type"/>
			<xsd:element name="address_line_2" type="ns1:address_line_type" minOccurs="0"/>
			<xsd:element name="city" type="ns1:ref_code_type"/>
			<xsd:element name="state" type="ns1:ref_code_type" minOccurs="0"/>
			<xsd:element name="cntry" type="ns1:ref_code_type" minOccurs="0"/>
			<xsd:element name="zip_code" type="ns1:zip_code_type" minOccurs="0"/>
		</xsd:sequence>
	</xsd:group>
	<xsd:complexType name="address_type">
		<xsd:group ref="ns:address_elements"/>
	</xsd:complexType>

	<xsd:group name="company_address_elements">
		<xsd:annotation>
			<xsd:documentation>
				<description></description>
			</xsd:documentation>
		</xsd:annotation>
		<xsd:sequence>
			<xsd:element name="org_id" type="ns1:org_id_type" minOccurs="0"/>
			<xsd:element name="address_id" type="ns1:address_id_type" minOccurs="0"/>
			<xsd:group ref="ns:address_elements"/>
			<xsd:element name="version" type="xsd:long"/>
			<xsd:element name="deleted" type="xsd:boolean" minOccurs="0"/>
		</xsd:sequence>
	</xsd:group>

	<xsd:complexType name="company_address_type">
		<xsd:group ref="ns:company_address_elements" minOccurs="1" maxOccurs="1"/>
	</xsd:complexType>

	<xsd:complexType name="company_addresses_type">
		<xsd:group ref="ns:company_address_elements" minOccurs="0" maxOccurs="unbounded"/>
	</xsd:complexType>

	<xsd:element name="company_address" type="ns:company_address_type"/>
	<xsd:element name="company_addresses" type="ns:company_addresses_type"/>
</xsd:schema>

```

### company\_address\_idl.xml
```
<?xml version="1.0" encoding="UTF-8"?>
<ns:interface xmlns:ns="http://evpoco.tekenlight.org/idl_spec"
				name="company_address" db_schema_name="'REGISTRAR'" package="biop.registrar">
	<documentation>
		Interface to carryout the CRUD (maintenance) operations of a company_address object
		For all the update methods, it is expected that the client calls the "fetch"
		method first and submit the modified company_address record appropriately.
	</documentation>
	<method name="fetch" transactional="false" http_method="GET">
		<documentation>
			fetch:

			Inputs:
				address_id of the company (mandatory)

			Outputs:
				company_address object of the given address of the company

			Description:
				Retrieves a company_address object for the given address_id

			Errors:
				Throws errors in case of invalid or missing inputs
				Throws errors in case the company_address record does not exist
		</documentation>
		<query_param namespace="http://primitives.biop.com" name="address_id" mandatory="true"/>
		<output namespace="http://composites.biop.com" name="company_address"/>
	</method>
	<method name="add" transactional="true" http_method="POST">
		<documentation>
			add:

			Inputs:
				company_address object of the given user

			Outputs:
				None

			Description:
				Adds a new company_address object to Registrar database

			Errors:
				Throws errors in case of invalid or missing inputs
				Throws errors in case the company record already exists
		</documentation>
		<input namespace="http://composites.biop.com" name="company_address"/>
	</method>
	<method name="modify" transactional="true" http_method="PUT">
		<documentation>
			modify:

			Inputs:
				company_address object of the given address_id

			Outputs:
				None

			Description:
				Update a company_address object in the Registrar database

			Errors:
				Throws errors in case of invalid or missing inputs
				Throws errors in case the company_address record does not exist
				Throws error in case of concurrent writes on the same object
		</documentation>
		<input namespace="http://composites.biop.com" name="company_address"/>
	</method>
	<method name="delete" transactional="true" http_method="PUT">
		<documentation>
			delete:

			Inputs:
				company_address object of the given address_id

			Outputs:
				None

			Description:
				Marks a company_address object in the Registrar database as deleted

			Errors:
				Throws errors in case of invalid or missing inputs
				Throws errors in case the company_address record does not exist
				Throws error in case of concurrent writes on the same object
		</documentation>
		<input namespace="http://composites.biop.com" name="company_address"/>
	</method>
	<method name="undelete" transactional="true" http_method="PUT">
		<documentation>
			undelete:

			Inputs:
				company_address object of the given address_id

			Outputs:
				None

			Description:
				Marks a company_address object in the Registrar database as not deleted

			Errors:
				Throws errors in case of invalid or missing inputs
				Throws errors in case the company_address record does not exist
				Throws error in case of concurrent writes on the same object
		</documentation>
		<input namespace="http://composites.biop.com" name="company_address"/>
	</method>
	<method name="list" transactional="true" http_method="GET">
		<documentation>
			list:

			Inputs:
				query_params with one or all of
				org_id, address_id

			Outputs:
				List of comapny_address objects matching the given input criteria

			Description:
				Queries the database and retrives a list of matching company_address records

			Errors:
				Throws errors in case of invalid or missing inputs
		</documentation>
		<query_param namespace="http://primitives.biop.com" name="offset"/>
		<query_param namespace="http://primitives.biop.com" name="num_recs"/>
		<query_param namespace="http://primitives.biop.com" name="org_id"/>
		<query_param namespace="http://primitives.biop.com" name="deleted"/>
		<query_param namespace="http://primitives.biop.com" name="address_id"/>
		<query_param namespace="http://primitives.biop.com" name="org_id"/>
		<output namespace="http://composites.biop.com" name="company_addresses"/>
	</method>
</ns:interface>
```


### company\_address.lua
```
local ffi = require('ffi');
local master_db_params = require('db_params');
local error_handler = require("lua_schema.error_handler");
local single_crud_factory = require('service_utils.orm.single_crud_factory');
local company_address_single_crud = single_crud_factory.new({class_name = 'company_address', 
											msg_ns = 'http://composites.biop.com',
											msg_elem_name = 'company_address',
											db_name = 'REGISTRAR',
											tbl_name = 'BIOP_COMPANY_ADDRESS'});

local mapper = require('service_utils.orm.mapping_util');
local messages = require('service_common.literals');
local tao_factory = require('service_utils.orm.tao_factory');

local company_address = {};

company_address.fetch = function (self, context, query_params)
	return company_address_single_crud:fetch(context, query_params);
end

company_address.add = function (self, context, query_params, company_address)
	local company_address_tbl = tao_factory.open(context, "REGISTRAR", "BIOP_COMPANY_ADDRESS");
	local result;
	repeat
		local  address_id = context:get_seq_nextval('REGISTRAR', 'BIOP_ADMIN.BIOP_ADDRESS_ID_SEQ');

		company_address.address_id = string.format("%05d", tonumber(address_id));

		result = company_address_tbl:select(context,company_address.address_id);
	until (result == nil)

	local func_flg, msg, ret =  company_address_single_crud:add(context, company_address);
		
	if (not func_flg) then	
		if (ret == -1) then
			local msg1 = messages:format('RECORD_INSERTION_FAILED', company_address.org_id);
			error_handler.reset_error();
			error_handler.raise_error(-1, msg1, debug.getinfo(1));
		end		
	end

	return func_flg, msg;

end

company_address.modify = function (self, context, query_params, company_address)

	local func_flg, msg, ret =  company_address_single_crud:modify(context, company_address);
		
	if (not func_flg) then	
		if (ret == -1) then
			local msg1 = messages:format('RECORD_INSERTION_FAILED', company_address.org_id);
			error_handler.reset_error();
			error_handler.raise_error(-1, msg1, debug.getinfo(1));
		end		
		
	end
	
	return func_flg, msg;
end

local validate_for_delete = function(self, context, company_address)
	local flg, out = self:fetch(context, { address_id = company_address.address_id });
	if (not flg) then
		local msg = messages:format('RECORD_NOT_FOUND', company_address.address_id);
		error_handler.raise_error(-1, msg, debug.getinfo(1));
		return false;
	end
	if (out.deleted) then
		local msg = messages:format('RECORD_DELETED', company_address.address_id);
		error_handler.raise_error(-1, msg, debug.getinfo(1));
		return false;
	end
	return true;
end

company_address.delete = function (self, context, query_params, company_address)
	if (not validate_for_delete(self, context, company_address)) then
		return false, nil;
	end

	return company_address_single_crud:delete(context, company_address);
end

local validate_for_undelete = function(self, context, company_address)
	local flg, out = self:fetch(context, { address_id = company_address.address_id });
	if (not flg) then
		local msg = messages:format('RECORD_NOT_FOUND', company_address.address_id);
		error_handler.raise_error(-1, msg, debug.getinfo(1));
		return false;
	end
	if (not out.deleted) then
		local msg = messages:format('RECORD_NOT_DELETED', company_address.address_id);
		error_handler.raise_error(-1, msg, debug.getinfo(1));
		return false;
	end

	return true;
end

company_address.undelete = function (self, context, query_params, company_address)
	if (not validate_for_undelete(self, context, company_address)) then
		return false, nil;
	end

	return company_address_single_crud:undelete(context, company_address);
end

local function prepare_query_string(query_params)
	local p = {};
	local i = 1;
	local q = [[ SELECT org_id, address_id, address_line_1, address_line_2,
				city, state, cntry, zip_code, deleted, version
				FROM BIOP_ADMIN.BIOP_COMPANY_ADDRESS WHERE org_id = ? ]]
		p[i] = query_params.org_id;
		i = i + 1;
	if (query_params.address_id ~= nil) then
		q = q..' AND address_id = ?'
		p[i] = query_params.address_id;
		i = i + 1;
	end
	if (query_params.deleted ~= nil) then
        q = q..' AND deleted = ?'
        local d = '0';
        if (query_params.deleted == true) then
            d = '1';
        end
        p[i] = d;
        i = i + 1;
    end
	
	return q, p;
end

company_address.list= function (self, context, query_params)

	local out = {};
	local q, p = prepare_query_string(query_params);

	local cur = (context:get_connection('REGISTRAR')):open_cursor('COMPANY_ADDRESS_LIST', q, table.unpack(p));
	local c_out = cur:fetch_next_set({offset = query_params.offset, num_recs = query_params.num_recs});

	local rec = c_out:fetch_rec();
	while (rec ~= nil) do
		local row = c_out:map(rec,
				{ 'org_id', 'address_id','address_line_1', 'address_line_2',
				'city', 'state', 'cntry', 'zip_code', 'deleted', 'version' });
		out[#out+1] = row;
		rec = c_out:fetch_rec();
	end
	cur:close();

	return true, out;
end


return company_address;

```


### evluaserver.properties
```
# This is a sample configuration file for HTTPFormServer

logging.loggers.root.channel.class = ConsoleChannel
logging.loggers.app.name = Application
logging.loggers.app.channel = c1
logging.formatters.f1.class = PatternFormatter
logging.formatters.f1.pattern = [%p] %t
logging.channels.c1.class = ConsoleChannel
logging.channels.c1.formatter = f1

EVTCPServer.numThreads = 1
EVTCPServer.useIpv6ForConn = 0
EVTCPServer.numConnections = 1000

evlhttprequesthandler.enableluafilecache = false

evluaserver.port   = 9982
evluaserver.networkInterfaceToRunOn= en0, lo0

evluaserver.requestMappingScript = mapper.lua
evluaserver.wsMessageMappingScript = mapper.lua
evluaserver.clMappingScript = evlua_mapper.lua

service_utils.jwtSignatureKey = example_key

service_utils.REST.controller.disableAuthCheck = true

```

