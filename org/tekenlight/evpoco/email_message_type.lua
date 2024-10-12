local basic_stuff = require("lua_schema.basic_stuff");
local eh_cache = require("lua_schema.eh_cache");

local element_handler = {};
element_handler.__name__ = 'email_message_type';

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

eh_cache.add('{http://evpoco.tekenlight.org}email_message_type', _factory);


do
    element_handler.properties = {};
    element_handler.properties.element_type = 'C';
    element_handler.properties.content_type = 'C';
    element_handler.properties.schema_type = '{http://evpoco.tekenlight.org}email_message_type';
    element_handler.properties.q_name = {};
    element_handler.properties.q_name.ns = 'http://evpoco.tekenlight.org'
    element_handler.properties.q_name.local_name = 'email_message_type'

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
        group_type = 'S',
        max_occurs = 1,
        generated_subelement_name = '_sequence_group',
        'from',
        'password',
        'sender_name',
        'recipients',
        'subject',
        'message_body',
        'attachments',
    };
end

-- element_handler.properties.content_fsa_properties
do
    element_handler.properties.content_fsa_properties = {
        {symbol_type = 'cm_begin', symbol_name = '_sequence_group', generated_symbol_name = '_sequence_group', min_occurs = 1, max_occurs = 1, cm = element_handler.properties.content_model}
        ,{symbol_type = 'element', symbol_name = '{}from', generated_symbol_name = '{}from', min_occurs = 1, max_occurs = 1, wild_card_type = 0, generated_name = 'from', cm = element_handler.properties.content_model}
        ,{symbol_type = 'element', symbol_name = '{}password', generated_symbol_name = '{}password', min_occurs = 1, max_occurs = 1, wild_card_type = 0, generated_name = 'password', cm = element_handler.properties.content_model}
        ,{symbol_type = 'element', symbol_name = '{}sender_name', generated_symbol_name = '{}sender_name', min_occurs = 0, max_occurs = 1, wild_card_type = 0, generated_name = 'sender_name', cm = element_handler.properties.content_model}
        ,{symbol_type = 'element', symbol_name = '{}recipients', generated_symbol_name = '{}recipients', min_occurs = 1, max_occurs = -1, wild_card_type = 0, generated_name = 'recipients', cm = element_handler.properties.content_model}
        ,{symbol_type = 'element', symbol_name = '{}subject', generated_symbol_name = '{}subject', min_occurs = 1, max_occurs = 1, wild_card_type = 0, generated_name = 'subject', cm = element_handler.properties.content_model}
        ,{symbol_type = 'element', symbol_name = '{}message_body', generated_symbol_name = '{}message_body', min_occurs = 1, max_occurs = 1, wild_card_type = 0, generated_name = 'message_body', cm = element_handler.properties.content_model}
        ,{symbol_type = 'element', symbol_name = '{}attachments', generated_symbol_name = '{}attachments', min_occurs = 0, max_occurs = -1, wild_card_type = 0, generated_name = 'attachments', cm = element_handler.properties.content_model}
        ,{symbol_type = 'cm_end', symbol_name = '_sequence_group', generated_symbol_name = '_sequence_group', cm_begin_index = 1, cm = element_handler.properties.content_model}
    };
end

do
    element_handler.properties.declared_subelements = {
        '{}from'
        ,'{}password'
        ,'{}sender_name'
        ,'{}recipients'
        ,'{}subject'
        ,'{}message_body'
        ,'{}attachments'
    };
end

do
    element_handler.properties.subelement_properties = {};
    do
        element_handler.properties.subelement_properties['{}attachments'] = 
            (basic_stuff.get_element_handler('http://evpoco.tekenlight.org', 'attachment_dtls_type'):
            new_instance_as_local_element({ns = '', local_name = 'attachments', generated_name = 'attachments',
                    root_element = false, min_occurs = 0, max_occurs = -1}));
    end

    do
        element_handler.properties.subelement_properties['{}recipients'] = 
            (basic_stuff.get_element_handler('http://evpoco.tekenlight.org', 'recipient_dtls_type'):
            new_instance_as_local_element({ns = '', local_name = 'recipients', generated_name = 'recipients',
                    root_element = false, min_occurs = 1, max_occurs = -1}));
    end

    element_handler.properties.subelement_properties['{}password'] = {};
    do
element_handler.properties.subelement_properties['{}password'].super_element_content_type = require('org.w3.2001.XMLSchema.string_handler'):instantiate();

element_handler.properties.subelement_properties['{}password'].type_of_simple = 'A';

        do
            element_handler.properties.subelement_properties['{}password'].properties = {};
            element_handler.properties.subelement_properties['{}password'].properties.element_type = 'S';
            element_handler.properties.subelement_properties['{}password'].properties.content_type = 'S';
            element_handler.properties.subelement_properties['{}password'].properties.schema_type = '{http://www.w3.org/2001/XMLSchema}string';
            element_handler.properties.subelement_properties['{}password'].properties.bi_type = {};
            element_handler.properties.subelement_properties['{}password'].properties.bi_type.ns = 'http://www.w3.org/2001/XMLSchema';
            element_handler.properties.subelement_properties['{}password'].properties.bi_type.name = 'string';
            element_handler.properties.subelement_properties['{}password'].properties.bi_type.id = '1';
            element_handler.properties.subelement_properties['{}password'].properties.attr = {};
            element_handler.properties.subelement_properties['{}password'].properties.attr._attr_properties = {};
            element_handler.properties.subelement_properties['{}password'].properties.attr._generated_attr = {};
        end

        do
            element_handler.properties.subelement_properties['{}password'].particle_properties = {};
            element_handler.properties.subelement_properties['{}password'].particle_properties.q_name = {};
            element_handler.properties.subelement_properties['{}password'].particle_properties.q_name.ns = '';
            element_handler.properties.subelement_properties['{}password'].particle_properties.q_name.local_name = 'password';
            element_handler.properties.subelement_properties['{}password'].particle_properties.generated_name = 'password';
        end

        -- Simple type properties
        do
            element_handler.properties.subelement_properties['{}password'].base = {};
            element_handler.properties.subelement_properties['{}password'].base.ns = 'http://www.w3.org/2001/XMLSchema';
            element_handler.properties.subelement_properties['{}password'].base.name = 'string';
            element_handler.properties.subelement_properties['{}password'].local_facets = {};
            element_handler.properties.subelement_properties['{}password'].facets = basic_stuff.inherit_facets(element_handler.properties.subelement_properties['{}password']);
        end

        do
            element_handler.properties.subelement_properties['{}password'].type_handler = require('org.w3.2001.XMLSchema.string_handler'):instantiate();
            element_handler.properties.subelement_properties['{}password'].get_attributes = basic_stuff.get_attributes;
            element_handler.properties.subelement_properties['{}password'].is_valid = basic_stuff.simple_is_valid;
            element_handler.properties.subelement_properties['{}password'].to_xmlua = basic_stuff.simple_to_xmlua;
            element_handler.properties.subelement_properties['{}password'].get_unique_namespaces_declared = basic_stuff.simple_get_unique_namespaces_declared;
            element_handler.properties.subelement_properties['{}password'].parse_xml = basic_stuff.parse_xml;
        end

        element_handler.properties.subelement_properties['{}password'].particle_properties.root_element = false;
        element_handler.properties.subelement_properties['{}password'].particle_properties.min_occurs = 1;
        element_handler.properties.subelement_properties['{}password'].particle_properties.max_occurs = 1;
    end

    element_handler.properties.subelement_properties['{}from'] = {};
    do
element_handler.properties.subelement_properties['{}from'].super_element_content_type = require('org.w3.2001.XMLSchema.token_handler'):instantiate();

element_handler.properties.subelement_properties['{}from'].type_of_simple = 'A';

        do
            element_handler.properties.subelement_properties['{}from'].properties = {};
            element_handler.properties.subelement_properties['{}from'].properties.element_type = 'S';
            element_handler.properties.subelement_properties['{}from'].properties.content_type = 'S';
            element_handler.properties.subelement_properties['{}from'].properties.schema_type = '{http://evpoco.tekenlight.org}email_id_type';
            element_handler.properties.subelement_properties['{}from'].properties.bi_type = {};
            element_handler.properties.subelement_properties['{}from'].properties.bi_type.ns = 'http://www.w3.org/2001/XMLSchema';
            element_handler.properties.subelement_properties['{}from'].properties.bi_type.name = 'token';
            element_handler.properties.subelement_properties['{}from'].properties.bi_type.id = '0';
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
            element_handler.properties.subelement_properties['{}from'].local_facets.max_length = 320;
            element_handler.properties.subelement_properties['{}from'].local_facets.pattern = {};
            element_handler.properties.subelement_properties['{}from'].local_facets.pattern[1] = {};
            element_handler.properties.subelement_properties['{}from'].local_facets.pattern[1].str_p = [=[([0-9a-zA-Z]([-._\w]*[0-9a-zA-Z])*@([0-9a-zA-Z][-\w]*[0-9a-zA-Z]\.)+[a-zA-Z]{2,9})]=];
            element_handler.properties.subelement_properties['{}from'].local_facets.pattern[1].com_p = nil;
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

    element_handler.properties.subelement_properties['{}sender_name'] = {};
    do
element_handler.properties.subelement_properties['{}sender_name'].super_element_content_type = require('org.w3.2001.XMLSchema.token_handler'):instantiate();

element_handler.properties.subelement_properties['{}sender_name'].type_of_simple = 'A';

        do
            element_handler.properties.subelement_properties['{}sender_name'].properties = {};
            element_handler.properties.subelement_properties['{}sender_name'].properties.element_type = 'S';
            element_handler.properties.subelement_properties['{}sender_name'].properties.content_type = 'S';
            element_handler.properties.subelement_properties['{}sender_name'].properties.schema_type = '{http://evpoco.tekenlight.org}user_name_type';
            element_handler.properties.subelement_properties['{}sender_name'].properties.bi_type = {};
            element_handler.properties.subelement_properties['{}sender_name'].properties.bi_type.ns = 'http://www.w3.org/2001/XMLSchema';
            element_handler.properties.subelement_properties['{}sender_name'].properties.bi_type.name = 'token';
            element_handler.properties.subelement_properties['{}sender_name'].properties.bi_type.id = '0';
            element_handler.properties.subelement_properties['{}sender_name'].properties.attr = {};
            element_handler.properties.subelement_properties['{}sender_name'].properties.attr._attr_properties = {};
            element_handler.properties.subelement_properties['{}sender_name'].properties.attr._generated_attr = {};
        end

        do
            element_handler.properties.subelement_properties['{}sender_name'].particle_properties = {};
            element_handler.properties.subelement_properties['{}sender_name'].particle_properties.q_name = {};
            element_handler.properties.subelement_properties['{}sender_name'].particle_properties.q_name.ns = '';
            element_handler.properties.subelement_properties['{}sender_name'].particle_properties.q_name.local_name = 'sender_name';
            element_handler.properties.subelement_properties['{}sender_name'].particle_properties.generated_name = 'sender_name';
        end

        -- Simple type properties
        do
            element_handler.properties.subelement_properties['{}sender_name'].base = {};
            element_handler.properties.subelement_properties['{}sender_name'].base.ns = 'http://www.w3.org/2001/XMLSchema';
            element_handler.properties.subelement_properties['{}sender_name'].base.name = 'token';
            element_handler.properties.subelement_properties['{}sender_name'].local_facets = {};
            element_handler.properties.subelement_properties['{}sender_name'].local_facets.max_length = 256;
            element_handler.properties.subelement_properties['{}sender_name'].facets = basic_stuff.inherit_facets(element_handler.properties.subelement_properties['{}sender_name']);
        end

        do
            element_handler.properties.subelement_properties['{}sender_name'].type_handler = require('org.w3.2001.XMLSchema.token_handler'):instantiate();
            element_handler.properties.subelement_properties['{}sender_name'].get_attributes = basic_stuff.get_attributes;
            element_handler.properties.subelement_properties['{}sender_name'].is_valid = basic_stuff.simple_is_valid;
            element_handler.properties.subelement_properties['{}sender_name'].to_xmlua = basic_stuff.simple_to_xmlua;
            element_handler.properties.subelement_properties['{}sender_name'].get_unique_namespaces_declared = basic_stuff.simple_get_unique_namespaces_declared;
            element_handler.properties.subelement_properties['{}sender_name'].parse_xml = basic_stuff.parse_xml;
        end

        element_handler.properties.subelement_properties['{}sender_name'].particle_properties.root_element = false;
        element_handler.properties.subelement_properties['{}sender_name'].particle_properties.min_occurs = 0;
        element_handler.properties.subelement_properties['{}sender_name'].particle_properties.max_occurs = 1;
    end

end

do
    element_handler.properties.generated_subelements = {
        ['from'] = element_handler.properties.subelement_properties['{}from']
        ,['password'] = element_handler.properties.subelement_properties['{}password']
        ,['sender_name'] = element_handler.properties.subelement_properties['{}sender_name']
        ,['recipients'] = element_handler.properties.subelement_properties['{}recipients']
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
