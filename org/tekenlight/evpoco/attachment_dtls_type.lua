local basic_stuff = require("lua_schema.basic_stuff");
local eh_cache = require("lua_schema.eh_cache");

local element_handler = {};
element_handler.__name__ = 'attachment_dtls_type';

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

eh_cache.add('{http://evpoco.tekenlight.org}attachment_dtls_type', _factory);


do
    element_handler.properties = {};
    element_handler.properties.element_type = 'C';
    element_handler.properties.content_type = 'C';
    element_handler.properties.schema_type = '{http://evpoco.tekenlight.org}attachment_dtls_type';
    element_handler.properties.q_name = {};
    element_handler.properties.q_name.ns = 'http://evpoco.tekenlight.org'
    element_handler.properties.q_name.local_name = 'attachment_dtls_type'

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
        max_occurs = 1,
        group_type = 'S',
        generated_subelement_name = '_sequence_group',
        'name',
        'data',
        'content_type',
    };
end

-- element_handler.properties.content_fsa_properties
do
    element_handler.properties.content_fsa_properties = {
        {symbol_type = 'cm_begin', symbol_name = '_sequence_group', generated_symbol_name = '_sequence_group', min_occurs = 1, max_occurs = 1, cm = element_handler.properties.content_model}
        ,{symbol_type = 'element', symbol_name = '{}name', generated_symbol_name = '{}name', min_occurs = 1, max_occurs = 1, wild_card_type = 0, generated_name = 'name', cm = element_handler.properties.content_model}
        ,{symbol_type = 'element', symbol_name = '{}data', generated_symbol_name = '{}data', min_occurs = 1, max_occurs = 1, wild_card_type = 0, generated_name = 'data', cm = element_handler.properties.content_model}
        ,{symbol_type = 'element', symbol_name = '{}content_type', generated_symbol_name = '{}content_type', min_occurs = 1, max_occurs = 1, wild_card_type = 0, generated_name = 'content_type', cm = element_handler.properties.content_model}
        ,{symbol_type = 'cm_end', symbol_name = '_sequence_group', generated_symbol_name = '_sequence_group', cm_begin_index = 1, cm = element_handler.properties.content_model}
    };
end

do
    element_handler.properties.declared_subelements = {
        '{}name'
        ,'{}data'
        ,'{}content_type'
    };
end

do
    element_handler.properties.subelement_properties = {};
    element_handler.properties.subelement_properties['{}content_type'] = {};
    do
element_handler.properties.subelement_properties['{}content_type'].super_element_content_type = require('org.w3.2001.XMLSchema.token_handler'):instantiate();

element_handler.properties.subelement_properties['{}content_type'].type_of_simple = 'A';

        do
            element_handler.properties.subelement_properties['{}content_type'].properties = {};
            element_handler.properties.subelement_properties['{}content_type'].properties.element_type = 'S';
            element_handler.properties.subelement_properties['{}content_type'].properties.content_type = 'S';
            element_handler.properties.subelement_properties['{}content_type'].properties.schema_type = '{http://www.w3.org/2001/XMLSchema}token';
            element_handler.properties.subelement_properties['{}content_type'].properties.bi_type = {};
            element_handler.properties.subelement_properties['{}content_type'].properties.bi_type.ns = 'http://www.w3.org/2001/XMLSchema';
            element_handler.properties.subelement_properties['{}content_type'].properties.bi_type.name = 'token';
            element_handler.properties.subelement_properties['{}content_type'].properties.bi_type.id = '16';
            element_handler.properties.subelement_properties['{}content_type'].properties.attr = {};
            element_handler.properties.subelement_properties['{}content_type'].properties.attr._attr_properties = {};
            element_handler.properties.subelement_properties['{}content_type'].properties.attr._generated_attr = {};
        end

        do
            element_handler.properties.subelement_properties['{}content_type'].particle_properties = {};
            element_handler.properties.subelement_properties['{}content_type'].particle_properties.q_name = {};
            element_handler.properties.subelement_properties['{}content_type'].particle_properties.q_name.ns = '';
            element_handler.properties.subelement_properties['{}content_type'].particle_properties.q_name.local_name = 'content_type';
            element_handler.properties.subelement_properties['{}content_type'].particle_properties.generated_name = 'content_type';
        end

        -- Simple type properties
        do
            element_handler.properties.subelement_properties['{}content_type'].base = {};
            element_handler.properties.subelement_properties['{}content_type'].base.ns = 'http://www.w3.org/2001/XMLSchema';
            element_handler.properties.subelement_properties['{}content_type'].base.name = 'token';
            element_handler.properties.subelement_properties['{}content_type'].local_facets = {};
            element_handler.properties.subelement_properties['{}content_type'].facets = basic_stuff.inherit_facets(element_handler.properties.subelement_properties['{}content_type']);
        end

        do
            element_handler.properties.subelement_properties['{}content_type'].type_handler = require('org.w3.2001.XMLSchema.token_handler'):instantiate();
            element_handler.properties.subelement_properties['{}content_type'].get_attributes = basic_stuff.get_attributes;
            element_handler.properties.subelement_properties['{}content_type'].is_valid = basic_stuff.simple_is_valid;
            element_handler.properties.subelement_properties['{}content_type'].to_xmlua = basic_stuff.simple_to_xmlua;
            element_handler.properties.subelement_properties['{}content_type'].get_unique_namespaces_declared = basic_stuff.simple_get_unique_namespaces_declared;
            element_handler.properties.subelement_properties['{}content_type'].parse_xml = basic_stuff.parse_xml;
        end

        element_handler.properties.subelement_properties['{}content_type'].particle_properties.root_element = false;
        element_handler.properties.subelement_properties['{}content_type'].particle_properties.min_occurs = 1;
        element_handler.properties.subelement_properties['{}content_type'].particle_properties.max_occurs = 1;
    end

    element_handler.properties.subelement_properties['{}name'] = {};
    do
element_handler.properties.subelement_properties['{}name'].super_element_content_type = require('org.w3.2001.XMLSchema.token_handler'):instantiate();

element_handler.properties.subelement_properties['{}name'].type_of_simple = 'A';

        do
            element_handler.properties.subelement_properties['{}name'].properties = {};
            element_handler.properties.subelement_properties['{}name'].properties.element_type = 'S';
            element_handler.properties.subelement_properties['{}name'].properties.content_type = 'S';
            element_handler.properties.subelement_properties['{}name'].properties.schema_type = '{http://www.w3.org/2001/XMLSchema}token';
            element_handler.properties.subelement_properties['{}name'].properties.bi_type = {};
            element_handler.properties.subelement_properties['{}name'].properties.bi_type.ns = 'http://www.w3.org/2001/XMLSchema';
            element_handler.properties.subelement_properties['{}name'].properties.bi_type.name = 'token';
            element_handler.properties.subelement_properties['{}name'].properties.bi_type.id = '16';
            element_handler.properties.subelement_properties['{}name'].properties.attr = {};
            element_handler.properties.subelement_properties['{}name'].properties.attr._attr_properties = {};
            element_handler.properties.subelement_properties['{}name'].properties.attr._generated_attr = {};
        end

        do
            element_handler.properties.subelement_properties['{}name'].particle_properties = {};
            element_handler.properties.subelement_properties['{}name'].particle_properties.q_name = {};
            element_handler.properties.subelement_properties['{}name'].particle_properties.q_name.ns = '';
            element_handler.properties.subelement_properties['{}name'].particle_properties.q_name.local_name = 'name';
            element_handler.properties.subelement_properties['{}name'].particle_properties.generated_name = 'name';
        end

        -- Simple type properties
        do
            element_handler.properties.subelement_properties['{}name'].base = {};
            element_handler.properties.subelement_properties['{}name'].base.ns = 'http://www.w3.org/2001/XMLSchema';
            element_handler.properties.subelement_properties['{}name'].base.name = 'token';
            element_handler.properties.subelement_properties['{}name'].local_facets = {};
            element_handler.properties.subelement_properties['{}name'].facets = basic_stuff.inherit_facets(element_handler.properties.subelement_properties['{}name']);
        end

        do
            element_handler.properties.subelement_properties['{}name'].type_handler = require('org.w3.2001.XMLSchema.token_handler'):instantiate();
            element_handler.properties.subelement_properties['{}name'].get_attributes = basic_stuff.get_attributes;
            element_handler.properties.subelement_properties['{}name'].is_valid = basic_stuff.simple_is_valid;
            element_handler.properties.subelement_properties['{}name'].to_xmlua = basic_stuff.simple_to_xmlua;
            element_handler.properties.subelement_properties['{}name'].get_unique_namespaces_declared = basic_stuff.simple_get_unique_namespaces_declared;
            element_handler.properties.subelement_properties['{}name'].parse_xml = basic_stuff.parse_xml;
        end

        element_handler.properties.subelement_properties['{}name'].particle_properties.root_element = false;
        element_handler.properties.subelement_properties['{}name'].particle_properties.min_occurs = 1;
        element_handler.properties.subelement_properties['{}name'].particle_properties.max_occurs = 1;
    end

    element_handler.properties.subelement_properties['{}data'] = {};
    do
element_handler.properties.subelement_properties['{}data'].super_element_content_type = require('org.w3.2001.XMLSchema.hexBinary_handler'):instantiate();

element_handler.properties.subelement_properties['{}data'].type_of_simple = 'A';

        do
            element_handler.properties.subelement_properties['{}data'].properties = {};
            element_handler.properties.subelement_properties['{}data'].properties.element_type = 'S';
            element_handler.properties.subelement_properties['{}data'].properties.content_type = 'S';
            element_handler.properties.subelement_properties['{}data'].properties.schema_type = '{http://www.w3.org/2001/XMLSchema}hexBinary';
            element_handler.properties.subelement_properties['{}data'].properties.bi_type = {};
            element_handler.properties.subelement_properties['{}data'].properties.bi_type.ns = 'http://www.w3.org/2001/XMLSchema';
            element_handler.properties.subelement_properties['{}data'].properties.bi_type.name = 'hexBinary';
            element_handler.properties.subelement_properties['{}data'].properties.bi_type.id = '43';
            element_handler.properties.subelement_properties['{}data'].properties.attr = {};
            element_handler.properties.subelement_properties['{}data'].properties.attr._attr_properties = {};
            element_handler.properties.subelement_properties['{}data'].properties.attr._generated_attr = {};
        end

        do
            element_handler.properties.subelement_properties['{}data'].particle_properties = {};
            element_handler.properties.subelement_properties['{}data'].particle_properties.q_name = {};
            element_handler.properties.subelement_properties['{}data'].particle_properties.q_name.ns = '';
            element_handler.properties.subelement_properties['{}data'].particle_properties.q_name.local_name = 'data';
            element_handler.properties.subelement_properties['{}data'].particle_properties.generated_name = 'data';
        end

        -- Simple type properties
        do
            element_handler.properties.subelement_properties['{}data'].base = {};
            element_handler.properties.subelement_properties['{}data'].base.ns = 'http://www.w3.org/2001/XMLSchema';
            element_handler.properties.subelement_properties['{}data'].base.name = 'hexBinary';
            element_handler.properties.subelement_properties['{}data'].local_facets = {};
            element_handler.properties.subelement_properties['{}data'].facets = basic_stuff.inherit_facets(element_handler.properties.subelement_properties['{}data']);
        end

        do
            element_handler.properties.subelement_properties['{}data'].type_handler = require('org.w3.2001.XMLSchema.hexBinary_handler'):instantiate();
            element_handler.properties.subelement_properties['{}data'].get_attributes = basic_stuff.get_attributes;
            element_handler.properties.subelement_properties['{}data'].is_valid = basic_stuff.simple_is_valid;
            element_handler.properties.subelement_properties['{}data'].to_xmlua = basic_stuff.simple_to_xmlua;
            element_handler.properties.subelement_properties['{}data'].get_unique_namespaces_declared = basic_stuff.simple_get_unique_namespaces_declared;
            element_handler.properties.subelement_properties['{}data'].parse_xml = basic_stuff.parse_xml;
        end

        element_handler.properties.subelement_properties['{}data'].particle_properties.root_element = false;
        element_handler.properties.subelement_properties['{}data'].particle_properties.min_occurs = 1;
        element_handler.properties.subelement_properties['{}data'].particle_properties.max_occurs = 1;
    end

end

do
    element_handler.properties.generated_subelements = {
        ['name'] = element_handler.properties.subelement_properties['{}name']
        ,['data'] = element_handler.properties.subelement_properties['{}data']
        ,['content_type'] = element_handler.properties.subelement_properties['{}content_type']
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
