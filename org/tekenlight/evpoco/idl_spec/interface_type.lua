local basic_stuff = require("lua_schema.basic_stuff");
local eh_cache = require("lua_schema.eh_cache");

local element_handler = {};
element_handler.__name__ = 'interface_type';

local mt = { __index = element_handler; };
local _factory = {};

function _factory:new_instance_as_global_element(global_element_properties)
    return basic_stuff.instantiate_type_as_doc_root(mt, global_element_properties);
end

function _factory:new_instance_as_local_element(local_element_properties)
    return basic_stuff.instantiate_type_as_local_element(mt, local_element_properties);
end

function _factory:instantiate()
    local o = {};
    local o = setmetatable(o,mt);
    return(o);
end

eh_cache.add('{http://evpoco.tekenlight.org/idl_spec}interface_type', _factory);


do
    element_handler.properties = {};
    element_handler.properties.element_type = 'C';
    element_handler.properties.content_type = 'C';
    element_handler.properties.schema_type = '{http://evpoco.tekenlight.org/idl_spec}interface_type';
    element_handler.properties.q_name = {};
    element_handler.properties.q_name.ns = 'http://evpoco.tekenlight.org/idl_spec'
    element_handler.properties.q_name.local_name = 'interface_type'

    -- No particle properties for a typedef

    element_handler.properties.attr = {};
    element_handler.properties.attr._attr_properties = {};
    do
        element_handler.properties.attr._attr_properties['{}db_schema_name'] = {};

        element_handler.properties.attr._attr_properties['{}db_schema_name'].base = {};
        element_handler.properties.attr._attr_properties['{}db_schema_name'].base.ns = 'http://www.w3.org/2001/XMLSchema';
        element_handler.properties.attr._attr_properties['{}db_schema_name'].base.name = 'token';
        element_handler.properties.attr._attr_properties['{}db_schema_name'].bi_type = {};
        element_handler.properties.attr._attr_properties['{}db_schema_name'].bi_type.ns = 'http://www.w3.org/2001/XMLSchema';
        element_handler.properties.attr._attr_properties['{}db_schema_name'].bi_type.name = 'token';
        element_handler.properties.attr._attr_properties['{}db_schema_name'].bi_type.id = '16';
        element_handler.properties.attr._attr_properties['{}db_schema_name'].properties = {};
        element_handler.properties.attr._attr_properties['{}db_schema_name'].properties.schema_type = '{http://www.w3.org/2001/XMLSchema}token';
        element_handler.properties.attr._attr_properties['{}db_schema_name'].properties.default = '';
        element_handler.properties.attr._attr_properties['{}db_schema_name'].properties.fixed = false;
        element_handler.properties.attr._attr_properties['{}db_schema_name'].properties.use = 'R';
        element_handler.properties.attr._attr_properties['{}db_schema_name'].properties.form = 'U';

        element_handler.properties.attr._attr_properties['{}db_schema_name'].particle_properties = {};
        element_handler.properties.attr._attr_properties['{}db_schema_name'].particle_properties.q_name = {};
        element_handler.properties.attr._attr_properties['{}db_schema_name'].particle_properties.q_name.ns = '';
        element_handler.properties.attr._attr_properties['{}db_schema_name'].particle_properties.q_name.local_name = 'db_schema_name';
        element_handler.properties.attr._attr_properties['{}db_schema_name'].particle_properties.generated_name = 'db_schema_name';

        element_handler.properties.attr._attr_properties['{}db_schema_name'].type_handler = require('org.w3.2001.XMLSchema.token_handler'):instantiate();

        element_handler.properties.attr._attr_properties['{}db_schema_name'].super_element_content_type = require('org.w3.2001.XMLSchema.token_handler'):instantiate();
        element_handler.properties.attr._attr_properties['{}db_schema_name'].type_of_simple = 'A';
        element_handler.properties.attr._attr_properties['{}db_schema_name'].local_facets = {}
        element_handler.properties.attr._attr_properties['{}db_schema_name'].facets = basic_stuff.inherit_facets(element_handler.properties.attr._attr_properties['{}db_schema_name']);
    end
    do
        element_handler.properties.attr._attr_properties['{}name'] = {};

        element_handler.properties.attr._attr_properties['{}name'].base = {};
        element_handler.properties.attr._attr_properties['{}name'].base.ns = 'http://www.w3.org/2001/XMLSchema';
        element_handler.properties.attr._attr_properties['{}name'].base.name = 'token';
        element_handler.properties.attr._attr_properties['{}name'].bi_type = {};
        element_handler.properties.attr._attr_properties['{}name'].bi_type.ns = 'http://www.w3.org/2001/XMLSchema';
        element_handler.properties.attr._attr_properties['{}name'].bi_type.name = 'token';
        element_handler.properties.attr._attr_properties['{}name'].bi_type.id = '16';
        element_handler.properties.attr._attr_properties['{}name'].properties = {};
        element_handler.properties.attr._attr_properties['{}name'].properties.schema_type = '{http://www.w3.org/2001/XMLSchema}token';
        element_handler.properties.attr._attr_properties['{}name'].properties.default = '';
        element_handler.properties.attr._attr_properties['{}name'].properties.fixed = false;
        element_handler.properties.attr._attr_properties['{}name'].properties.use = 'R';
        element_handler.properties.attr._attr_properties['{}name'].properties.form = 'U';

        element_handler.properties.attr._attr_properties['{}name'].particle_properties = {};
        element_handler.properties.attr._attr_properties['{}name'].particle_properties.q_name = {};
        element_handler.properties.attr._attr_properties['{}name'].particle_properties.q_name.ns = '';
        element_handler.properties.attr._attr_properties['{}name'].particle_properties.q_name.local_name = 'name';
        element_handler.properties.attr._attr_properties['{}name'].particle_properties.generated_name = 'name';

        element_handler.properties.attr._attr_properties['{}name'].type_handler = require('org.w3.2001.XMLSchema.token_handler'):instantiate();

        element_handler.properties.attr._attr_properties['{}name'].super_element_content_type = require('org.w3.2001.XMLSchema.token_handler'):instantiate();
        element_handler.properties.attr._attr_properties['{}name'].type_of_simple = 'A';
        element_handler.properties.attr._attr_properties['{}name'].local_facets = {}
        element_handler.properties.attr._attr_properties['{}name'].facets = basic_stuff.inherit_facets(element_handler.properties.attr._attr_properties['{}name']);
    end
    do
        element_handler.properties.attr._attr_properties['{}package'] = {};

        element_handler.properties.attr._attr_properties['{}package'].base = {};
        element_handler.properties.attr._attr_properties['{}package'].base.ns = 'http://www.w3.org/2001/XMLSchema';
        element_handler.properties.attr._attr_properties['{}package'].base.name = 'token';
        element_handler.properties.attr._attr_properties['{}package'].bi_type = {};
        element_handler.properties.attr._attr_properties['{}package'].bi_type.ns = 'http://www.w3.org/2001/XMLSchema';
        element_handler.properties.attr._attr_properties['{}package'].bi_type.name = 'token';
        element_handler.properties.attr._attr_properties['{}package'].bi_type.id = '16';
        element_handler.properties.attr._attr_properties['{}package'].properties = {};
        element_handler.properties.attr._attr_properties['{}package'].properties.schema_type = '{http://www.w3.org/2001/XMLSchema}token';
        element_handler.properties.attr._attr_properties['{}package'].properties.default = '';
        element_handler.properties.attr._attr_properties['{}package'].properties.fixed = false;
        element_handler.properties.attr._attr_properties['{}package'].properties.use = 'R';
        element_handler.properties.attr._attr_properties['{}package'].properties.form = 'U';

        element_handler.properties.attr._attr_properties['{}package'].particle_properties = {};
        element_handler.properties.attr._attr_properties['{}package'].particle_properties.q_name = {};
        element_handler.properties.attr._attr_properties['{}package'].particle_properties.q_name.ns = '';
        element_handler.properties.attr._attr_properties['{}package'].particle_properties.q_name.local_name = 'package';
        element_handler.properties.attr._attr_properties['{}package'].particle_properties.generated_name = 'package';

        element_handler.properties.attr._attr_properties['{}package'].type_handler = require('org.w3.2001.XMLSchema.token_handler'):instantiate();

        element_handler.properties.attr._attr_properties['{}package'].super_element_content_type = require('org.w3.2001.XMLSchema.token_handler'):instantiate();
        element_handler.properties.attr._attr_properties['{}package'].type_of_simple = 'A';
        element_handler.properties.attr._attr_properties['{}package'].local_facets = {}
        element_handler.properties.attr._attr_properties['{}package'].facets = basic_stuff.inherit_facets(element_handler.properties.attr._attr_properties['{}package']);
    end
    element_handler.properties.attr._generated_attr = {};
    element_handler.properties.attr._generated_attr['package'] = '{}package';
    element_handler.properties.attr._generated_attr['db_schema_name'] = '{}db_schema_name';
    element_handler.properties.attr._generated_attr['name'] = '{}name';
end

-- element_handler.properties.content_model
do
    element_handler.properties.content_model = {
        generated_subelement_name = '_sequence_group',
        top_level_group = true,
        group_type = 'S',
        max_occurs = 1,
        min_occurs = 1,
        'method',
    };
end

-- element_handler.properties.content_fsa_properties
do
    element_handler.properties.content_fsa_properties = {
        {symbol_type = 'cm_begin', symbol_name = '_sequence_group', generated_symbol_name = '_sequence_group', min_occurs = 1, max_occurs = 1, cm = element_handler.properties.content_model}
        ,{symbol_type = 'element', symbol_name = '{}method', generated_symbol_name = '{}method', min_occurs = 1, max_occurs = -1, wild_card_type = 0, generated_name = 'method', cm = element_handler.properties.content_model}
        ,{symbol_type = 'cm_end', symbol_name = '_sequence_group', generated_symbol_name = '_sequence_group', cm_begin_index = 1, cm = element_handler.properties.content_model}
    };
end

do
    element_handler.properties.declared_subelements = {
        '{}method'
    };
end

do
    element_handler.properties.subelement_properties = {};
    do
        element_handler.properties.subelement_properties['{}method'] = 
            (basic_stuff.get_element_handler('http://evpoco.tekenlight.org/idl_spec', 'method_type'):
            new_instance_as_local_element({ns = '', local_name = 'method', generated_name = 'method',
                    root_element = false, min_occurs = 1, max_occurs = -1}));
    end

end

do
    element_handler.properties.generated_subelements = {
        ['method'] = element_handler.properties.subelement_properties['{}method']
    };
end

do
    element_handler.type_handler = element_handler;
    element_handler.get_attributes = basic_stuff.get_attributes;
    element_handler.is_valid = basic_stuff.complex_type_is_valid;
    element_handler.to_xmlua = basic_stuff.struct_to_xmlua;
    element_handler.get_unique_namespaces_declared = basic_stuff.complex_get_unique_namespaces_declared;
    element_handler.parse_xml = basic_stuff.parse_xml
end



return _factory;
