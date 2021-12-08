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
        top_level_group = true,
        group_type = 'S',
        min_occurs = 1,
        max_occurs = 1,
        generated_subelement_name = '_sequence_group',
        'host',
        'port',
    };
end

-- element_handler.properties.content_fsa_properties
do
    element_handler.properties.content_fsa_properties = {
        {symbol_type = 'cm_begin', symbol_name = '_sequence_group', generated_symbol_name = '_sequence_group', min_occurs = 1, max_occurs = 1, cm = element_handler.properties.content_model}
        ,{symbol_type = 'element', symbol_name = '{}host', generated_symbol_name = '{}host', min_occurs = 1, max_occurs = 1, wild_card_type = 0, generated_name = 'host', cm = element_handler.properties.content_model}
        ,{symbol_type = 'element', symbol_name = '{}port', generated_symbol_name = '{}port', min_occurs = 1, max_occurs = 1, wild_card_type = 0, generated_name = 'port', cm = element_handler.properties.content_model}
        ,{symbol_type = 'cm_end', symbol_name = '_sequence_group', generated_symbol_name = '_sequence_group', cm_begin_index = 1, cm = element_handler.properties.content_model}
    };
end

do
    element_handler.properties.declared_subelements = {
        '{}host'
        ,'{}port'
    };
end

do
    element_handler.properties.subelement_properties = {};
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
        element_handler.properties.subelement_properties['{}port'].particle_properties.min_occurs = 1;
        element_handler.properties.subelement_properties['{}port'].particle_properties.max_occurs = 1;
    end

    element_handler.properties.subelement_properties['{}host'] = {};
    do
element_handler.properties.subelement_properties['{}host'].super_element_content_type = require('org.w3.2001.XMLSchema.token_handler'):instantiate();

element_handler.properties.subelement_properties['{}host'].type_of_simple = 'A';

        do
            element_handler.properties.subelement_properties['{}host'].properties = {};
            element_handler.properties.subelement_properties['{}host'].properties.element_type = 'S';
            element_handler.properties.subelement_properties['{}host'].properties.content_type = 'S';
            element_handler.properties.subelement_properties['{}host'].properties.schema_type = '{http://evpoco.tekenlight.org/idl_spec}host_ipv4_address_type';
            element_handler.properties.subelement_properties['{}host'].properties.bi_type = {};
            element_handler.properties.subelement_properties['{}host'].properties.bi_type.ns = 'http://www.w3.org/2001/XMLSchema';
            element_handler.properties.subelement_properties['{}host'].properties.bi_type.name = 'token';
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
            element_handler.properties.subelement_properties['{}host'].base.name = 'token';
            element_handler.properties.subelement_properties['{}host'].local_facets = {};
            element_handler.properties.subelement_properties['{}host'].local_facets.pattern = {};
            element_handler.properties.subelement_properties['{}host'].local_facets.pattern[1] = {};
            element_handler.properties.subelement_properties['{}host'].local_facets.pattern[1].str_p = [=[[\d]+\.[\d]+\.[\d]+\.[\d]+]=];
            element_handler.properties.subelement_properties['{}host'].local_facets.pattern[1].com_p = nil;
            element_handler.properties.subelement_properties['{}host'].facets = basic_stuff.inherit_facets(element_handler.properties.subelement_properties['{}host']);
        end

        do
            element_handler.properties.subelement_properties['{}host'].type_handler = require('org.w3.2001.XMLSchema.token_handler'):instantiate();
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

end

do
    element_handler.properties.generated_subelements = {
        ['host'] = element_handler.properties.subelement_properties['{}host']
        ,['port'] = element_handler.properties.subelement_properties['{}port']
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
