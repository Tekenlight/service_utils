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
        max_occurs = 1,
        generated_subelement_name = '_sequence_group',
        group_type = 'S',
        top_level_group = true,
        'file_name',
        'data',
        'mime_type',
    };
end

-- element_handler.properties.content_fsa_properties
do
    element_handler.properties.content_fsa_properties = {
        {symbol_type = 'cm_begin', symbol_name = '_sequence_group', generated_symbol_name = '_sequence_group', min_occurs = 1, max_occurs = 1, cm = element_handler.properties.content_model}
        ,{symbol_type = 'element', symbol_name = '{}file_name', generated_symbol_name = '{}file_name', min_occurs = 1, max_occurs = 1, wild_card_type = 0, generated_name = 'file_name', cm = element_handler.properties.content_model}
        ,{symbol_type = 'element', symbol_name = '{}data', generated_symbol_name = '{}data', min_occurs = 1, max_occurs = 1, wild_card_type = 0, generated_name = 'data', cm = element_handler.properties.content_model}
        ,{symbol_type = 'element', symbol_name = '{}mime_type', generated_symbol_name = '{}mime_type', min_occurs = 1, max_occurs = 1, wild_card_type = 0, generated_name = 'mime_type', cm = element_handler.properties.content_model}
        ,{symbol_type = 'cm_end', symbol_name = '_sequence_group', generated_symbol_name = '_sequence_group', cm_begin_index = 1, cm = element_handler.properties.content_model}
    };
end

do
    element_handler.properties.declared_subelements = {
        '{}file_name'
        ,'{}data'
        ,'{}mime_type'
    };
end

do
    element_handler.properties.subelement_properties = {};
    element_handler.properties.subelement_properties['{}data'] = {};
    do
element_handler.properties.subelement_properties['{}data'].super_element_content_type = require('org.w3.2001.XMLSchema.base64Binary_handler'):instantiate();

element_handler.properties.subelement_properties['{}data'].type_of_simple = 'A';

        do
            element_handler.properties.subelement_properties['{}data'].properties = {};
            element_handler.properties.subelement_properties['{}data'].properties.element_type = 'S';
            element_handler.properties.subelement_properties['{}data'].properties.content_type = 'S';
            element_handler.properties.subelement_properties['{}data'].properties.schema_type = '{http://www.w3.org/2001/XMLSchema}base64Binary';
            element_handler.properties.subelement_properties['{}data'].properties.bi_type = {};
            element_handler.properties.subelement_properties['{}data'].properties.bi_type.ns = 'http://www.w3.org/2001/XMLSchema';
            element_handler.properties.subelement_properties['{}data'].properties.bi_type.name = 'base64Binary';
            element_handler.properties.subelement_properties['{}data'].properties.bi_type.id = '44';
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
            element_handler.properties.subelement_properties['{}data'].base.name = 'base64Binary';
            element_handler.properties.subelement_properties['{}data'].local_facets = {};
            element_handler.properties.subelement_properties['{}data'].facets = basic_stuff.inherit_facets(element_handler.properties.subelement_properties['{}data']);
        end

        do
            element_handler.properties.subelement_properties['{}data'].type_handler = require('org.w3.2001.XMLSchema.base64Binary_handler'):instantiate();
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

    element_handler.properties.subelement_properties['{}file_name'] = {};
    do
element_handler.properties.subelement_properties['{}file_name'].super_element_content_type = require('org.w3.2001.XMLSchema.token_handler'):instantiate();

element_handler.properties.subelement_properties['{}file_name'].type_of_simple = 'A';

        do
            element_handler.properties.subelement_properties['{}file_name'].properties = {};
            element_handler.properties.subelement_properties['{}file_name'].properties.element_type = 'S';
            element_handler.properties.subelement_properties['{}file_name'].properties.content_type = 'S';
            element_handler.properties.subelement_properties['{}file_name'].properties.schema_type = '{http://www.w3.org/2001/XMLSchema}token';
            element_handler.properties.subelement_properties['{}file_name'].properties.bi_type = {};
            element_handler.properties.subelement_properties['{}file_name'].properties.bi_type.ns = 'http://www.w3.org/2001/XMLSchema';
            element_handler.properties.subelement_properties['{}file_name'].properties.bi_type.name = 'token';
            element_handler.properties.subelement_properties['{}file_name'].properties.bi_type.id = '16';
            element_handler.properties.subelement_properties['{}file_name'].properties.attr = {};
            element_handler.properties.subelement_properties['{}file_name'].properties.attr._attr_properties = {};
            element_handler.properties.subelement_properties['{}file_name'].properties.attr._generated_attr = {};
        end

        do
            element_handler.properties.subelement_properties['{}file_name'].particle_properties = {};
            element_handler.properties.subelement_properties['{}file_name'].particle_properties.q_name = {};
            element_handler.properties.subelement_properties['{}file_name'].particle_properties.q_name.ns = '';
            element_handler.properties.subelement_properties['{}file_name'].particle_properties.q_name.local_name = 'file_name';
            element_handler.properties.subelement_properties['{}file_name'].particle_properties.generated_name = 'file_name';
        end

        -- Simple type properties
        do
            element_handler.properties.subelement_properties['{}file_name'].base = {};
            element_handler.properties.subelement_properties['{}file_name'].base.ns = 'http://www.w3.org/2001/XMLSchema';
            element_handler.properties.subelement_properties['{}file_name'].base.name = 'token';
            element_handler.properties.subelement_properties['{}file_name'].local_facets = {};
            element_handler.properties.subelement_properties['{}file_name'].facets = basic_stuff.inherit_facets(element_handler.properties.subelement_properties['{}file_name']);
        end

        do
            element_handler.properties.subelement_properties['{}file_name'].type_handler = require('org.w3.2001.XMLSchema.token_handler'):instantiate();
            element_handler.properties.subelement_properties['{}file_name'].get_attributes = basic_stuff.get_attributes;
            element_handler.properties.subelement_properties['{}file_name'].is_valid = basic_stuff.simple_is_valid;
            element_handler.properties.subelement_properties['{}file_name'].to_xmlua = basic_stuff.simple_to_xmlua;
            element_handler.properties.subelement_properties['{}file_name'].get_unique_namespaces_declared = basic_stuff.simple_get_unique_namespaces_declared;
            element_handler.properties.subelement_properties['{}file_name'].parse_xml = basic_stuff.parse_xml;
        end

        element_handler.properties.subelement_properties['{}file_name'].particle_properties.root_element = false;
        element_handler.properties.subelement_properties['{}file_name'].particle_properties.min_occurs = 1;
        element_handler.properties.subelement_properties['{}file_name'].particle_properties.max_occurs = 1;
    end

    element_handler.properties.subelement_properties['{}mime_type'] = {};
    do
element_handler.properties.subelement_properties['{}mime_type'].super_element_content_type = require('org.w3.2001.XMLSchema.token_handler'):instantiate();

element_handler.properties.subelement_properties['{}mime_type'].type_of_simple = 'A';

        do
            element_handler.properties.subelement_properties['{}mime_type'].properties = {};
            element_handler.properties.subelement_properties['{}mime_type'].properties.element_type = 'S';
            element_handler.properties.subelement_properties['{}mime_type'].properties.content_type = 'S';
            element_handler.properties.subelement_properties['{}mime_type'].properties.schema_type = '{http://www.w3.org/2001/XMLSchema}token';
            element_handler.properties.subelement_properties['{}mime_type'].properties.bi_type = {};
            element_handler.properties.subelement_properties['{}mime_type'].properties.bi_type.ns = 'http://www.w3.org/2001/XMLSchema';
            element_handler.properties.subelement_properties['{}mime_type'].properties.bi_type.name = 'token';
            element_handler.properties.subelement_properties['{}mime_type'].properties.bi_type.id = '16';
            element_handler.properties.subelement_properties['{}mime_type'].properties.attr = {};
            element_handler.properties.subelement_properties['{}mime_type'].properties.attr._attr_properties = {};
            element_handler.properties.subelement_properties['{}mime_type'].properties.attr._generated_attr = {};
        end

        do
            element_handler.properties.subelement_properties['{}mime_type'].particle_properties = {};
            element_handler.properties.subelement_properties['{}mime_type'].particle_properties.q_name = {};
            element_handler.properties.subelement_properties['{}mime_type'].particle_properties.q_name.ns = '';
            element_handler.properties.subelement_properties['{}mime_type'].particle_properties.q_name.local_name = 'mime_type';
            element_handler.properties.subelement_properties['{}mime_type'].particle_properties.generated_name = 'mime_type';
        end

        -- Simple type properties
        do
            element_handler.properties.subelement_properties['{}mime_type'].base = {};
            element_handler.properties.subelement_properties['{}mime_type'].base.ns = 'http://www.w3.org/2001/XMLSchema';
            element_handler.properties.subelement_properties['{}mime_type'].base.name = 'token';
            element_handler.properties.subelement_properties['{}mime_type'].local_facets = {};
            element_handler.properties.subelement_properties['{}mime_type'].facets = basic_stuff.inherit_facets(element_handler.properties.subelement_properties['{}mime_type']);
        end

        do
            element_handler.properties.subelement_properties['{}mime_type'].type_handler = require('org.w3.2001.XMLSchema.token_handler'):instantiate();
            element_handler.properties.subelement_properties['{}mime_type'].get_attributes = basic_stuff.get_attributes;
            element_handler.properties.subelement_properties['{}mime_type'].is_valid = basic_stuff.simple_is_valid;
            element_handler.properties.subelement_properties['{}mime_type'].to_xmlua = basic_stuff.simple_to_xmlua;
            element_handler.properties.subelement_properties['{}mime_type'].get_unique_namespaces_declared = basic_stuff.simple_get_unique_namespaces_declared;
            element_handler.properties.subelement_properties['{}mime_type'].parse_xml = basic_stuff.parse_xml;
        end

        element_handler.properties.subelement_properties['{}mime_type'].particle_properties.root_element = false;
        element_handler.properties.subelement_properties['{}mime_type'].particle_properties.min_occurs = 1;
        element_handler.properties.subelement_properties['{}mime_type'].particle_properties.max_occurs = 1;
    end

end

do
    element_handler.properties.generated_subelements = {
        ['file_name'] = element_handler.properties.subelement_properties['{}file_name']
        ,['data'] = element_handler.properties.subelement_properties['{}data']
        ,['mime_type'] = element_handler.properties.subelement_properties['{}mime_type']
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
