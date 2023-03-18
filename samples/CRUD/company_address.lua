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
local validations = require("biop.registrar.val.company_address_validations");
local tao_factory = require('service_utils.orm.tao_factory');

local company_address = {};

company_address.fetch = function (self, context, query_params)
	return company_address_single_crud:fetch(context, query_params);
end

local validate_for_add = function(self, context, company_address)
	return validations.validate_company_address_elements_for_add(context, company_address)
end

company_address.add = function (self, context, query_params, company_address)
	if (not validate_for_add(self, context, company_address)) then
		return false, nil;
	end
	
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

local validate_for_modify = function(self, context, company_address)
	
	return validations.validate_company_address_elements(context, company_address)
end

company_address.modify = function (self, context, query_params, company_address)

	if (not validate_for_modify(self, context, company_address)) then
		return false, nil;
	end
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
	local flg = validations.validate_company_address_elements(context, company_address)
	if (not flg) then
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

