local basic_stuff = require("lua_schema.basic_stuff");
local eh_cache = require("lua_schema.eh_cache");

local element_handler = {};
element_handler.__name__ = 'error_response_type';

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

eh_cache.add('{http://evpoco.tekenlight.org/idl_spec}error_response_type', _factory);


do
    element_handler.properties = {};
    element_handler.properties.element_type = 'C';
    element_handler.properties.content_type = 'C';
    element_handler.properties.schema_type = '{http://evpoco.tekenlight.org/idl_spec}error_response_type';
    element_handler.properties.q_name = {};
    element_handler.properties.q_name.ns = 'http://evpoco.tekenlight.org/idl_spec'
    element_handler.properties.q_name.local_name = 'error_response_type'

    -- No particle properties for a typedef

    element_handler.properties.attr = {};
    element_handler.properties.attr._attr_properties = {};
    element_handler.properties.attr._generated_attr = {};
end

-- element_handler.properties.content_model
do
    element_handler.properties.content_model = {
        min_occurs = 1,
        top_level_group = true,
        generated_subelement_name = '_sequence_group',
        group_type = 'S',
        max_occurs = 1,
        'error_message',
    };
end

-- element_handler.properties.content_fsa_properties
do
    element_handler.properties.content_fsa_properties = {
        {symbol_type = 'cm_begin', symbol_name = '_sequence_group', generated_symbol_name = '_sequence_group', min_occurs = 1, max_occurs = 1, cm = element_handler.properties.content_model}
        ,{symbol_type = 'element', symbol_name = '{}error_message', generated_symbol_name = '{}error_message', min_occurs = 1, max_occurs = 1, wild_card_type = 0, generated_name = 'error_message', cm = element_handler.properties.content_model}
        ,{symbol_type = 'cm_end', symbol_name = '_sequence_group', generated_symbol_name = '_sequence_group', cm_begin_index = 1, cm = element_handler.properties.content_model}
    };
end

do
    element_handler.properties.declared_subelements = {
        '{}error_message'
    };
end

do
    element_handler.properties.subelement_properties = {};
    element_handler.properties.subelement_properties['{}error_message'] = {};
    do
element_handler.properties.subelement_properties['{}error_message'].super_element_content_type = require('org.w3.2001.XMLSchema.token_handler'):instantiate();

element_handler.properties.subelement_properties['{}error_message'].type_of_simple = 'A';

        do
            element_handler.properties.subelement_properties['{}error_message'].properties = {};
            element_handler.properties.subelement_properties['{}error_message'].properties.element_type = 'S';
            element_handler.properties.subelement_properties['{}error_message'].properties.content_type = 'S';
            element_handler.properties.subelement_properties['{}error_message'].properties.schema_type = '{http://www.w3.org/2001/XMLSchema}token';
            element_handler.properties.subelement_properties['{}error_message'].properties.bi_type = {};
            element_handler.properties.subelement_properties['{}error_message'].properties.bi_type.ns = 'http://www.w3.org/2001/XMLSchema';
            element_handler.properties.subelement_properties['{}error_message'].properties.bi_type.name = 'token';
            element_handler.properties.subelement_properties['{}error_message'].properties.bi_type.id = '16';
            element_handler.properties.subelement_properties['{}error_message'].properties.attr = {};
            element_handler.properties.subelement_properties['{}error_message'].properties.attr._attr_properties = {};
            element_handler.properties.subelement_properties['{}error_message'].properties.attr._generated_attr = {};
        end

        do
            element_handler.properties.subelement_properties['{}error_message'].particle_properties = {};
            element_handler.properties.subelement_properties['{}error_message'].particle_properties.q_name = {};
            element_handler.properties.subelement_properties['{}error_message'].particle_properties.q_name.ns = '';
            element_handler.properties.subelement_properties['{}error_message'].particle_properties.q_name.local_name = 'error_message';
            element_handler.properties.subelement_properties['{}error_message'].particle_properties.generated_name = 'error_message';
        end

        -- Simple type properties
        do
            element_handler.properties.subelement_properties['{}error_message'].base = {};
            element_handler.properties.subelement_properties['{}error_message'].base.ns = 'http://www.w3.org/2001/XMLSchema';
            element_handler.properties.subelement_properties['{}error_message'].base.name = 'token';
            element_handler.properties.subelement_properties['{}error_message'].local_facets = {};
            element_handler.properties.subelement_properties['{}error_message'].facets = basic_stuff.inherit_facets(element_handler.properties.subelement_properties['{}error_message']);
        end

        do
            element_handler.properties.subelement_properties['{}error_message'].type_handler = require('org.w3.2001.XMLSchema.token_handler'):instantiate();
            element_handler.properties.subelement_properties['{}error_message'].get_attributes = basic_stuff.get_attributes;
            element_handler.properties.subelement_properties['{}error_message'].is_valid = basic_stuff.simple_is_valid;
            element_handler.properties.subelement_properties['{}error_message'].to_xmlua = basic_stuff.simple_to_xmlua;
            element_handler.properties.subelement_properties['{}error_message'].get_unique_namespaces_declared = basic_stuff.simple_get_unique_namespaces_declared;
            element_handler.properties.subelement_properties['{}error_message'].parse_xml = basic_stuff.parse_xml;
        end

        element_handler.properties.subelement_properties['{}error_message'].particle_properties.root_element = false;
        element_handler.properties.subelement_properties['{}error_message'].particle_properties.min_occurs = 1;
        element_handler.properties.subelement_properties['{}error_message'].particle_properties.max_occurs = 1;
    end

end

do
    element_handler.properties.generated_subelements = {
        ['error_message'] = element_handler.properties.subelement_properties['{}error_message']
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
