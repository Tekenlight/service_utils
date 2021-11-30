local basic_stuff = require("lua_schema.basic_stuff");

local eh_cache = require("lua_schema.eh_cache");

local _factory = {};
eh_cache.add('{http://evpoco.tekenlight.org/tbl_spec}tbldef', _factory);



function _factory:new_instance_as_root()
    local type_handler = basic_stuff.get_element_handler('http://evpoco.tekenlight.org/tbl_spec', 'tbldef_type');
    local obj =  type_handler:new_instance_as_global_element({
                                        ns = 'http://evpoco.tekenlight.org/tbl_spec',
                                        local_name = 'tbldef',
                                        generated_name = 'tbldef',
                                        root_element = true,
                                        min_occurs = 1,
                                        max_occurs = 1});
    return obj;
end


function _factory:new_instance_as_ref(element_ref_properties)
    local type_handler = basic_stuff.get_element_handler('http://evpoco.tekenlight.org/tbl_spec', 'tbldef_type');
    local obj = type_handler:new_instance_as_local_element({ ns = 'http://evpoco.tekenlight.org/tbl_spec',
                                               local_name = 'tbldef',
                                               generated_name = element_ref_properties.generated_name,
                                               min_occurs = element_ref_properties.min_occurs,
                                               max_occurs = element_ref_properties.max_occurs,
                                               root_element = element_ref_properties.root_element});
    return obj;
end


return _factory;
