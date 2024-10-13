local basic_stuff = require("lua_schema.basic_stuff");
local eh_cache = require("lua_schema.eh_cache");

local element_handler = {};
element_handler.__name__ = 'inbound_email_message_type';

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

eh_cache.add('{http://evpoco.tekenlight.org}inbound_email_message_type', _factory);


do
    element_handler.properties = {};
    element_handler.properties.element_type = 'C';
    element_handler.properties.content_type = 'C';
    element_handler.properties.schema_type = '{http://evpoco.tekenlight.org}inbound_email_message_type';
    element_handler.properties.q_name = {};
    element_handler.properties.q_name.ns = 'http://evpoco.tekenlight.org'
    element_handler.properties.q_name.local_name = 'inbound_email_message_type'

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
        'id',
        'date',
        'from',
        'return_path',
        'delivered_to',
        'to',
        'cc',
        'subject',
        'message_body',
        'attachments',
    };
end

-- element_handler.properties.content_fsa_properties
do
    element_handler.properties.content_fsa_properties = {
        {symbol_type = 'cm_begin', symbol_name = '_sequence_group', generated_symbol_name = '_sequence_group', min_occurs = 1, max_occurs = 1, cm = element_handler.properties.content_model}
        ,{symbol_type = 'element', symbol_name = '{}id', generated_symbol_name = '{}id', min_occurs = 1, max_occurs = 1, wild_card_type = 0, generated_name = 'id', cm = element_handler.properties.content_model}
        ,{symbol_type = 'element', symbol_name = '{}date', generated_symbol_name = '{}date', min_occurs = 1, max_occurs = 1, wild_card_type = 0, generated_name = 'date', cm = element_handler.properties.content_model}
        ,{symbol_type = 'element', symbol_name = '{}from', generated_symbol_name = '{}from', min_occurs = 1, max_occurs = 1, wild_card_type = 0, generated_name = 'from', cm = element_handler.properties.content_model}
        ,{symbol_type = 'element', symbol_name = '{}return_path', generated_symbol_name = '{}return_path', min_occurs = 1, max_occurs = 1, wild_card_type = 0, generated_name = 'return_path', cm = element_handler.properties.content_model}
        ,{symbol_type = 'element', symbol_name = '{}delivered_to', generated_symbol_name = '{}delivered_to', min_occurs = 1, max_occurs = 1, wild_card_type = 0, generated_name = 'delivered_to', cm = element_handler.properties.content_model}
        ,{symbol_type = 'element', symbol_name = '{}to', generated_symbol_name = '{}to', min_occurs = 1, max_occurs = 1, wild_card_type = 0, generated_name = 'to', cm = element_handler.properties.content_model}
        ,{symbol_type = 'element', symbol_name = '{}cc', generated_symbol_name = '{}cc', min_occurs = 1, max_occurs = 1, wild_card_type = 0, generated_name = 'cc', cm = element_handler.properties.content_model}
        ,{symbol_type = 'element', symbol_name = '{}subject', generated_symbol_name = '{}subject', min_occurs = 1, max_occurs = 1, wild_card_type = 0, generated_name = 'subject', cm = element_handler.properties.content_model}
        ,{symbol_type = 'element', symbol_name = '{}message_body', generated_symbol_name = '{}message_body', min_occurs = 1, max_occurs = 1, wild_card_type = 0, generated_name = 'message_body', cm = element_handler.properties.content_model}
        ,{symbol_type = 'element', symbol_name = '{}attachments', generated_symbol_name = '{}attachments', min_occurs = 0, max_occurs = -1, wild_card_type = 0, generated_name = 'attachments', cm = element_handler.properties.content_model}
        ,{symbol_type = 'cm_end', symbol_name = '_sequence_group', generated_symbol_name = '_sequence_group', cm_begin_index = 1, cm = element_handler.properties.content_model}
    };
end

do
    element_handler.properties.declared_subelements = {
        '{}id'
        ,'{}date'
        ,'{}from'
        ,'{}return_path'
        ,'{}delivered_to'
        ,'{}to'
        ,'{}cc'
        ,'{}subject'
        ,'{}message_body'
        ,'{}attachments'
    };
end

do
    element_handler.properties.subelement_properties = {};
    element_handler.properties.subelement_properties['{}from'] = {};
    do
element_handler.properties.subelement_properties['{}from'].super_element_content_type = require('org.w3.2001.XMLSchema.token_handler'):instantiate();

element_handler.properties.subelement_properties['{}from'].type_of_simple = 'A';

        do
            element_handler.properties.subelement_properties['{}from'].properties = {};
            element_handler.properties.subelement_properties['{}from'].properties.element_type = 'S';
            element_handler.properties.subelement_properties['{}from'].properties.content_type = 'S';
            element_handler.properties.subelement_properties['{}from'].properties.schema_type = '{http://www.w3.org/2001/XMLSchema}token';
            element_handler.properties.subelement_properties['{}from'].properties.bi_type = {};
            element_handler.properties.subelement_properties['{}from'].properties.bi_type.ns = 'http://www.w3.org/2001/XMLSchema';
            element_handler.properties.subelement_properties['{}from'].properties.bi_type.name = 'token';
            element_handler.properties.subelement_properties['{}from'].properties.bi_type.id = '16';
            element_handler.properties.subelement_properties['{}from'].properties.attr = {};
            element_handler.properties.subelement_properties['{}from'].properties.attr._attr_properties = {};
            element_handler.properties.subelement_properties['{}from'].properties.attr._generated_attr = {};
        end

        do
            element_handler.properties.subelement_properties['{}from'].particle_properties = {};
            element_handler.properties.subelement_properties['{}from'].particle_properties.q_name = {};
            element_handler.properties.subelement_properties['{}from'].particle_properties.q_name.ns = '';
            element_handler.properties.subelement_properties['{}from'].particle_properties.q_name.local_name = 'from';
            element_handler.properties.subelement_properties['{}from'].particle_properties.generated_name = 'from';
        end

        -- Simple type properties
        do
            element_handler.properties.subelement_properties['{}from'].base = {};
            element_handler.properties.subelement_properties['{}from'].base.ns = 'http://www.w3.org/2001/XMLSchema';
            element_handler.properties.subelement_properties['{}from'].base.name = 'token';
            element_handler.properties.subelement_properties['{}from'].local_facets = {};
            element_handler.properties.subelement_properties['{}from'].facets = basic_stuff.inherit_facets(element_handler.properties.subelement_properties['{}from']);
        end

        do
            element_handler.properties.subelement_properties['{}from'].type_handler = require('org.w3.2001.XMLSchema.token_handler'):instantiate();
            element_handler.properties.subelement_properties['{}from'].get_attributes = basic_stuff.get_attributes;
            element_handler.properties.subelement_properties['{}from'].is_valid = basic_stuff.simple_is_valid;
            element_handler.properties.subelement_properties['{}from'].to_xmlua = basic_stuff.simple_to_xmlua;
            element_handler.properties.subelement_properties['{}from'].get_unique_namespaces_declared = basic_stuff.simple_get_unique_namespaces_declared;
            element_handler.properties.subelement_properties['{}from'].parse_xml = basic_stuff.parse_xml;
        end

        element_handler.properties.subelement_properties['{}from'].particle_properties.root_element = false;
        element_handler.properties.subelement_properties['{}from'].particle_properties.min_occurs = 1;
        element_handler.properties.subelement_properties['{}from'].particle_properties.max_occurs = 1;
    end

    do
        element_handler.properties.subelement_properties['{}attachments'] = 
            (basic_stuff.get_element_handler('http://evpoco.tekenlight.org', 'attachment_dtls_type'):
            new_instance_as_local_element({ns = '', local_name = 'attachments', generated_name = 'attachments',
                    root_element = false, min_occurs = 0, max_occurs = -1}));
    end

    element_handler.properties.subelement_properties['{}delivered_to'] = {};
    do
element_handler.properties.subelement_properties['{}delivered_to'].super_element_content_type = require('org.w3.2001.XMLSchema.token_handler'):instantiate();

element_handler.properties.subelement_properties['{}delivered_to'].type_of_simple = 'A';

        do
            element_handler.properties.subelement_properties['{}delivered_to'].properties = {};
            element_handler.properties.subelement_properties['{}delivered_to'].properties.element_type = 'S';
            element_handler.properties.subelement_properties['{}delivered_to'].properties.content_type = 'S';
            element_handler.properties.subelement_properties['{}delivered_to'].properties.schema_type = '{http://evpoco.tekenlight.org}email_id_type';
            element_handler.properties.subelement_properties['{}delivered_to'].properties.bi_type = {};
            element_handler.properties.subelement_properties['{}delivered_to'].properties.bi_type.ns = 'http://www.w3.org/2001/XMLSchema';
            element_handler.properties.subelement_properties['{}delivered_to'].properties.bi_type.name = 'token';
            element_handler.properties.subelement_properties['{}delivered_to'].properties.bi_type.id = '0';
            element_handler.properties.subelement_properties['{}delivered_to'].properties.attr = {};
            element_handler.properties.subelement_properties['{}delivered_to'].properties.attr._attr_properties = {};
            element_handler.properties.subelement_properties['{}delivered_to'].properties.attr._generated_attr = {};
        end

        do
            element_handler.properties.subelement_properties['{}delivered_to'].particle_properties = {};
            element_handler.properties.subelement_properties['{}delivered_to'].particle_properties.q_name = {};
            element_handler.properties.subelement_properties['{}delivered_to'].particle_properties.q_name.ns = '';
            element_handler.properties.subelement_properties['{}delivered_to'].particle_properties.q_name.local_name = 'delivered_to';
            element_handler.properties.subelement_properties['{}delivered_to'].particle_properties.generated_name = 'delivered_to';
        end

        -- Simple type properties
        do
            element_handler.properties.subelement_properties['{}delivered_to'].base = {};
            element_handler.properties.subelement_properties['{}delivered_to'].base.ns = 'http://www.w3.org/2001/XMLSchema';
            element_handler.properties.subelement_properties['{}delivered_to'].base.name = 'token';
            element_handler.properties.subelement_properties['{}delivered_to'].local_facets = {};
            element_handler.properties.subelement_properties['{}delivered_to'].local_facets.max_length = 320;
            element_handler.properties.subelement_properties['{}delivered_to'].local_facets.pattern = {};
            element_handler.properties.subelement_properties['{}delivered_to'].local_facets.pattern[1] = {};
            element_handler.properties.subelement_properties['{}delivered_to'].local_facets.pattern[1].str_p = [=[([0-9a-zA-Z]([-._\w]*[0-9a-zA-Z])*@([0-9a-zA-Z][-\w]*[0-9a-zA-Z]\.)+[a-zA-Z]{2,9})]=];
            element_handler.properties.subelement_properties['{}delivered_to'].local_facets.pattern[1].com_p = nil;
            element_handler.properties.subelement_properties['{}delivered_to'].facets = basic_stuff.inherit_facets(element_handler.properties.subelement_properties['{}delivered_to']);
        end

        do
            element_handler.properties.subelement_properties['{}delivered_to'].type_handler = require('org.w3.2001.XMLSchema.token_handler'):instantiate();
            element_handler.properties.subelement_properties['{}delivered_to'].get_attributes = basic_stuff.get_attributes;
            element_handler.properties.subelement_properties['{}delivered_to'].is_valid = basic_stuff.simple_is_valid;
            element_handler.properties.subelement_properties['{}delivered_to'].to_xmlua = basic_stuff.simple_to_xmlua;
            element_handler.properties.subelement_properties['{}delivered_to'].get_unique_namespaces_declared = basic_stuff.simple_get_unique_namespaces_declared;
            element_handler.properties.subelement_properties['{}delivered_to'].parse_xml = basic_stuff.parse_xml;
        end

        element_handler.properties.subelement_properties['{}delivered_to'].particle_properties.root_element = false;
        element_handler.properties.subelement_properties['{}delivered_to'].particle_properties.min_occurs = 1;
        element_handler.properties.subelement_properties['{}delivered_to'].particle_properties.max_occurs = 1;
    end

    element_handler.properties.subelement_properties['{}id'] = {};
    do
element_handler.properties.subelement_properties['{}id'].super_element_content_type = require('org.w3.2001.XMLSchema.token_handler'):instantiate();

element_handler.properties.subelement_properties['{}id'].type_of_simple = 'A';

        do
            element_handler.properties.subelement_properties['{}id'].properties = {};
            element_handler.properties.subelement_properties['{}id'].properties.element_type = 'S';
            element_handler.properties.subelement_properties['{}id'].properties.content_type = 'S';
            element_handler.properties.subelement_properties['{}id'].properties.schema_type = '{http://www.w3.org/2001/XMLSchema}token';
            element_handler.properties.subelement_properties['{}id'].properties.bi_type = {};
            element_handler.properties.subelement_properties['{}id'].properties.bi_type.ns = 'http://www.w3.org/2001/XMLSchema';
            element_handler.properties.subelement_properties['{}id'].properties.bi_type.name = 'token';
            element_handler.properties.subelement_properties['{}id'].properties.bi_type.id = '16';
            element_handler.properties.subelement_properties['{}id'].properties.attr = {};
            element_handler.properties.subelement_properties['{}id'].properties.attr._attr_properties = {};
            element_handler.properties.subelement_properties['{}id'].properties.attr._generated_attr = {};
        end

        do
            element_handler.properties.subelement_properties['{}id'].particle_properties = {};
            element_handler.properties.subelement_properties['{}id'].particle_properties.q_name = {};
            element_handler.properties.subelement_properties['{}id'].particle_properties.q_name.ns = '';
            element_handler.properties.subelement_properties['{}id'].particle_properties.q_name.local_name = 'id';
            element_handler.properties.subelement_properties['{}id'].particle_properties.generated_name = 'id';
        end

        -- Simple type properties
        do
            element_handler.properties.subelement_properties['{}id'].base = {};
            element_handler.properties.subelement_properties['{}id'].base.ns = 'http://www.w3.org/2001/XMLSchema';
            element_handler.properties.subelement_properties['{}id'].base.name = 'token';
            element_handler.properties.subelement_properties['{}id'].local_facets = {};
            element_handler.properties.subelement_properties['{}id'].facets = basic_stuff.inherit_facets(element_handler.properties.subelement_properties['{}id']);
        end

        do
            element_handler.properties.subelement_properties['{}id'].type_handler = require('org.w3.2001.XMLSchema.token_handler'):instantiate();
            element_handler.properties.subelement_properties['{}id'].get_attributes = basic_stuff.get_attributes;
            element_handler.properties.subelement_properties['{}id'].is_valid = basic_stuff.simple_is_valid;
            element_handler.properties.subelement_properties['{}id'].to_xmlua = basic_stuff.simple_to_xmlua;
            element_handler.properties.subelement_properties['{}id'].get_unique_namespaces_declared = basic_stuff.simple_get_unique_namespaces_declared;
            element_handler.properties.subelement_properties['{}id'].parse_xml = basic_stuff.parse_xml;
        end

        element_handler.properties.subelement_properties['{}id'].particle_properties.root_element = false;
        element_handler.properties.subelement_properties['{}id'].particle_properties.min_occurs = 1;
        element_handler.properties.subelement_properties['{}id'].particle_properties.max_occurs = 1;
    end

    element_handler.properties.subelement_properties['{}to'] = {};
    do
element_handler.properties.subelement_properties['{}to'].super_element_content_type = require('org.w3.2001.XMLSchema.token_handler'):instantiate();

element_handler.properties.subelement_properties['{}to'].type_of_simple = 'A';

        do
            element_handler.properties.subelement_properties['{}to'].properties = {};
            element_handler.properties.subelement_properties['{}to'].properties.element_type = 'S';
            element_handler.properties.subelement_properties['{}to'].properties.content_type = 'S';
            element_handler.properties.subelement_properties['{}to'].properties.schema_type = '{http://www.w3.org/2001/XMLSchema}token';
            element_handler.properties.subelement_properties['{}to'].properties.bi_type = {};
            element_handler.properties.subelement_properties['{}to'].properties.bi_type.ns = 'http://www.w3.org/2001/XMLSchema';
            element_handler.properties.subelement_properties['{}to'].properties.bi_type.name = 'token';
            element_handler.properties.subelement_properties['{}to'].properties.bi_type.id = '16';
            element_handler.properties.subelement_properties['{}to'].properties.attr = {};
            element_handler.properties.subelement_properties['{}to'].properties.attr._attr_properties = {};
            element_handler.properties.subelement_properties['{}to'].properties.attr._generated_attr = {};
        end

        do
            element_handler.properties.subelement_properties['{}to'].particle_properties = {};
            element_handler.properties.subelement_properties['{}to'].particle_properties.q_name = {};
            element_handler.properties.subelement_properties['{}to'].particle_properties.q_name.ns = '';
            element_handler.properties.subelement_properties['{}to'].particle_properties.q_name.local_name = 'to';
            element_handler.properties.subelement_properties['{}to'].particle_properties.generated_name = 'to';
        end

        -- Simple type properties
        do
            element_handler.properties.subelement_properties['{}to'].base = {};
            element_handler.properties.subelement_properties['{}to'].base.ns = 'http://www.w3.org/2001/XMLSchema';
            element_handler.properties.subelement_properties['{}to'].base.name = 'token';
            element_handler.properties.subelement_properties['{}to'].local_facets = {};
            element_handler.properties.subelement_properties['{}to'].facets = basic_stuff.inherit_facets(element_handler.properties.subelement_properties['{}to']);
        end

        do
            element_handler.properties.subelement_properties['{}to'].type_handler = require('org.w3.2001.XMLSchema.token_handler'):instantiate();
            element_handler.properties.subelement_properties['{}to'].get_attributes = basic_stuff.get_attributes;
            element_handler.properties.subelement_properties['{}to'].is_valid = basic_stuff.simple_is_valid;
            element_handler.properties.subelement_properties['{}to'].to_xmlua = basic_stuff.simple_to_xmlua;
            element_handler.properties.subelement_properties['{}to'].get_unique_namespaces_declared = basic_stuff.simple_get_unique_namespaces_declared;
            element_handler.properties.subelement_properties['{}to'].parse_xml = basic_stuff.parse_xml;
        end

        element_handler.properties.subelement_properties['{}to'].particle_properties.root_element = false;
        element_handler.properties.subelement_properties['{}to'].particle_properties.min_occurs = 1;
        element_handler.properties.subelement_properties['{}to'].particle_properties.max_occurs = 1;
    end

    element_handler.properties.subelement_properties['{}subject'] = {};
    do
element_handler.properties.subelement_properties['{}subject'].super_element_content_type = require('org.w3.2001.XMLSchema.token_handler'):instantiate();

element_handler.properties.subelement_properties['{}subject'].type_of_simple = 'A';

        do
            element_handler.properties.subelement_properties['{}subject'].properties = {};
            element_handler.properties.subelement_properties['{}subject'].properties.element_type = 'S';
            element_handler.properties.subelement_properties['{}subject'].properties.content_type = 'S';
            element_handler.properties.subelement_properties['{}subject'].properties.schema_type = '{http://www.w3.org/2001/XMLSchema}token';
            element_handler.properties.subelement_properties['{}subject'].properties.bi_type = {};
            element_handler.properties.subelement_properties['{}subject'].properties.bi_type.ns = 'http://www.w3.org/2001/XMLSchema';
            element_handler.properties.subelement_properties['{}subject'].properties.bi_type.name = 'token';
            element_handler.properties.subelement_properties['{}subject'].properties.bi_type.id = '16';
            element_handler.properties.subelement_properties['{}subject'].properties.attr = {};
            element_handler.properties.subelement_properties['{}subject'].properties.attr._attr_properties = {};
            element_handler.properties.subelement_properties['{}subject'].properties.attr._generated_attr = {};
        end

        do
            element_handler.properties.subelement_properties['{}subject'].particle_properties = {};
            element_handler.properties.subelement_properties['{}subject'].particle_properties.q_name = {};
            element_handler.properties.subelement_properties['{}subject'].particle_properties.q_name.ns = '';
            element_handler.properties.subelement_properties['{}subject'].particle_properties.q_name.local_name = 'subject';
            element_handler.properties.subelement_properties['{}subject'].particle_properties.generated_name = 'subject';
        end

        -- Simple type properties
        do
            element_handler.properties.subelement_properties['{}subject'].base = {};
            element_handler.properties.subelement_properties['{}subject'].base.ns = 'http://www.w3.org/2001/XMLSchema';
            element_handler.properties.subelement_properties['{}subject'].base.name = 'token';
            element_handler.properties.subelement_properties['{}subject'].local_facets = {};
            element_handler.properties.subelement_properties['{}subject'].facets = basic_stuff.inherit_facets(element_handler.properties.subelement_properties['{}subject']);
        end

        do
            element_handler.properties.subelement_properties['{}subject'].type_handler = require('org.w3.2001.XMLSchema.token_handler'):instantiate();
            element_handler.properties.subelement_properties['{}subject'].get_attributes = basic_stuff.get_attributes;
            element_handler.properties.subelement_properties['{}subject'].is_valid = basic_stuff.simple_is_valid;
            element_handler.properties.subelement_properties['{}subject'].to_xmlua = basic_stuff.simple_to_xmlua;
            element_handler.properties.subelement_properties['{}subject'].get_unique_namespaces_declared = basic_stuff.simple_get_unique_namespaces_declared;
            element_handler.properties.subelement_properties['{}subject'].parse_xml = basic_stuff.parse_xml;
        end

        element_handler.properties.subelement_properties['{}subject'].particle_properties.root_element = false;
        element_handler.properties.subelement_properties['{}subject'].particle_properties.min_occurs = 1;
        element_handler.properties.subelement_properties['{}subject'].particle_properties.max_occurs = 1;
    end

    element_handler.properties.subelement_properties['{}date'] = {};
    do
element_handler.properties.subelement_properties['{}date'].super_element_content_type = require('org.w3.2001.XMLSchema.dateTime_handler'):instantiate();

element_handler.properties.subelement_properties['{}date'].type_of_simple = 'A';

        do
            element_handler.properties.subelement_properties['{}date'].properties = {};
            element_handler.properties.subelement_properties['{}date'].properties.element_type = 'S';
            element_handler.properties.subelement_properties['{}date'].properties.content_type = 'S';
            element_handler.properties.subelement_properties['{}date'].properties.schema_type = '{http://www.w3.org/2001/XMLSchema}dateTime';
            element_handler.properties.subelement_properties['{}date'].properties.bi_type = {};
            element_handler.properties.subelement_properties['{}date'].properties.bi_type.ns = 'http://www.w3.org/2001/XMLSchema';
            element_handler.properties.subelement_properties['{}date'].properties.bi_type.name = 'dateTime';
            element_handler.properties.subelement_properties['{}date'].properties.bi_type.id = '11';
            element_handler.properties.subelement_properties['{}date'].properties.attr = {};
            element_handler.properties.subelement_properties['{}date'].properties.attr._attr_properties = {};
            element_handler.properties.subelement_properties['{}date'].properties.attr._generated_attr = {};
        end

        do
            element_handler.properties.subelement_properties['{}date'].particle_properties = {};
            element_handler.properties.subelement_properties['{}date'].particle_properties.q_name = {};
            element_handler.properties.subelement_properties['{}date'].particle_properties.q_name.ns = '';
            element_handler.properties.subelement_properties['{}date'].particle_properties.q_name.local_name = 'date';
            element_handler.properties.subelement_properties['{}date'].particle_properties.generated_name = 'date';
        end

        -- Simple type properties
        do
            element_handler.properties.subelement_properties['{}date'].base = {};
            element_handler.properties.subelement_properties['{}date'].base.ns = 'http://www.w3.org/2001/XMLSchema';
            element_handler.properties.subelement_properties['{}date'].base.name = 'dateTime';
            element_handler.properties.subelement_properties['{}date'].local_facets = {};
            element_handler.properties.subelement_properties['{}date'].facets = basic_stuff.inherit_facets(element_handler.properties.subelement_properties['{}date']);
        end

        do
            element_handler.properties.subelement_properties['{}date'].type_handler = require('org.w3.2001.XMLSchema.dateTime_handler'):instantiate();
            element_handler.properties.subelement_properties['{}date'].get_attributes = basic_stuff.get_attributes;
            element_handler.properties.subelement_properties['{}date'].is_valid = basic_stuff.simple_is_valid;
            element_handler.properties.subelement_properties['{}date'].to_xmlua = basic_stuff.simple_to_xmlua;
            element_handler.properties.subelement_properties['{}date'].get_unique_namespaces_declared = basic_stuff.simple_get_unique_namespaces_declared;
            element_handler.properties.subelement_properties['{}date'].parse_xml = basic_stuff.parse_xml;
        end

        element_handler.properties.subelement_properties['{}date'].particle_properties.root_element = false;
        element_handler.properties.subelement_properties['{}date'].particle_properties.min_occurs = 1;
        element_handler.properties.subelement_properties['{}date'].particle_properties.max_occurs = 1;
    end

    element_handler.properties.subelement_properties['{}message_body'] = {};
    do
element_handler.properties.subelement_properties['{}message_body'].super_element_content_type = require('org.w3.2001.XMLSchema.string_handler'):instantiate();

element_handler.properties.subelement_properties['{}message_body'].type_of_simple = 'A';

        do
            element_handler.properties.subelement_properties['{}message_body'].properties = {};
            element_handler.properties.subelement_properties['{}message_body'].properties.element_type = 'S';
            element_handler.properties.subelement_properties['{}message_body'].properties.content_type = 'S';
            element_handler.properties.subelement_properties['{}message_body'].properties.schema_type = '{http://www.w3.org/2001/XMLSchema}string';
            element_handler.properties.subelement_properties['{}message_body'].properties.bi_type = {};
            element_handler.properties.subelement_properties['{}message_body'].properties.bi_type.ns = 'http://www.w3.org/2001/XMLSchema';
            element_handler.properties.subelement_properties['{}message_body'].properties.bi_type.name = 'string';
            element_handler.properties.subelement_properties['{}message_body'].properties.bi_type.id = '1';
            element_handler.properties.subelement_properties['{}message_body'].properties.attr = {};
            element_handler.properties.subelement_properties['{}message_body'].properties.attr._attr_properties = {};
            element_handler.properties.subelement_properties['{}message_body'].properties.attr._generated_attr = {};
        end

        do
            element_handler.properties.subelement_properties['{}message_body'].particle_properties = {};
            element_handler.properties.subelement_properties['{}message_body'].particle_properties.q_name = {};
            element_handler.properties.subelement_properties['{}message_body'].particle_properties.q_name.ns = '';
            element_handler.properties.subelement_properties['{}message_body'].particle_properties.q_name.local_name = 'message_body';
            element_handler.properties.subelement_properties['{}message_body'].particle_properties.generated_name = 'message_body';
        end

        -- Simple type properties
        do
            element_handler.properties.subelement_properties['{}message_body'].base = {};
            element_handler.properties.subelement_properties['{}message_body'].base.ns = 'http://www.w3.org/2001/XMLSchema';
            element_handler.properties.subelement_properties['{}message_body'].base.name = 'string';
            element_handler.properties.subelement_properties['{}message_body'].local_facets = {};
            element_handler.properties.subelement_properties['{}message_body'].facets = basic_stuff.inherit_facets(element_handler.properties.subelement_properties['{}message_body']);
        end

        do
            element_handler.properties.subelement_properties['{}message_body'].type_handler = require('org.w3.2001.XMLSchema.string_handler'):instantiate();
            element_handler.properties.subelement_properties['{}message_body'].get_attributes = basic_stuff.get_attributes;
            element_handler.properties.subelement_properties['{}message_body'].is_valid = basic_stuff.simple_is_valid;
            element_handler.properties.subelement_properties['{}message_body'].to_xmlua = basic_stuff.simple_to_xmlua;
            element_handler.properties.subelement_properties['{}message_body'].get_unique_namespaces_declared = basic_stuff.simple_get_unique_namespaces_declared;
            element_handler.properties.subelement_properties['{}message_body'].parse_xml = basic_stuff.parse_xml;
        end

        element_handler.properties.subelement_properties['{}message_body'].particle_properties.root_element = false;
        element_handler.properties.subelement_properties['{}message_body'].particle_properties.min_occurs = 1;
        element_handler.properties.subelement_properties['{}message_body'].particle_properties.max_occurs = 1;
    end

    element_handler.properties.subelement_properties['{}cc'] = {};
    do
element_handler.properties.subelement_properties['{}cc'].super_element_content_type = require('org.w3.2001.XMLSchema.token_handler'):instantiate();

element_handler.properties.subelement_properties['{}cc'].type_of_simple = 'A';

        do
            element_handler.properties.subelement_properties['{}cc'].properties = {};
            element_handler.properties.subelement_properties['{}cc'].properties.element_type = 'S';
            element_handler.properties.subelement_properties['{}cc'].properties.content_type = 'S';
            element_handler.properties.subelement_properties['{}cc'].properties.schema_type = '{http://www.w3.org/2001/XMLSchema}token';
            element_handler.properties.subelement_properties['{}cc'].properties.bi_type = {};
            element_handler.properties.subelement_properties['{}cc'].properties.bi_type.ns = 'http://www.w3.org/2001/XMLSchema';
            element_handler.properties.subelement_properties['{}cc'].properties.bi_type.name = 'token';
            element_handler.properties.subelement_properties['{}cc'].properties.bi_type.id = '16';
            element_handler.properties.subelement_properties['{}cc'].properties.attr = {};
            element_handler.properties.subelement_properties['{}cc'].properties.attr._attr_properties = {};
            element_handler.properties.subelement_properties['{}cc'].properties.attr._generated_attr = {};
        end

        do
            element_handler.properties.subelement_properties['{}cc'].particle_properties = {};
            element_handler.properties.subelement_properties['{}cc'].particle_properties.q_name = {};
            element_handler.properties.subelement_properties['{}cc'].particle_properties.q_name.ns = '';
            element_handler.properties.subelement_properties['{}cc'].particle_properties.q_name.local_name = 'cc';
            element_handler.properties.subelement_properties['{}cc'].particle_properties.generated_name = 'cc';
        end

        -- Simple type properties
        do
            element_handler.properties.subelement_properties['{}cc'].base = {};
            element_handler.properties.subelement_properties['{}cc'].base.ns = 'http://www.w3.org/2001/XMLSchema';
            element_handler.properties.subelement_properties['{}cc'].base.name = 'token';
            element_handler.properties.subelement_properties['{}cc'].local_facets = {};
            element_handler.properties.subelement_properties['{}cc'].facets = basic_stuff.inherit_facets(element_handler.properties.subelement_properties['{}cc']);
        end

        do
            element_handler.properties.subelement_properties['{}cc'].type_handler = require('org.w3.2001.XMLSchema.token_handler'):instantiate();
            element_handler.properties.subelement_properties['{}cc'].get_attributes = basic_stuff.get_attributes;
            element_handler.properties.subelement_properties['{}cc'].is_valid = basic_stuff.simple_is_valid;
            element_handler.properties.subelement_properties['{}cc'].to_xmlua = basic_stuff.simple_to_xmlua;
            element_handler.properties.subelement_properties['{}cc'].get_unique_namespaces_declared = basic_stuff.simple_get_unique_namespaces_declared;
            element_handler.properties.subelement_properties['{}cc'].parse_xml = basic_stuff.parse_xml;
        end

        element_handler.properties.subelement_properties['{}cc'].particle_properties.root_element = false;
        element_handler.properties.subelement_properties['{}cc'].particle_properties.min_occurs = 1;
        element_handler.properties.subelement_properties['{}cc'].particle_properties.max_occurs = 1;
    end

    element_handler.properties.subelement_properties['{}return_path'] = {};
    do
element_handler.properties.subelement_properties['{}return_path'].super_element_content_type = require('org.w3.2001.XMLSchema.token_handler'):instantiate();

element_handler.properties.subelement_properties['{}return_path'].type_of_simple = 'A';

        do
            element_handler.properties.subelement_properties['{}return_path'].properties = {};
            element_handler.properties.subelement_properties['{}return_path'].properties.element_type = 'S';
            element_handler.properties.subelement_properties['{}return_path'].properties.content_type = 'S';
            element_handler.properties.subelement_properties['{}return_path'].properties.schema_type = '{http://evpoco.tekenlight.org}email_id_type';
            element_handler.properties.subelement_properties['{}return_path'].properties.bi_type = {};
            element_handler.properties.subelement_properties['{}return_path'].properties.bi_type.ns = 'http://www.w3.org/2001/XMLSchema';
            element_handler.properties.subelement_properties['{}return_path'].properties.bi_type.name = 'token';
            element_handler.properties.subelement_properties['{}return_path'].properties.bi_type.id = '0';
            element_handler.properties.subelement_properties['{}return_path'].properties.attr = {};
            element_handler.properties.subelement_properties['{}return_path'].properties.attr._attr_properties = {};
            element_handler.properties.subelement_properties['{}return_path'].properties.attr._generated_attr = {};
        end

        do
            element_handler.properties.subelement_properties['{}return_path'].particle_properties = {};
            element_handler.properties.subelement_properties['{}return_path'].particle_properties.q_name = {};
            element_handler.properties.subelement_properties['{}return_path'].particle_properties.q_name.ns = '';
            element_handler.properties.subelement_properties['{}return_path'].particle_properties.q_name.local_name = 'return_path';
            element_handler.properties.subelement_properties['{}return_path'].particle_properties.generated_name = 'return_path';
        end

        -- Simple type properties
        do
            element_handler.properties.subelement_properties['{}return_path'].base = {};
            element_handler.properties.subelement_properties['{}return_path'].base.ns = 'http://www.w3.org/2001/XMLSchema';
            element_handler.properties.subelement_properties['{}return_path'].base.name = 'token';
            element_handler.properties.subelement_properties['{}return_path'].local_facets = {};
            element_handler.properties.subelement_properties['{}return_path'].local_facets.max_length = 320;
            element_handler.properties.subelement_properties['{}return_path'].local_facets.pattern = {};
            element_handler.properties.subelement_properties['{}return_path'].local_facets.pattern[1] = {};
            element_handler.properties.subelement_properties['{}return_path'].local_facets.pattern[1].str_p = [=[([0-9a-zA-Z]([-._\w]*[0-9a-zA-Z])*@([0-9a-zA-Z][-\w]*[0-9a-zA-Z]\.)+[a-zA-Z]{2,9})]=];
            element_handler.properties.subelement_properties['{}return_path'].local_facets.pattern[1].com_p = nil;
            element_handler.properties.subelement_properties['{}return_path'].facets = basic_stuff.inherit_facets(element_handler.properties.subelement_properties['{}return_path']);
        end

        do
            element_handler.properties.subelement_properties['{}return_path'].type_handler = require('org.w3.2001.XMLSchema.token_handler'):instantiate();
            element_handler.properties.subelement_properties['{}return_path'].get_attributes = basic_stuff.get_attributes;
            element_handler.properties.subelement_properties['{}return_path'].is_valid = basic_stuff.simple_is_valid;
            element_handler.properties.subelement_properties['{}return_path'].to_xmlua = basic_stuff.simple_to_xmlua;
            element_handler.properties.subelement_properties['{}return_path'].get_unique_namespaces_declared = basic_stuff.simple_get_unique_namespaces_declared;
            element_handler.properties.subelement_properties['{}return_path'].parse_xml = basic_stuff.parse_xml;
        end

        element_handler.properties.subelement_properties['{}return_path'].particle_properties.root_element = false;
        element_handler.properties.subelement_properties['{}return_path'].particle_properties.min_occurs = 1;
        element_handler.properties.subelement_properties['{}return_path'].particle_properties.max_occurs = 1;
    end

end

do
    element_handler.properties.generated_subelements = {
        ['id'] = element_handler.properties.subelement_properties['{}id']
        ,['date'] = element_handler.properties.subelement_properties['{}date']
        ,['from'] = element_handler.properties.subelement_properties['{}from']
        ,['return_path'] = element_handler.properties.subelement_properties['{}return_path']
        ,['delivered_to'] = element_handler.properties.subelement_properties['{}delivered_to']
        ,['to'] = element_handler.properties.subelement_properties['{}to']
        ,['cc'] = element_handler.properties.subelement_properties['{}cc']
        ,['subject'] = element_handler.properties.subelement_properties['{}subject']
        ,['message_body'] = element_handler.properties.subelement_properties['{}message_body']
        ,['attachments'] = element_handler.properties.subelement_properties['{}attachments']
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
