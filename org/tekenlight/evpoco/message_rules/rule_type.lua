local basic_stuff = require("lua_schema.basic_stuff");
local eh_cache = require("lua_schema.eh_cache");

local element_handler = {};
element_handler.__name__ = 'rule_type';

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

eh_cache.add('{http://evpoco.tekenlight.org/message_rules}rule_type', _factory);


do
    element_handler.properties = {};
    element_handler.properties.element_type = 'C';
    element_handler.properties.content_type = 'C';
    element_handler.properties.schema_type = '{http://evpoco.tekenlight.org/message_rules}rule_type';
    element_handler.properties.q_name = {};
    element_handler.properties.q_name.ns = 'http://evpoco.tekenlight.org/message_rules'
    element_handler.properties.q_name.local_name = 'rule_type'

    -- No particle properties for a typedef

    element_handler.properties.attr = {};
    element_handler.properties.attr._attr_properties = {};
    do
        element_handler.properties.attr._attr_properties['{}type'] = {};

        element_handler.properties.attr._attr_properties['{}type'].base = {};
        element_handler.properties.attr._attr_properties['{}type'].base.ns = 'http://www.w3.org/2001/XMLSchema';
        element_handler.properties.attr._attr_properties['{}type'].base.name = 'token';
        element_handler.properties.attr._attr_properties['{}type'].bi_type = {};
        element_handler.properties.attr._attr_properties['{}type'].bi_type.ns = 'http://www.w3.org/2001/XMLSchema';
        element_handler.properties.attr._attr_properties['{}type'].bi_type.name = 'token';
        element_handler.properties.attr._attr_properties['{}type'].bi_type.id = '0';
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
        element_handler.properties.attr._attr_properties['{}type'].local_facets.enumeration = {};
        element_handler.properties.attr._attr_properties['{}type'].local_facets.enumeration[1] = 'independent';
        element_handler.properties.attr._attr_properties['{}type'].local_facets.enumeration[2] = 'dependent';
        element_handler.properties.attr._attr_properties['{}type'].facets = basic_stuff.inherit_facets(element_handler.properties.attr._attr_properties['{}type']);
    end
    element_handler.properties.attr._generated_attr = {};
    element_handler.properties.attr._generated_attr['type'] = '{}type';
end

-- element_handler.properties.content_model
do
    element_handler.properties.content_model = {
        top_level_group = true,
        generated_subelement_name = '_choice_group',
        group_type = 'C',
        max_occurs = 1,
        min_occurs = 1,
        {
            top_level_group = false,
            generated_subelement_name = '_sequence_group',
            group_type = 'S',
            max_occurs = 1,
            min_occurs = 1,
            'assertion',
            'error',
        },
        'validation',
    };
end

-- element_handler.properties.content_fsa_properties
do
    element_handler.properties.content_fsa_properties = {
        {symbol_type = 'cm_begin', symbol_name = '_choice_group', generated_symbol_name = '_choice_group', min_occurs = 1, max_occurs = 1, cm = element_handler.properties.content_model}
        ,{symbol_type = 'cm_begin', symbol_name = '_sequence_group', generated_symbol_name = '_sequence_group', min_occurs = 1, max_occurs = 1, cm = element_handler.properties.content_model[1]}
        ,{symbol_type = 'element', symbol_name = '{}assertion', generated_symbol_name = '{}assertion', min_occurs = 1, max_occurs = 1, wild_card_type = 0, generated_name = 'assertion', cm = element_handler.properties.content_model[1]}
        ,{symbol_type = 'element', symbol_name = '{}error', generated_symbol_name = '{}error', min_occurs = 1, max_occurs = 1, wild_card_type = 0, generated_name = 'error', cm = element_handler.properties.content_model[1]}
        ,{symbol_type = 'cm_end', symbol_name = '_sequence_group', generated_symbol_name = '_sequence_group', cm_begin_index = 2, cm = element_handler.properties.content_model[1]}
        ,{symbol_type = 'element', symbol_name = '{}validation', generated_symbol_name = '{}validation', min_occurs = 1, max_occurs = 1, wild_card_type = 0, generated_name = 'validation', cm = element_handler.properties.content_model}
        ,{symbol_type = 'cm_end', symbol_name = '_choice_group', generated_symbol_name = '_choice_group', cm_begin_index = 1, cm = element_handler.properties.content_model}
    };
end

do
    element_handler.properties.declared_subelements = {
        '{}assertion'
        ,'{}error'
        ,'{}validation'
    };
end

do
    element_handler.properties.subelement_properties = {};
    element_handler.properties.subelement_properties['{}error'] = {};
    do
element_handler.properties.subelement_properties['{}error'].super_element_content_type = require('org.w3.2001.XMLSchema.token_handler'):instantiate();

element_handler.properties.subelement_properties['{}error'].type_of_simple = 'A';

        do
            element_handler.properties.subelement_properties['{}error'].properties = {};
            element_handler.properties.subelement_properties['{}error'].properties.element_type = 'S';
            element_handler.properties.subelement_properties['{}error'].properties.content_type = 'S';
            element_handler.properties.subelement_properties['{}error'].properties.schema_type = '{http://www.w3.org/2001/XMLSchema}token';
            element_handler.properties.subelement_properties['{}error'].properties.bi_type = {};
            element_handler.properties.subelement_properties['{}error'].properties.bi_type.ns = 'http://www.w3.org/2001/XMLSchema';
            element_handler.properties.subelement_properties['{}error'].properties.bi_type.name = 'token';
            element_handler.properties.subelement_properties['{}error'].properties.bi_type.id = '16';
            element_handler.properties.subelement_properties['{}error'].properties.attr = {};
            element_handler.properties.subelement_properties['{}error'].properties.attr._attr_properties = {};
            element_handler.properties.subelement_properties['{}error'].properties.attr._generated_attr = {};
        end

        do
            element_handler.properties.subelement_properties['{}error'].particle_properties = {};
            element_handler.properties.subelement_properties['{}error'].particle_properties.q_name = {};
            element_handler.properties.subelement_properties['{}error'].particle_properties.q_name.ns = '';
            element_handler.properties.subelement_properties['{}error'].particle_properties.q_name.local_name = 'error';
            element_handler.properties.subelement_properties['{}error'].particle_properties.generated_name = 'error';
        end

        -- Simple type properties
        do
            element_handler.properties.subelement_properties['{}error'].base = {};
            element_handler.properties.subelement_properties['{}error'].base.ns = 'http://www.w3.org/2001/XMLSchema';
            element_handler.properties.subelement_properties['{}error'].base.name = 'token';
            element_handler.properties.subelement_properties['{}error'].local_facets = {};
            element_handler.properties.subelement_properties['{}error'].facets = basic_stuff.inherit_facets(element_handler.properties.subelement_properties['{}error']);
        end

        do
            element_handler.properties.subelement_properties['{}error'].type_handler = require('org.w3.2001.XMLSchema.token_handler'):instantiate();
            element_handler.properties.subelement_properties['{}error'].get_attributes = basic_stuff.get_attributes;
            element_handler.properties.subelement_properties['{}error'].is_valid = basic_stuff.simple_is_valid;
            element_handler.properties.subelement_properties['{}error'].to_xmlua = basic_stuff.simple_to_xmlua;
            element_handler.properties.subelement_properties['{}error'].get_unique_namespaces_declared = basic_stuff.simple_get_unique_namespaces_declared;
            element_handler.properties.subelement_properties['{}error'].parse_xml = basic_stuff.parse_xml;
        end

        element_handler.properties.subelement_properties['{}error'].particle_properties.root_element = false;
        element_handler.properties.subelement_properties['{}error'].particle_properties.min_occurs = 1;
        element_handler.properties.subelement_properties['{}error'].particle_properties.max_occurs = 1;
    end

    element_handler.properties.subelement_properties['{}assertion'] = {};
    do
element_handler.properties.subelement_properties['{}assertion'].super_element_content_type = require('org.w3.2001.XMLSchema.token_handler'):instantiate();

element_handler.properties.subelement_properties['{}assertion'].type_of_simple = 'A';

        do
            element_handler.properties.subelement_properties['{}assertion'].properties = {};
            element_handler.properties.subelement_properties['{}assertion'].properties.element_type = 'C';
            element_handler.properties.subelement_properties['{}assertion'].properties.content_type = 'S';
            element_handler.properties.subelement_properties['{}assertion'].properties.schema_type = '{}assertion';
            element_handler.properties.subelement_properties['{}assertion'].properties.bi_type = {};
            element_handler.properties.subelement_properties['{}assertion'].properties.bi_type.ns = 'http://www.w3.org/2001/XMLSchema';
            element_handler.properties.subelement_properties['{}assertion'].properties.bi_type.name = 'token';
            element_handler.properties.subelement_properties['{}assertion'].properties.bi_type.id = '16';
            element_handler.properties.subelement_properties['{}assertion'].properties.attr = {};
            element_handler.properties.subelement_properties['{}assertion'].properties.attr._attr_properties = {};
            do
                element_handler.properties.subelement_properties['{}assertion'].properties.attr._attr_properties['{}condition'] = {};

                element_handler.properties.subelement_properties['{}assertion'].properties.attr._attr_properties['{}condition'].base = {};
                element_handler.properties.subelement_properties['{}assertion'].properties.attr._attr_properties['{}condition'].base.ns = 'http://www.w3.org/2001/XMLSchema';
                element_handler.properties.subelement_properties['{}assertion'].properties.attr._attr_properties['{}condition'].base.name = 'token';
                element_handler.properties.subelement_properties['{}assertion'].properties.attr._attr_properties['{}condition'].bi_type = {};
                element_handler.properties.subelement_properties['{}assertion'].properties.attr._attr_properties['{}condition'].bi_type.ns = 'http://www.w3.org/2001/XMLSchema';
                element_handler.properties.subelement_properties['{}assertion'].properties.attr._attr_properties['{}condition'].bi_type.name = 'token';
                element_handler.properties.subelement_properties['{}assertion'].properties.attr._attr_properties['{}condition'].bi_type.id = '16';
                element_handler.properties.subelement_properties['{}assertion'].properties.attr._attr_properties['{}condition'].properties = {};
                element_handler.properties.subelement_properties['{}assertion'].properties.attr._attr_properties['{}condition'].properties.schema_type = '{http://www.w3.org/2001/XMLSchema}token';
                element_handler.properties.subelement_properties['{}assertion'].properties.attr._attr_properties['{}condition'].properties.default = '';
                element_handler.properties.subelement_properties['{}assertion'].properties.attr._attr_properties['{}condition'].properties.fixed = false;
                element_handler.properties.subelement_properties['{}assertion'].properties.attr._attr_properties['{}condition'].properties.use = 'O';
                element_handler.properties.subelement_properties['{}assertion'].properties.attr._attr_properties['{}condition'].properties.form = 'U';

                element_handler.properties.subelement_properties['{}assertion'].properties.attr._attr_properties['{}condition'].particle_properties = {};
                element_handler.properties.subelement_properties['{}assertion'].properties.attr._attr_properties['{}condition'].particle_properties.q_name = {};
                element_handler.properties.subelement_properties['{}assertion'].properties.attr._attr_properties['{}condition'].particle_properties.q_name.ns = '';
                element_handler.properties.subelement_properties['{}assertion'].properties.attr._attr_properties['{}condition'].particle_properties.q_name.local_name = 'condition';
                element_handler.properties.subelement_properties['{}assertion'].properties.attr._attr_properties['{}condition'].particle_properties.generated_name = 'condition';

                element_handler.properties.subelement_properties['{}assertion'].properties.attr._attr_properties['{}condition'].type_handler = require('org.w3.2001.XMLSchema.token_handler'):instantiate();

                element_handler.properties.subelement_properties['{}assertion'].properties.attr._attr_properties['{}condition'].super_element_content_type = require('org.w3.2001.XMLSchema.token_handler'):instantiate();
                element_handler.properties.subelement_properties['{}assertion'].properties.attr._attr_properties['{}condition'].type_of_simple = 'A';
                element_handler.properties.subelement_properties['{}assertion'].properties.attr._attr_properties['{}condition'].local_facets = {}
                element_handler.properties.subelement_properties['{}assertion'].properties.attr._attr_properties['{}condition'].facets = basic_stuff.inherit_facets(element_handler.properties.subelement_properties['{}assertion'].properties.attr._attr_properties['{}condition']);
            end
            element_handler.properties.subelement_properties['{}assertion'].properties.attr._generated_attr = {};
            element_handler.properties.subelement_properties['{}assertion'].properties.attr._generated_attr['condition'] = '{}condition';
        end

        do
            element_handler.properties.subelement_properties['{}assertion'].particle_properties = {};
            element_handler.properties.subelement_properties['{}assertion'].particle_properties.q_name = {};
            element_handler.properties.subelement_properties['{}assertion'].particle_properties.q_name.ns = '';
            element_handler.properties.subelement_properties['{}assertion'].particle_properties.q_name.local_name = 'assertion';
            element_handler.properties.subelement_properties['{}assertion'].particle_properties.generated_name = 'assertion';
        end

        -- Simple type properties
        do
            element_handler.properties.subelement_properties['{}assertion'].base = {};
            element_handler.properties.subelement_properties['{}assertion'].base.ns = 'http://www.w3.org/2001/XMLSchema';
            element_handler.properties.subelement_properties['{}assertion'].base.name = 'token';
            element_handler.properties.subelement_properties['{}assertion'].local_facets = {};
            element_handler.properties.subelement_properties['{}assertion'].facets = basic_stuff.inherit_facets(element_handler.properties.subelement_properties['{}assertion']);
        end

        do
            element_handler.properties.subelement_properties['{}assertion'].type_handler = require('org.w3.2001.XMLSchema.token_handler'):instantiate();
            element_handler.properties.subelement_properties['{}assertion'].get_attributes = basic_stuff.get_attributes;
            element_handler.properties.subelement_properties['{}assertion'].is_valid = basic_stuff.complex_type_simple_content_is_valid;
            element_handler.properties.subelement_properties['{}assertion'].to_xmlua = basic_stuff.complex_type_simple_content_to_xmlua;
            element_handler.properties.subelement_properties['{}assertion'].get_unique_namespaces_declared = basic_stuff.simple_get_unique_namespaces_declared;
            element_handler.properties.subelement_properties['{}assertion'].parse_xml = basic_stuff.parse_xml;
        end

        element_handler.properties.subelement_properties['{}assertion'].particle_properties.root_element = false;
        element_handler.properties.subelement_properties['{}assertion'].particle_properties.min_occurs = 1;
        element_handler.properties.subelement_properties['{}assertion'].particle_properties.max_occurs = 1;
    end

    do
        element_handler.properties.subelement_properties['{}validation'] = 
            (basic_stuff.get_element_handler('http://evpoco.tekenlight.org/message_rules', 'validation_type'):
            new_instance_as_local_element({ns = '', local_name = 'validation', generated_name = 'validation',
                    root_element = false, min_occurs = 1, max_occurs = 1}));
    end

end

do
    element_handler.properties.generated_subelements = {
        ['assertion'] = element_handler.properties.subelement_properties['{}assertion']
        ,['error'] = element_handler.properties.subelement_properties['{}error']
        ,['validation'] = element_handler.properties.subelement_properties['{}validation']
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
