local basic_stuff = require("lua_schema.basic_stuff");
local eh_cache = require("lua_schema.eh_cache");

local element_handler = {};
element_handler.__name__ = 'columns_type';

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

eh_cache.add('{http://evpoco.tekenlight.org/tbl_spec}columns_type', _factory);


do
    element_handler.properties = {};
    element_handler.properties.element_type = 'C';
    element_handler.properties.content_type = 'C';
    element_handler.properties.schema_type = '{http://evpoco.tekenlight.org/tbl_spec}columns_type';
    element_handler.properties.q_name = {};
    element_handler.properties.q_name.ns = 'http://evpoco.tekenlight.org/tbl_spec'
    element_handler.properties.q_name.local_name = 'columns_type'

    -- No particle properties for a typedef

    element_handler.properties.attr = {};
    element_handler.properties.attr._attr_properties = {};
    do
        element_handler.properties.attr._attr_properties['{}entity_state_field'] = {};

        element_handler.properties.attr._attr_properties['{}entity_state_field'].base = {};
        element_handler.properties.attr._attr_properties['{}entity_state_field'].base.ns = 'http://www.w3.org/2001/XMLSchema';
        element_handler.properties.attr._attr_properties['{}entity_state_field'].base.name = 'boolean';
        element_handler.properties.attr._attr_properties['{}entity_state_field'].bi_type = {};
        element_handler.properties.attr._attr_properties['{}entity_state_field'].bi_type.ns = 'http://www.w3.org/2001/XMLSchema';
        element_handler.properties.attr._attr_properties['{}entity_state_field'].bi_type.name = 'boolean';
        element_handler.properties.attr._attr_properties['{}entity_state_field'].bi_type.id = '15';
        element_handler.properties.attr._attr_properties['{}entity_state_field'].properties = {};
        element_handler.properties.attr._attr_properties['{}entity_state_field'].properties.schema_type = '{http://www.w3.org/2001/XMLSchema}boolean';
        element_handler.properties.attr._attr_properties['{}entity_state_field'].properties.default = '';
        element_handler.properties.attr._attr_properties['{}entity_state_field'].properties.fixed = false;
        element_handler.properties.attr._attr_properties['{}entity_state_field'].properties.use = 'O';
        element_handler.properties.attr._attr_properties['{}entity_state_field'].properties.form = 'U';

        element_handler.properties.attr._attr_properties['{}entity_state_field'].particle_properties = {};
        element_handler.properties.attr._attr_properties['{}entity_state_field'].particle_properties.q_name = {};
        element_handler.properties.attr._attr_properties['{}entity_state_field'].particle_properties.q_name.ns = '';
        element_handler.properties.attr._attr_properties['{}entity_state_field'].particle_properties.q_name.local_name = 'entity_state_field';
        element_handler.properties.attr._attr_properties['{}entity_state_field'].particle_properties.generated_name = 'entity_state_field';

        element_handler.properties.attr._attr_properties['{}entity_state_field'].type_handler = require('org.w3.2001.XMLSchema.boolean_handler'):instantiate();

        element_handler.properties.attr._attr_properties['{}entity_state_field'].super_element_content_type = require('org.w3.2001.XMLSchema.boolean_handler'):instantiate();
        element_handler.properties.attr._attr_properties['{}entity_state_field'].type_of_simple = 'A';
        element_handler.properties.attr._attr_properties['{}entity_state_field'].local_facets = {}
        element_handler.properties.attr._attr_properties['{}entity_state_field'].facets = basic_stuff.inherit_facets(element_handler.properties.attr._attr_properties['{}entity_state_field']);
    end
    do
        element_handler.properties.attr._attr_properties['{}update_fields'] = {};

        element_handler.properties.attr._attr_properties['{}update_fields'].base = {};
        element_handler.properties.attr._attr_properties['{}update_fields'].base.ns = 'http://www.w3.org/2001/XMLSchema';
        element_handler.properties.attr._attr_properties['{}update_fields'].base.name = 'boolean';
        element_handler.properties.attr._attr_properties['{}update_fields'].bi_type = {};
        element_handler.properties.attr._attr_properties['{}update_fields'].bi_type.ns = 'http://www.w3.org/2001/XMLSchema';
        element_handler.properties.attr._attr_properties['{}update_fields'].bi_type.name = 'boolean';
        element_handler.properties.attr._attr_properties['{}update_fields'].bi_type.id = '15';
        element_handler.properties.attr._attr_properties['{}update_fields'].properties = {};
        element_handler.properties.attr._attr_properties['{}update_fields'].properties.schema_type = '{http://www.w3.org/2001/XMLSchema}boolean';
        element_handler.properties.attr._attr_properties['{}update_fields'].properties.default = '';
        element_handler.properties.attr._attr_properties['{}update_fields'].properties.fixed = false;
        element_handler.properties.attr._attr_properties['{}update_fields'].properties.use = 'R';
        element_handler.properties.attr._attr_properties['{}update_fields'].properties.form = 'U';

        element_handler.properties.attr._attr_properties['{}update_fields'].particle_properties = {};
        element_handler.properties.attr._attr_properties['{}update_fields'].particle_properties.q_name = {};
        element_handler.properties.attr._attr_properties['{}update_fields'].particle_properties.q_name.ns = '';
        element_handler.properties.attr._attr_properties['{}update_fields'].particle_properties.q_name.local_name = 'update_fields';
        element_handler.properties.attr._attr_properties['{}update_fields'].particle_properties.generated_name = 'update_fields';

        element_handler.properties.attr._attr_properties['{}update_fields'].type_handler = require('org.w3.2001.XMLSchema.boolean_handler'):instantiate();

        element_handler.properties.attr._attr_properties['{}update_fields'].super_element_content_type = require('org.w3.2001.XMLSchema.boolean_handler'):instantiate();
        element_handler.properties.attr._attr_properties['{}update_fields'].type_of_simple = 'A';
        element_handler.properties.attr._attr_properties['{}update_fields'].local_facets = {}
        element_handler.properties.attr._attr_properties['{}update_fields'].facets = basic_stuff.inherit_facets(element_handler.properties.attr._attr_properties['{}update_fields']);
    end
    do
        element_handler.properties.attr._attr_properties['{}creation_fields'] = {};

        element_handler.properties.attr._attr_properties['{}creation_fields'].base = {};
        element_handler.properties.attr._attr_properties['{}creation_fields'].base.ns = 'http://www.w3.org/2001/XMLSchema';
        element_handler.properties.attr._attr_properties['{}creation_fields'].base.name = 'boolean';
        element_handler.properties.attr._attr_properties['{}creation_fields'].bi_type = {};
        element_handler.properties.attr._attr_properties['{}creation_fields'].bi_type.ns = 'http://www.w3.org/2001/XMLSchema';
        element_handler.properties.attr._attr_properties['{}creation_fields'].bi_type.name = 'boolean';
        element_handler.properties.attr._attr_properties['{}creation_fields'].bi_type.id = '15';
        element_handler.properties.attr._attr_properties['{}creation_fields'].properties = {};
        element_handler.properties.attr._attr_properties['{}creation_fields'].properties.schema_type = '{http://www.w3.org/2001/XMLSchema}boolean';
        element_handler.properties.attr._attr_properties['{}creation_fields'].properties.default = '';
        element_handler.properties.attr._attr_properties['{}creation_fields'].properties.fixed = false;
        element_handler.properties.attr._attr_properties['{}creation_fields'].properties.use = 'R';
        element_handler.properties.attr._attr_properties['{}creation_fields'].properties.form = 'U';

        element_handler.properties.attr._attr_properties['{}creation_fields'].particle_properties = {};
        element_handler.properties.attr._attr_properties['{}creation_fields'].particle_properties.q_name = {};
        element_handler.properties.attr._attr_properties['{}creation_fields'].particle_properties.q_name.ns = '';
        element_handler.properties.attr._attr_properties['{}creation_fields'].particle_properties.q_name.local_name = 'creation_fields';
        element_handler.properties.attr._attr_properties['{}creation_fields'].particle_properties.generated_name = 'creation_fields';

        element_handler.properties.attr._attr_properties['{}creation_fields'].type_handler = require('org.w3.2001.XMLSchema.boolean_handler'):instantiate();

        element_handler.properties.attr._attr_properties['{}creation_fields'].super_element_content_type = require('org.w3.2001.XMLSchema.boolean_handler'):instantiate();
        element_handler.properties.attr._attr_properties['{}creation_fields'].type_of_simple = 'A';
        element_handler.properties.attr._attr_properties['{}creation_fields'].local_facets = {}
        element_handler.properties.attr._attr_properties['{}creation_fields'].facets = basic_stuff.inherit_facets(element_handler.properties.attr._attr_properties['{}creation_fields']);
    end
    do
        element_handler.properties.attr._attr_properties['{}soft_del'] = {};

        element_handler.properties.attr._attr_properties['{}soft_del'].base = {};
        element_handler.properties.attr._attr_properties['{}soft_del'].base.ns = 'http://www.w3.org/2001/XMLSchema';
        element_handler.properties.attr._attr_properties['{}soft_del'].base.name = 'boolean';
        element_handler.properties.attr._attr_properties['{}soft_del'].bi_type = {};
        element_handler.properties.attr._attr_properties['{}soft_del'].bi_type.ns = 'http://www.w3.org/2001/XMLSchema';
        element_handler.properties.attr._attr_properties['{}soft_del'].bi_type.name = 'boolean';
        element_handler.properties.attr._attr_properties['{}soft_del'].bi_type.id = '15';
        element_handler.properties.attr._attr_properties['{}soft_del'].properties = {};
        element_handler.properties.attr._attr_properties['{}soft_del'].properties.schema_type = '{http://www.w3.org/2001/XMLSchema}boolean';
        element_handler.properties.attr._attr_properties['{}soft_del'].properties.default = '';
        element_handler.properties.attr._attr_properties['{}soft_del'].properties.fixed = false;
        element_handler.properties.attr._attr_properties['{}soft_del'].properties.use = 'R';
        element_handler.properties.attr._attr_properties['{}soft_del'].properties.form = 'U';

        element_handler.properties.attr._attr_properties['{}soft_del'].particle_properties = {};
        element_handler.properties.attr._attr_properties['{}soft_del'].particle_properties.q_name = {};
        element_handler.properties.attr._attr_properties['{}soft_del'].particle_properties.q_name.ns = '';
        element_handler.properties.attr._attr_properties['{}soft_del'].particle_properties.q_name.local_name = 'soft_del';
        element_handler.properties.attr._attr_properties['{}soft_del'].particle_properties.generated_name = 'soft_del';

        element_handler.properties.attr._attr_properties['{}soft_del'].type_handler = require('org.w3.2001.XMLSchema.boolean_handler'):instantiate();

        element_handler.properties.attr._attr_properties['{}soft_del'].super_element_content_type = require('org.w3.2001.XMLSchema.boolean_handler'):instantiate();
        element_handler.properties.attr._attr_properties['{}soft_del'].type_of_simple = 'A';
        element_handler.properties.attr._attr_properties['{}soft_del'].local_facets = {}
        element_handler.properties.attr._attr_properties['{}soft_del'].facets = basic_stuff.inherit_facets(element_handler.properties.attr._attr_properties['{}soft_del']);
    end
    do
        element_handler.properties.attr._attr_properties['{}internal_id'] = {};

        element_handler.properties.attr._attr_properties['{}internal_id'].base = {};
        element_handler.properties.attr._attr_properties['{}internal_id'].base.ns = 'http://www.w3.org/2001/XMLSchema';
        element_handler.properties.attr._attr_properties['{}internal_id'].base.name = 'boolean';
        element_handler.properties.attr._attr_properties['{}internal_id'].bi_type = {};
        element_handler.properties.attr._attr_properties['{}internal_id'].bi_type.ns = 'http://www.w3.org/2001/XMLSchema';
        element_handler.properties.attr._attr_properties['{}internal_id'].bi_type.name = 'boolean';
        element_handler.properties.attr._attr_properties['{}internal_id'].bi_type.id = '15';
        element_handler.properties.attr._attr_properties['{}internal_id'].properties = {};
        element_handler.properties.attr._attr_properties['{}internal_id'].properties.schema_type = '{http://www.w3.org/2001/XMLSchema}boolean';
        element_handler.properties.attr._attr_properties['{}internal_id'].properties.default = '';
        element_handler.properties.attr._attr_properties['{}internal_id'].properties.fixed = false;
        element_handler.properties.attr._attr_properties['{}internal_id'].properties.use = 'R';
        element_handler.properties.attr._attr_properties['{}internal_id'].properties.form = 'U';

        element_handler.properties.attr._attr_properties['{}internal_id'].particle_properties = {};
        element_handler.properties.attr._attr_properties['{}internal_id'].particle_properties.q_name = {};
        element_handler.properties.attr._attr_properties['{}internal_id'].particle_properties.q_name.ns = '';
        element_handler.properties.attr._attr_properties['{}internal_id'].particle_properties.q_name.local_name = 'internal_id';
        element_handler.properties.attr._attr_properties['{}internal_id'].particle_properties.generated_name = 'internal_id';

        element_handler.properties.attr._attr_properties['{}internal_id'].type_handler = require('org.w3.2001.XMLSchema.boolean_handler'):instantiate();

        element_handler.properties.attr._attr_properties['{}internal_id'].super_element_content_type = require('org.w3.2001.XMLSchema.boolean_handler'):instantiate();
        element_handler.properties.attr._attr_properties['{}internal_id'].type_of_simple = 'A';
        element_handler.properties.attr._attr_properties['{}internal_id'].local_facets = {}
        element_handler.properties.attr._attr_properties['{}internal_id'].facets = basic_stuff.inherit_facets(element_handler.properties.attr._attr_properties['{}internal_id']);
    end
    element_handler.properties.attr._generated_attr = {};
    element_handler.properties.attr._generated_attr['creation_fields'] = '{}creation_fields';
    element_handler.properties.attr._generated_attr['soft_del'] = '{}soft_del';
    element_handler.properties.attr._generated_attr['entity_state_field'] = '{}entity_state_field';
    element_handler.properties.attr._generated_attr['internal_id'] = '{}internal_id';
    element_handler.properties.attr._generated_attr['update_fields'] = '{}update_fields';
end

-- element_handler.properties.content_model
do
    element_handler.properties.content_model = {
        max_occurs = 1,
        generated_subelement_name = '_sequence_group',
        min_occurs = 1,
        group_type = 'S',
        top_level_group = true,
        'column',
    };
end

-- element_handler.properties.content_fsa_properties
do
    element_handler.properties.content_fsa_properties = {
        {symbol_type = 'cm_begin', symbol_name = '_sequence_group', generated_symbol_name = '_sequence_group', min_occurs = 1, max_occurs = 1, cm = element_handler.properties.content_model}
        ,{symbol_type = 'element', symbol_name = '{}column', generated_symbol_name = '{}column', min_occurs = 1, max_occurs = -1, wild_card_type = 0, generated_name = 'column', cm = element_handler.properties.content_model}
        ,{symbol_type = 'cm_end', symbol_name = '_sequence_group', generated_symbol_name = '_sequence_group', cm_begin_index = 1, cm = element_handler.properties.content_model}
    };
end

do
    element_handler.properties.declared_subelements = {
        '{}column'
    };
end

do
    element_handler.properties.subelement_properties = {};
    do
        element_handler.properties.subelement_properties['{}column'] = 
            (basic_stuff.get_element_handler('http://evpoco.tekenlight.org/tbl_spec', 'column_type'):
            new_instance_as_local_element({ns = '', local_name = 'column', generated_name = 'column',
                    root_element = false, min_occurs = 1, max_occurs = -1}));
    end

end

do
    element_handler.properties.generated_subelements = {
        ['column'] = element_handler.properties.subelement_properties['{}column']
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
