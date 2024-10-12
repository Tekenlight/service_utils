local basic_stuff = require("lua_schema.basic_stuff");
local eh_cache = require("lua_schema.eh_cache");

local element_handler = {};
element_handler.__name__ = 'host_config_rec_type';

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

eh_cache.add('{http://evpoco.tekenlight.org/idl_spec}host_config_rec_type', _factory);


do
    element_handler.properties = {};
    element_handler.properties.element_type = 'C';
    element_handler.properties.content_type = 'C';
    element_handler.properties.schema_type = '{http://evpoco.tekenlight.org/idl_spec}host_config_rec_type';
    element_handler.properties.q_name = {};
    element_handler.properties.q_name.ns = 'http://evpoco.tekenlight.org/idl_spec'
    element_handler.properties.q_name.local_name = 'host_config_rec_type'

    -- No particle properties for a typedef

    element_handler.properties.attr = {};
    element_handler.properties.attr._attr_properties = {};
    element_handler.properties.attr._generated_attr = {};
end

-- element_handler.properties.content_model
do
    element_handler.properties.content_model = {
        generated_subelement_name = '_sequence_group',
        max_occurs = 1,
        min_occurs = 1,
        top_level_group = true,
        group_type = 'S',
        'host',
        'port',
        'secure',
        'protocol',
    };
end

-- element_handler.properties.content_fsa_properties
do
    element_handler.properties.content_fsa_properties = {
        {symbol_type = 'cm_begin', symbol_name = '_sequence_group', generated_symbol_name = '_sequence_group', min_occurs = 1, max_occurs = 1, cm = element_handler.properties.content_model}
        ,{symbol_type = 'element', symbol_name = '{}host', generated_symbol_name = '{}host', min_occurs = 1, max_occurs = 1, wild_card_type = 0, generated_name = 'host', cm = element_handler.properties.content_model}
        ,{symbol_type = 'element', symbol_name = '{}port', generated_symbol_name = '{}port', min_occurs = 0, max_occurs = 1, wild_card_type = 0, generated_name = 'port', cm = element_handler.properties.content_model}
        ,{symbol_type = 'element', symbol_name = '{}secure', generated_symbol_name = '{}secure', min_occurs = 0, max_occurs = 1, wild_card_type = 0, generated_name = 'secure', cm = element_handler.properties.content_model}
        ,{symbol_type = 'element', symbol_name = '{}protocol', generated_symbol_name = '{}protocol', min_occurs = 0, max_occurs = 1, wild_card_type = 0, generated_name = 'protocol', cm = element_handler.properties.content_model}
        ,{symbol_type = 'cm_end', symbol_name = '_sequence_group', generated_symbol_name = '_sequence_group', cm_begin_index = 1, cm = element_handler.properties.content_model}
    };
end

do
    element_handler.properties.declared_subelements = {
        '{}host'
        ,'{}port'
        ,'{}secure'
        ,'{}protocol'
    };
end

do
    element_handler.properties.subelement_properties = {};
    element_handler.properties.subelement_properties['{}protocol'] = {};
    do
element_handler.properties.subelement_properties['{}protocol'].super_element_content_type = require('org.w3.2001.XMLSchema.string_handler'):instantiate();

element_handler.properties.subelement_properties['{}protocol'].type_of_simple = 'A';

        do
            element_handler.properties.subelement_properties['{}protocol'].properties = {};
            element_handler.properties.subelement_properties['{}protocol'].properties.element_type = 'S';
            element_handler.properties.subelement_properties['{}protocol'].properties.content_type = 'S';
            element_handler.properties.subelement_properties['{}protocol'].properties.schema_type = '{http://www.w3.org/2001/XMLSchema}string';
            element_handler.properties.subelement_properties['{}protocol'].properties.bi_type = {};
            element_handler.properties.subelement_properties['{}protocol'].properties.bi_type.ns = 'http://www.w3.org/2001/XMLSchema';
            element_handler.properties.subelement_properties['{}protocol'].properties.bi_type.name = 'string';
            element_handler.properties.subelement_properties['{}protocol'].properties.bi_type.id = '1';
            element_handler.properties.subelement_properties['{}protocol'].properties.attr = {};
            element_handler.properties.subelement_properties['{}protocol'].properties.attr._attr_properties = {};
            element_handler.properties.subelement_properties['{}protocol'].properties.attr._generated_attr = {};
        end

        do
            element_handler.properties.subelement_properties['{}protocol'].particle_properties = {};
            element_handler.properties.subelement_properties['{}protocol'].particle_properties.q_name = {};
            element_handler.properties.subelement_properties['{}protocol'].particle_properties.q_name.ns = '';
            element_handler.properties.subelement_properties['{}protocol'].particle_properties.q_name.local_name = 'protocol';
            element_handler.properties.subelement_properties['{}protocol'].particle_properties.generated_name = 'protocol';
        end

        -- Simple type properties
        do
            element_handler.properties.subelement_properties['{}protocol'].base = {};
            element_handler.properties.subelement_properties['{}protocol'].base.ns = 'http://www.w3.org/2001/XMLSchema';
            element_handler.properties.subelement_properties['{}protocol'].base.name = 'string';
            element_handler.properties.subelement_properties['{}protocol'].local_facets = {};
            element_handler.properties.subelement_properties['{}protocol'].facets = basic_stuff.inherit_facets(element_handler.properties.subelement_properties['{}protocol']);
        end

        do
            element_handler.properties.subelement_properties['{}protocol'].type_handler = require('org.w3.2001.XMLSchema.string_handler'):instantiate();
            element_handler.properties.subelement_properties['{}protocol'].get_attributes = basic_stuff.get_attributes;
            element_handler.properties.subelement_properties['{}protocol'].is_valid = basic_stuff.simple_is_valid;
            element_handler.properties.subelement_properties['{}protocol'].to_xmlua = basic_stuff.simple_to_xmlua;
            element_handler.properties.subelement_properties['{}protocol'].get_unique_namespaces_declared = basic_stuff.simple_get_unique_namespaces_declared;
            element_handler.properties.subelement_properties['{}protocol'].parse_xml = basic_stuff.parse_xml;
        end

        element_handler.properties.subelement_properties['{}protocol'].particle_properties.root_element = false;
        element_handler.properties.subelement_properties['{}protocol'].particle_properties.min_occurs = 0;
        element_handler.properties.subelement_properties['{}protocol'].particle_properties.max_occurs = 1;
    end

    element_handler.properties.subelement_properties['{}host'] = {};
    do
element_handler.properties.subelement_properties['{}host'].super_element_content_type = require('org.w3.2001.XMLSchema.anyURI_handler'):instantiate();

element_handler.properties.subelement_properties['{}host'].type_of_simple = 'A';

        do
            element_handler.properties.subelement_properties['{}host'].properties = {};
            element_handler.properties.subelement_properties['{}host'].properties.element_type = 'S';
            element_handler.properties.subelement_properties['{}host'].properties.content_type = 'S';
            element_handler.properties.subelement_properties['{}host'].properties.schema_type = '{http://evpoco.tekenlight.org/idl_spec}host_url_type';
            element_handler.properties.subelement_properties['{}host'].properties.bi_type = {};
            element_handler.properties.subelement_properties['{}host'].properties.bi_type.ns = 'http://www.w3.org/2001/XMLSchema';
            element_handler.properties.subelement_properties['{}host'].properties.bi_type.name = 'anyURI';
            element_handler.properties.subelement_properties['{}host'].properties.bi_type.id = '0';
            element_handler.properties.subelement_properties['{}host'].properties.attr = {};
            element_handler.properties.subelement_properties['{}host'].properties.attr._attr_properties = {};
            element_handler.properties.subelement_properties['{}host'].properties.attr._generated_attr = {};
        end

        do
            element_handler.properties.subelement_properties['{}host'].particle_properties = {};
            element_handler.properties.subelement_properties['{}host'].particle_properties.q_name = {};
            element_handler.properties.subelement_properties['{}host'].particle_properties.q_name.ns = '';
            element_handler.properties.subelement_properties['{}host'].particle_properties.q_name.local_name = 'host';
            element_handler.properties.subelement_properties['{}host'].particle_properties.generated_name = 'host';
        end

        -- Simple type properties
        do
            element_handler.properties.subelement_properties['{}host'].base = {};
            element_handler.properties.subelement_properties['{}host'].base.ns = 'http://www.w3.org/2001/XMLSchema';
            element_handler.properties.subelement_properties['{}host'].base.name = 'anyURI';
            element_handler.properties.subelement_properties['{}host'].local_facets = {};
            element_handler.properties.subelement_properties['{}host'].facets = basic_stuff.inherit_facets(element_handler.properties.subelement_properties['{}host']);
        end

        do
            element_handler.properties.subelement_properties['{}host'].type_handler = require('org.w3.2001.XMLSchema.anyURI_handler'):instantiate();
            element_handler.properties.subelement_properties['{}host'].get_attributes = basic_stuff.get_attributes;
            element_handler.properties.subelement_properties['{}host'].is_valid = basic_stuff.simple_is_valid;
            element_handler.properties.subelement_properties['{}host'].to_xmlua = basic_stuff.simple_to_xmlua;
            element_handler.properties.subelement_properties['{}host'].get_unique_namespaces_declared = basic_stuff.simple_get_unique_namespaces_declared;
            element_handler.properties.subelement_properties['{}host'].parse_xml = basic_stuff.parse_xml;
        end

        element_handler.properties.subelement_properties['{}host'].particle_properties.root_element = false;
        element_handler.properties.subelement_properties['{}host'].particle_properties.min_occurs = 1;
        element_handler.properties.subelement_properties['{}host'].particle_properties.max_occurs = 1;
    end

    element_handler.properties.subelement_properties['{}port'] = {};
    do
element_handler.properties.subelement_properties['{}port'].super_element_content_type = require('org.w3.2001.XMLSchema.int_handler'):instantiate();

element_handler.properties.subelement_properties['{}port'].type_of_simple = 'A';

        do
            element_handler.properties.subelement_properties['{}port'].properties = {};
            element_handler.properties.subelement_properties['{}port'].properties.element_type = 'S';
            element_handler.properties.subelement_properties['{}port'].properties.content_type = 'S';
            element_handler.properties.subelement_properties['{}port'].properties.schema_type = '{http://www.w3.org/2001/XMLSchema}int';
            element_handler.properties.subelement_properties['{}port'].properties.bi_type = {};
            element_handler.properties.subelement_properties['{}port'].properties.bi_type.ns = 'http://www.w3.org/2001/XMLSchema';
            element_handler.properties.subelement_properties['{}port'].properties.bi_type.name = 'int';
            element_handler.properties.subelement_properties['{}port'].properties.bi_type.id = '35';
            element_handler.properties.subelement_properties['{}port'].properties.attr = {};
            element_handler.properties.subelement_properties['{}port'].properties.attr._attr_properties = {};
            element_handler.properties.subelement_properties['{}port'].properties.attr._generated_attr = {};
        end

        do
            element_handler.properties.subelement_properties['{}port'].particle_properties = {};
            element_handler.properties.subelement_properties['{}port'].particle_properties.q_name = {};
            element_handler.properties.subelement_properties['{}port'].particle_properties.q_name.ns = '';
            element_handler.properties.subelement_properties['{}port'].particle_properties.q_name.local_name = 'port';
            element_handler.properties.subelement_properties['{}port'].particle_properties.generated_name = 'port';
        end

        -- Simple type properties
        do
            element_handler.properties.subelement_properties['{}port'].base = {};
            element_handler.properties.subelement_properties['{}port'].base.ns = 'http://www.w3.org/2001/XMLSchema';
            element_handler.properties.subelement_properties['{}port'].base.name = 'int';
            element_handler.properties.subelement_properties['{}port'].local_facets = {};
            element_handler.properties.subelement_properties['{}port'].facets = basic_stuff.inherit_facets(element_handler.properties.subelement_properties['{}port']);
        end

        do
            element_handler.properties.subelement_properties['{}port'].type_handler = require('org.w3.2001.XMLSchema.int_handler'):instantiate();
            element_handler.properties.subelement_properties['{}port'].get_attributes = basic_stuff.get_attributes;
            element_handler.properties.subelement_properties['{}port'].is_valid = basic_stuff.simple_is_valid;
            element_handler.properties.subelement_properties['{}port'].to_xmlua = basic_stuff.simple_to_xmlua;
            element_handler.properties.subelement_properties['{}port'].get_unique_namespaces_declared = basic_stuff.simple_get_unique_namespaces_declared;
            element_handler.properties.subelement_properties['{}port'].parse_xml = basic_stuff.parse_xml;
        end

        element_handler.properties.subelement_properties['{}port'].particle_properties.root_element = false;
        element_handler.properties.subelement_properties['{}port'].particle_properties.min_occurs = 0;
        element_handler.properties.subelement_properties['{}port'].particle_properties.max_occurs = 1;
    end

    element_handler.properties.subelement_properties['{}secure'] = {};
    do
element_handler.properties.subelement_properties['{}secure'].super_element_content_type = require('org.w3.2001.XMLSchema.boolean_handler'):instantiate();

element_handler.properties.subelement_properties['{}secure'].type_of_simple = 'A';

        do
            element_handler.properties.subelement_properties['{}secure'].properties = {};
            element_handler.properties.subelement_properties['{}secure'].properties.element_type = 'S';
            element_handler.properties.subelement_properties['{}secure'].properties.content_type = 'S';
            element_handler.properties.subelement_properties['{}secure'].properties.schema_type = '{http://www.w3.org/2001/XMLSchema}boolean';
            element_handler.properties.subelement_properties['{}secure'].properties.bi_type = {};
            element_handler.properties.subelement_properties['{}secure'].properties.bi_type.ns = 'http://www.w3.org/2001/XMLSchema';
            element_handler.properties.subelement_properties['{}secure'].properties.bi_type.name = 'boolean';
            element_handler.properties.subelement_properties['{}secure'].properties.bi_type.id = '15';
            element_handler.properties.subelement_properties['{}secure'].properties.attr = {};
            element_handler.properties.subelement_properties['{}secure'].properties.attr._attr_properties = {};
            element_handler.properties.subelement_properties['{}secure'].properties.attr._generated_attr = {};
        end

        do
            element_handler.properties.subelement_properties['{}secure'].particle_properties = {};
            element_handler.properties.subelement_properties['{}secure'].particle_properties.q_name = {};
            element_handler.properties.subelement_properties['{}secure'].particle_properties.q_name.ns = '';
            element_handler.properties.subelement_properties['{}secure'].particle_properties.q_name.local_name = 'secure';
            element_handler.properties.subelement_properties['{}secure'].particle_properties.generated_name = 'secure';
        end

        -- Simple type properties
        do
            element_handler.properties.subelement_properties['{}secure'].base = {};
            element_handler.properties.subelement_properties['{}secure'].base.ns = 'http://www.w3.org/2001/XMLSchema';
            element_handler.properties.subelement_properties['{}secure'].base.name = 'boolean';
            element_handler.properties.subelement_properties['{}secure'].local_facets = {};
            element_handler.properties.subelement_properties['{}secure'].facets = basic_stuff.inherit_facets(element_handler.properties.subelement_properties['{}secure']);
        end

        do
            element_handler.properties.subelement_properties['{}secure'].type_handler = require('org.w3.2001.XMLSchema.boolean_handler'):instantiate();
            element_handler.properties.subelement_properties['{}secure'].get_attributes = basic_stuff.get_attributes;
            element_handler.properties.subelement_properties['{}secure'].is_valid = basic_stuff.simple_is_valid;
            element_handler.properties.subelement_properties['{}secure'].to_xmlua = basic_stuff.simple_to_xmlua;
            element_handler.properties.subelement_properties['{}secure'].get_unique_namespaces_declared = basic_stuff.simple_get_unique_namespaces_declared;
            element_handler.properties.subelement_properties['{}secure'].parse_xml = basic_stuff.parse_xml;
        end

        element_handler.properties.subelement_properties['{}secure'].particle_properties.root_element = false;
        element_handler.properties.subelement_properties['{}secure'].particle_properties.min_occurs = 0;
        element_handler.properties.subelement_properties['{}secure'].particle_properties.max_occurs = 1;
    end

end

do
    element_handler.properties.generated_subelements = {
        ['host'] = element_handler.properties.subelement_properties['{}host']
        ,['port'] = element_handler.properties.subelement_properties['{}port']
        ,['secure'] = element_handler.properties.subelement_properties['{}secure']
        ,['protocol'] = element_handler.properties.subelement_properties['{}protocol']
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
