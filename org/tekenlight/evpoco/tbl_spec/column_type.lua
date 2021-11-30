local basic_stuff = require("lua_schema.basic_stuff");
local eh_cache = require("lua_schema.eh_cache");

local element_handler = {};
element_handler.__name__ = 'column_type';

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

eh_cache.add('{http://evpoco.tekenlight.org/tbl_spec}column_type', _factory);


do
    element_handler.properties = {};
    element_handler.properties.element_type = 'C';
    element_handler.properties.content_type = 'C';
    element_handler.properties.schema_type = '{http://evpoco.tekenlight.org/tbl_spec}column_type';
    element_handler.properties.q_name = {};
    element_handler.properties.q_name.ns = 'http://evpoco.tekenlight.org/tbl_spec'
    element_handler.properties.q_name.local_name = 'column_type'

    -- No particle properties for a typedef

    element_handler.properties.attr = {};
    element_handler.properties.attr._attr_properties = {};
    do
        element_handler.properties.attr._attr_properties['{}key_column'] = {};

        element_handler.properties.attr._attr_properties['{}key_column'].base = {};
        element_handler.properties.attr._attr_properties['{}key_column'].base.ns = 'http://www.w3.org/2001/XMLSchema';
        element_handler.properties.attr._attr_properties['{}key_column'].base.name = 'boolean';
        element_handler.properties.attr._attr_properties['{}key_column'].bi_type = {};
        element_handler.properties.attr._attr_properties['{}key_column'].bi_type.ns = 'http://www.w3.org/2001/XMLSchema';
        element_handler.properties.attr._attr_properties['{}key_column'].bi_type.name = 'boolean';
        element_handler.properties.attr._attr_properties['{}key_column'].bi_type.id = '15';
        element_handler.properties.attr._attr_properties['{}key_column'].properties = {};
        element_handler.properties.attr._attr_properties['{}key_column'].properties.schema_type = '{http://www.w3.org/2001/XMLSchema}boolean';
        element_handler.properties.attr._attr_properties['{}key_column'].properties.default = '';
        element_handler.properties.attr._attr_properties['{}key_column'].properties.fixed = false;
        element_handler.properties.attr._attr_properties['{}key_column'].properties.use = 'O';
        element_handler.properties.attr._attr_properties['{}key_column'].properties.form = 'U';

        element_handler.properties.attr._attr_properties['{}key_column'].particle_properties = {};
        element_handler.properties.attr._attr_properties['{}key_column'].particle_properties.q_name = {};
        element_handler.properties.attr._attr_properties['{}key_column'].particle_properties.q_name.ns = '';
        element_handler.properties.attr._attr_properties['{}key_column'].particle_properties.q_name.local_name = 'key_column';
        element_handler.properties.attr._attr_properties['{}key_column'].particle_properties.generated_name = 'key_column';

        element_handler.properties.attr._attr_properties['{}key_column'].type_handler = require('org.w3.2001.XMLSchema.boolean_handler'):instantiate();

        element_handler.properties.attr._attr_properties['{}key_column'].super_element_content_type = require('org.w3.2001.XMLSchema.boolean_handler'):instantiate();
        element_handler.properties.attr._attr_properties['{}key_column'].type_of_simple = 'A';
        element_handler.properties.attr._attr_properties['{}key_column'].local_facets = {}
        element_handler.properties.attr._attr_properties['{}key_column'].facets = basic_stuff.inherit_facets(element_handler.properties.attr._attr_properties['{}key_column']);
    end
    do
        element_handler.properties.attr._attr_properties['{}type'] = {};

        element_handler.properties.attr._attr_properties['{}type'].base = {};
        element_handler.properties.attr._attr_properties['{}type'].base.ns = 'http://www.w3.org/2001/XMLSchema';
        element_handler.properties.attr._attr_properties['{}type'].base.name = 'token';
        element_handler.properties.attr._attr_properties['{}type'].bi_type = {};
        element_handler.properties.attr._attr_properties['{}type'].bi_type.ns = 'http://www.w3.org/2001/XMLSchema';
        element_handler.properties.attr._attr_properties['{}type'].bi_type.name = 'token';
        element_handler.properties.attr._attr_properties['{}type'].bi_type.id = '16';
        element_handler.properties.attr._attr_properties['{}type'].properties = {};
        element_handler.properties.attr._attr_properties['{}type'].properties.schema_type = '{http://www.w3.org/2001/XMLSchema}token';
        element_handler.properties.attr._attr_properties['{}type'].properties.default = '';
        element_handler.properties.attr._attr_properties['{}type'].properties.fixed = false;
        element_handler.properties.attr._attr_properties['{}type'].properties.use = 'R';
        element_handler.properties.attr._attr_properties['{}type'].properties.form = 'U';

        element_handler.properties.attr._attr_properties['{}type'].particle_properties = {};
        element_handler.properties.attr._attr_properties['{}type'].particle_properties.q_name = {};
        element_handler.properties.attr._attr_properties['{}type'].particle_properties.q_name.ns = '';
        element_handler.properties.attr._attr_properties['{}type'].particle_properties.q_name.local_name = 'type';
        element_handler.properties.attr._attr_properties['{}type'].particle_properties.generated_name = 'type';

        element_handler.properties.attr._attr_properties['{}type'].type_handler = require('org.w3.2001.XMLSchema.token_handler'):instantiate();

        element_handler.properties.attr._attr_properties['{}type'].super_element_content_type = require('org.w3.2001.XMLSchema.token_handler'):instantiate();
        element_handler.properties.attr._attr_properties['{}type'].type_of_simple = 'A';
        element_handler.properties.attr._attr_properties['{}type'].local_facets = {}
        element_handler.properties.attr._attr_properties['{}type'].facets = basic_stuff.inherit_facets(element_handler.properties.attr._attr_properties['{}type']);
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
    element_handler.properties.attr._generated_attr = {};
    element_handler.properties.attr._generated_attr['name'] = '{}name';
    element_handler.properties.attr._generated_attr['type'] = '{}type';
    element_handler.properties.attr._generated_attr['key_column'] = '{}key_column';
end

-- element_handler.properties.content_model
do
    element_handler.properties.content_model = {
        generated_subelement_name = '_sequence_group',
        group_type = 'S',
        max_occurs = 1,
        top_level_group = true,
        min_occurs = 1,
        'doc',
    };
end

-- element_handler.properties.content_fsa_properties
do
    element_handler.properties.content_fsa_properties = {
        {symbol_type = 'cm_begin', symbol_name = '_sequence_group', generated_symbol_name = '_sequence_group', min_occurs = 1, max_occurs = 1, cm = element_handler.properties.content_model}
        ,{symbol_type = 'element', symbol_name = '{}doc', generated_symbol_name = '{}doc', min_occurs = 0, max_occurs = 1, wild_card_type = 0, generated_name = 'doc', cm = element_handler.properties.content_model}
        ,{symbol_type = 'cm_end', symbol_name = '_sequence_group', generated_symbol_name = '_sequence_group', cm_begin_index = 1, cm = element_handler.properties.content_model}
    };
end

do
    element_handler.properties.declared_subelements = {
        '{}doc'
    };
end

do
    element_handler.properties.subelement_properties = {};
    element_handler.properties.subelement_properties['{}doc'] = {};
    do
element_handler.properties.subelement_properties['{}doc'].super_element_content_type = require('org.w3.2001.XMLSchema.string_handler'):instantiate();

element_handler.properties.subelement_properties['{}doc'].type_of_simple = 'A';

        do
            element_handler.properties.subelement_properties['{}doc'].properties = {};
            element_handler.properties.subelement_properties['{}doc'].properties.element_type = 'S';
            element_handler.properties.subelement_properties['{}doc'].properties.content_type = 'S';
            element_handler.properties.subelement_properties['{}doc'].properties.schema_type = '{http://www.w3.org/2001/XMLSchema}string';
            element_handler.properties.subelement_properties['{}doc'].properties.bi_type = {};
            element_handler.properties.subelement_properties['{}doc'].properties.bi_type.ns = 'http://www.w3.org/2001/XMLSchema';
            element_handler.properties.subelement_properties['{}doc'].properties.bi_type.name = 'string';
            element_handler.properties.subelement_properties['{}doc'].properties.bi_type.id = '1';
            element_handler.properties.subelement_properties['{}doc'].properties.attr = {};
            element_handler.properties.subelement_properties['{}doc'].properties.attr._attr_properties = {};
            element_handler.properties.subelement_properties['{}doc'].properties.attr._generated_attr = {};
        end

        do
            element_handler.properties.subelement_properties['{}doc'].particle_properties = {};
            element_handler.properties.subelement_properties['{}doc'].particle_properties.q_name = {};
            element_handler.properties.subelement_properties['{}doc'].particle_properties.q_name.ns = '';
            element_handler.properties.subelement_properties['{}doc'].particle_properties.q_name.local_name = 'doc';
            element_handler.properties.subelement_properties['{}doc'].particle_properties.generated_name = 'doc';
        end

        -- Simple type properties
        do
            element_handler.properties.subelement_properties['{}doc'].base = {};
            element_handler.properties.subelement_properties['{}doc'].base.ns = 'http://www.w3.org/2001/XMLSchema';
            element_handler.properties.subelement_properties['{}doc'].base.name = 'string';
            element_handler.properties.subelement_properties['{}doc'].local_facets = {};
            element_handler.properties.subelement_properties['{}doc'].facets = basic_stuff.inherit_facets(element_handler.properties.subelement_properties['{}doc']);
        end

        do
            element_handler.properties.subelement_properties['{}doc'].type_handler = require('org.w3.2001.XMLSchema.string_handler'):instantiate();
            element_handler.properties.subelement_properties['{}doc'].get_attributes = basic_stuff.get_attributes;
            element_handler.properties.subelement_properties['{}doc'].is_valid = basic_stuff.simple_is_valid;
            element_handler.properties.subelement_properties['{}doc'].to_xmlua = basic_stuff.simple_to_xmlua;
            element_handler.properties.subelement_properties['{}doc'].get_unique_namespaces_declared = basic_stuff.simple_get_unique_namespaces_declared;
            element_handler.properties.subelement_properties['{}doc'].parse_xml = basic_stuff.parse_xml;
        end

        element_handler.properties.subelement_properties['{}doc'].particle_properties.root_element = false;
        element_handler.properties.subelement_properties['{}doc'].particle_properties.min_occurs = 0;
        element_handler.properties.subelement_properties['{}doc'].particle_properties.max_occurs = 1;
    end

end

do
    element_handler.properties.generated_subelements = {
        ['doc'] = element_handler.properties.subelement_properties['{}doc']
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
