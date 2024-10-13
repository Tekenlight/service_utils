local basic_stuff = require("lua_schema.basic_stuff");
local eh_cache = require("lua_schema.eh_cache");

local element_handler = {};
element_handler.__name__ = 'recipient_dtls_type';

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

eh_cache.add('{http://evpoco.tekenlight.org}recipient_dtls_type', _factory);


do
    element_handler.properties = {};
    element_handler.properties.element_type = 'C';
    element_handler.properties.content_type = 'C';
    element_handler.properties.schema_type = '{http://evpoco.tekenlight.org}recipient_dtls_type';
    element_handler.properties.q_name = {};
    element_handler.properties.q_name.ns = 'http://evpoco.tekenlight.org'
    element_handler.properties.q_name.local_name = 'recipient_dtls_type'

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
        'address',
        'recipient_type',
        'real_name',
    };
end

-- element_handler.properties.content_fsa_properties
do
    element_handler.properties.content_fsa_properties = {
        {symbol_type = 'cm_begin', symbol_name = '_sequence_group', generated_symbol_name = '_sequence_group', min_occurs = 1, max_occurs = 1, cm = element_handler.properties.content_model}
        ,{symbol_type = 'element', symbol_name = '{}address', generated_symbol_name = '{}address', min_occurs = 1, max_occurs = 1, wild_card_type = 0, generated_name = 'address', cm = element_handler.properties.content_model}
        ,{symbol_type = 'element', symbol_name = '{}recipient_type', generated_symbol_name = '{}recipient_type', min_occurs = 1, max_occurs = 1, wild_card_type = 0, generated_name = 'recipient_type', cm = element_handler.properties.content_model}
        ,{symbol_type = 'element', symbol_name = '{}real_name', generated_symbol_name = '{}real_name', min_occurs = 0, max_occurs = 1, wild_card_type = 0, generated_name = 'real_name', cm = element_handler.properties.content_model}
        ,{symbol_type = 'cm_end', symbol_name = '_sequence_group', generated_symbol_name = '_sequence_group', cm_begin_index = 1, cm = element_handler.properties.content_model}
    };
end

do
    element_handler.properties.declared_subelements = {
        '{}address'
        ,'{}recipient_type'
        ,'{}real_name'
    };
end

do
    element_handler.properties.subelement_properties = {};
    element_handler.properties.subelement_properties['{}address'] = {};
    do
element_handler.properties.subelement_properties['{}address'].super_element_content_type = require('org.w3.2001.XMLSchema.token_handler'):instantiate();

element_handler.properties.subelement_properties['{}address'].type_of_simple = 'A';

        do
            element_handler.properties.subelement_properties['{}address'].properties = {};
            element_handler.properties.subelement_properties['{}address'].properties.element_type = 'S';
            element_handler.properties.subelement_properties['{}address'].properties.content_type = 'S';
            element_handler.properties.subelement_properties['{}address'].properties.schema_type = '{http://evpoco.tekenlight.org}email_id_type';
            element_handler.properties.subelement_properties['{}address'].properties.bi_type = {};
            element_handler.properties.subelement_properties['{}address'].properties.bi_type.ns = 'http://www.w3.org/2001/XMLSchema';
            element_handler.properties.subelement_properties['{}address'].properties.bi_type.name = 'token';
            element_handler.properties.subelement_properties['{}address'].properties.bi_type.id = '0';
            element_handler.properties.subelement_properties['{}address'].properties.attr = {};
            element_handler.properties.subelement_properties['{}address'].properties.attr._attr_properties = {};
            element_handler.properties.subelement_properties['{}address'].properties.attr._generated_attr = {};
        end

        do
            element_handler.properties.subelement_properties['{}address'].particle_properties = {};
            element_handler.properties.subelement_properties['{}address'].particle_properties.q_name = {};
            element_handler.properties.subelement_properties['{}address'].particle_properties.q_name.ns = '';
            element_handler.properties.subelement_properties['{}address'].particle_properties.q_name.local_name = 'address';
            element_handler.properties.subelement_properties['{}address'].particle_properties.generated_name = 'address';
        end

        -- Simple type properties
        do
            element_handler.properties.subelement_properties['{}address'].base = {};
            element_handler.properties.subelement_properties['{}address'].base.ns = 'http://www.w3.org/2001/XMLSchema';
            element_handler.properties.subelement_properties['{}address'].base.name = 'token';
            element_handler.properties.subelement_properties['{}address'].local_facets = {};
            element_handler.properties.subelement_properties['{}address'].local_facets.max_length = 320;
            element_handler.properties.subelement_properties['{}address'].local_facets.pattern = {};
            element_handler.properties.subelement_properties['{}address'].local_facets.pattern[1] = {};
            element_handler.properties.subelement_properties['{}address'].local_facets.pattern[1].str_p = [=[([0-9a-zA-Z]([-._\w]*[0-9a-zA-Z])*@([0-9a-zA-Z][-\w]*[0-9a-zA-Z]\.)+[a-zA-Z]{2,9})]=];
            element_handler.properties.subelement_properties['{}address'].local_facets.pattern[1].com_p = nil;
            element_handler.properties.subelement_properties['{}address'].facets = basic_stuff.inherit_facets(element_handler.properties.subelement_properties['{}address']);
        end

        do
            element_handler.properties.subelement_properties['{}address'].type_handler = require('org.w3.2001.XMLSchema.token_handler'):instantiate();
            element_handler.properties.subelement_properties['{}address'].get_attributes = basic_stuff.get_attributes;
            element_handler.properties.subelement_properties['{}address'].is_valid = basic_stuff.simple_is_valid;
            element_handler.properties.subelement_properties['{}address'].to_xmlua = basic_stuff.simple_to_xmlua;
            element_handler.properties.subelement_properties['{}address'].get_unique_namespaces_declared = basic_stuff.simple_get_unique_namespaces_declared;
            element_handler.properties.subelement_properties['{}address'].parse_xml = basic_stuff.parse_xml;
        end

        element_handler.properties.subelement_properties['{}address'].particle_properties.root_element = false;
        element_handler.properties.subelement_properties['{}address'].particle_properties.min_occurs = 1;
        element_handler.properties.subelement_properties['{}address'].particle_properties.max_occurs = 1;
    end

    element_handler.properties.subelement_properties['{}recipient_type'] = {};
    do
element_handler.properties.subelement_properties['{}recipient_type'].super_element_content_type = require('org.w3.2001.XMLSchema.float_handler'):instantiate();

element_handler.properties.subelement_properties['{}recipient_type'].type_of_simple = 'A';

        do
            element_handler.properties.subelement_properties['{}recipient_type'].properties = {};
            element_handler.properties.subelement_properties['{}recipient_type'].properties.element_type = 'S';
            element_handler.properties.subelement_properties['{}recipient_type'].properties.content_type = 'S';
            element_handler.properties.subelement_properties['{}recipient_type'].properties.schema_type = '{http://evpoco.tekenlight.org}recipient_type_type';
            element_handler.properties.subelement_properties['{}recipient_type'].properties.bi_type = {};
            element_handler.properties.subelement_properties['{}recipient_type'].properties.bi_type.ns = 'http://www.w3.org/2001/XMLSchema';
            element_handler.properties.subelement_properties['{}recipient_type'].properties.bi_type.name = 'float';
            element_handler.properties.subelement_properties['{}recipient_type'].properties.bi_type.id = '0';
            element_handler.properties.subelement_properties['{}recipient_type'].properties.attr = {};
            element_handler.properties.subelement_properties['{}recipient_type'].properties.attr._attr_properties = {};
            element_handler.properties.subelement_properties['{}recipient_type'].properties.attr._generated_attr = {};
        end

        do
            element_handler.properties.subelement_properties['{}recipient_type'].particle_properties = {};
            element_handler.properties.subelement_properties['{}recipient_type'].particle_properties.q_name = {};
            element_handler.properties.subelement_properties['{}recipient_type'].particle_properties.q_name.ns = '';
            element_handler.properties.subelement_properties['{}recipient_type'].particle_properties.q_name.local_name = 'recipient_type';
            element_handler.properties.subelement_properties['{}recipient_type'].particle_properties.generated_name = 'recipient_type';
        end

        -- Simple type properties
        do
            element_handler.properties.subelement_properties['{}recipient_type'].base = {};
            element_handler.properties.subelement_properties['{}recipient_type'].base.ns = 'http://www.w3.org/2001/XMLSchema';
            element_handler.properties.subelement_properties['{}recipient_type'].base.name = 'float';
            element_handler.properties.subelement_properties['{}recipient_type'].local_facets = {};
            element_handler.properties.subelement_properties['{}recipient_type'].local_facets.enumeration = {};
            element_handler.properties.subelement_properties['{}recipient_type'].local_facets.enumeration[1] = '0';
            element_handler.properties.subelement_properties['{}recipient_type'].local_facets.enumeration[2] = '1';
            element_handler.properties.subelement_properties['{}recipient_type'].local_facets.enumeration[3] = '2';
            element_handler.properties.subelement_properties['{}recipient_type'].local_facets.pattern = {};
            element_handler.properties.subelement_properties['{}recipient_type'].local_facets.pattern[1] = {};
            element_handler.properties.subelement_properties['{}recipient_type'].local_facets.pattern[1].str_p = [=[([0-9]+)]=];
            element_handler.properties.subelement_properties['{}recipient_type'].local_facets.pattern[1].com_p = nil;
            element_handler.properties.subelement_properties['{}recipient_type'].facets = basic_stuff.inherit_facets(element_handler.properties.subelement_properties['{}recipient_type']);
        end

        do
            element_handler.properties.subelement_properties['{}recipient_type'].type_handler = require('org.w3.2001.XMLSchema.float_handler'):instantiate();
            element_handler.properties.subelement_properties['{}recipient_type'].get_attributes = basic_stuff.get_attributes;
            element_handler.properties.subelement_properties['{}recipient_type'].is_valid = basic_stuff.simple_is_valid;
            element_handler.properties.subelement_properties['{}recipient_type'].to_xmlua = basic_stuff.simple_to_xmlua;
            element_handler.properties.subelement_properties['{}recipient_type'].get_unique_namespaces_declared = basic_stuff.simple_get_unique_namespaces_declared;
            element_handler.properties.subelement_properties['{}recipient_type'].parse_xml = basic_stuff.parse_xml;
        end

        element_handler.properties.subelement_properties['{}recipient_type'].particle_properties.root_element = false;
        element_handler.properties.subelement_properties['{}recipient_type'].particle_properties.min_occurs = 1;
        element_handler.properties.subelement_properties['{}recipient_type'].particle_properties.max_occurs = 1;
    end

    element_handler.properties.subelement_properties['{}real_name'] = {};
    do
element_handler.properties.subelement_properties['{}real_name'].super_element_content_type = require('org.w3.2001.XMLSchema.token_handler'):instantiate();

element_handler.properties.subelement_properties['{}real_name'].type_of_simple = 'A';

        do
            element_handler.properties.subelement_properties['{}real_name'].properties = {};
            element_handler.properties.subelement_properties['{}real_name'].properties.element_type = 'S';
            element_handler.properties.subelement_properties['{}real_name'].properties.content_type = 'S';
            element_handler.properties.subelement_properties['{}real_name'].properties.schema_type = '{http://www.w3.org/2001/XMLSchema}token';
            element_handler.properties.subelement_properties['{}real_name'].properties.bi_type = {};
            element_handler.properties.subelement_properties['{}real_name'].properties.bi_type.ns = 'http://www.w3.org/2001/XMLSchema';
            element_handler.properties.subelement_properties['{}real_name'].properties.bi_type.name = 'token';
            element_handler.properties.subelement_properties['{}real_name'].properties.bi_type.id = '16';
            element_handler.properties.subelement_properties['{}real_name'].properties.attr = {};
            element_handler.properties.subelement_properties['{}real_name'].properties.attr._attr_properties = {};
            element_handler.properties.subelement_properties['{}real_name'].properties.attr._generated_attr = {};
        end

        do
            element_handler.properties.subelement_properties['{}real_name'].particle_properties = {};
            element_handler.properties.subelement_properties['{}real_name'].particle_properties.q_name = {};
            element_handler.properties.subelement_properties['{}real_name'].particle_properties.q_name.ns = '';
            element_handler.properties.subelement_properties['{}real_name'].particle_properties.q_name.local_name = 'real_name';
            element_handler.properties.subelement_properties['{}real_name'].particle_properties.generated_name = 'real_name';
        end

        -- Simple type properties
        do
            element_handler.properties.subelement_properties['{}real_name'].base = {};
            element_handler.properties.subelement_properties['{}real_name'].base.ns = 'http://www.w3.org/2001/XMLSchema';
            element_handler.properties.subelement_properties['{}real_name'].base.name = 'token';
            element_handler.properties.subelement_properties['{}real_name'].local_facets = {};
            element_handler.properties.subelement_properties['{}real_name'].facets = basic_stuff.inherit_facets(element_handler.properties.subelement_properties['{}real_name']);
        end

        do
            element_handler.properties.subelement_properties['{}real_name'].type_handler = require('org.w3.2001.XMLSchema.token_handler'):instantiate();
            element_handler.properties.subelement_properties['{}real_name'].get_attributes = basic_stuff.get_attributes;
            element_handler.properties.subelement_properties['{}real_name'].is_valid = basic_stuff.simple_is_valid;
            element_handler.properties.subelement_properties['{}real_name'].to_xmlua = basic_stuff.simple_to_xmlua;
            element_handler.properties.subelement_properties['{}real_name'].get_unique_namespaces_declared = basic_stuff.simple_get_unique_namespaces_declared;
            element_handler.properties.subelement_properties['{}real_name'].parse_xml = basic_stuff.parse_xml;
        end

        element_handler.properties.subelement_properties['{}real_name'].particle_properties.root_element = false;
        element_handler.properties.subelement_properties['{}real_name'].particle_properties.min_occurs = 0;
        element_handler.properties.subelement_properties['{}real_name'].particle_properties.max_occurs = 1;
    end

end

do
    element_handler.properties.generated_subelements = {
        ['address'] = element_handler.properties.subelement_properties['{}address']
        ,['recipient_type'] = element_handler.properties.subelement_properties['{}recipient_type']
        ,['real_name'] = element_handler.properties.subelement_properties['{}real_name']
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
