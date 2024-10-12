local basic_stuff = require("lua_schema.basic_stuff");
local eh_cache = require("lua_schema.eh_cache");

local element_handler = {};
element_handler.__name__ = 'method_type';

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

eh_cache.add('{http://evpoco.tekenlight.org/idl_spec}method_type', _factory);


do
    element_handler.properties = {};
    element_handler.properties.element_type = 'C';
    element_handler.properties.content_type = 'C';
    element_handler.properties.schema_type = '{http://evpoco.tekenlight.org/idl_spec}method_type';
    element_handler.properties.q_name = {};
    element_handler.properties.q_name.ns = 'http://evpoco.tekenlight.org/idl_spec'
    element_handler.properties.q_name.local_name = 'method_type'

    -- No particle properties for a typedef

    element_handler.properties.attr = {};
    element_handler.properties.attr._attr_properties = {};
    do
        element_handler.properties.attr._attr_properties['{}transactional'] = {};

        element_handler.properties.attr._attr_properties['{}transactional'].base = {};
        element_handler.properties.attr._attr_properties['{}transactional'].base.ns = 'http://www.w3.org/2001/XMLSchema';
        element_handler.properties.attr._attr_properties['{}transactional'].base.name = 'boolean';
        element_handler.properties.attr._attr_properties['{}transactional'].bi_type = {};
        element_handler.properties.attr._attr_properties['{}transactional'].bi_type.ns = 'http://www.w3.org/2001/XMLSchema';
        element_handler.properties.attr._attr_properties['{}transactional'].bi_type.name = 'boolean';
        element_handler.properties.attr._attr_properties['{}transactional'].bi_type.id = '15';
        element_handler.properties.attr._attr_properties['{}transactional'].properties = {};
        element_handler.properties.attr._attr_properties['{}transactional'].properties.schema_type = '{http://www.w3.org/2001/XMLSchema}boolean';
        element_handler.properties.attr._attr_properties['{}transactional'].properties.default = '';
        element_handler.properties.attr._attr_properties['{}transactional'].properties.fixed = false;
        element_handler.properties.attr._attr_properties['{}transactional'].properties.use = 'R';
        element_handler.properties.attr._attr_properties['{}transactional'].properties.form = 'U';

        element_handler.properties.attr._attr_properties['{}transactional'].particle_properties = {};
        element_handler.properties.attr._attr_properties['{}transactional'].particle_properties.q_name = {};
        element_handler.properties.attr._attr_properties['{}transactional'].particle_properties.q_name.ns = '';
        element_handler.properties.attr._attr_properties['{}transactional'].particle_properties.q_name.local_name = 'transactional';
        element_handler.properties.attr._attr_properties['{}transactional'].particle_properties.generated_name = 'transactional';

        element_handler.properties.attr._attr_properties['{}transactional'].type_handler = require('org.w3.2001.XMLSchema.boolean_handler'):instantiate();

        element_handler.properties.attr._attr_properties['{}transactional'].super_element_content_type = require('org.w3.2001.XMLSchema.boolean_handler'):instantiate();
        element_handler.properties.attr._attr_properties['{}transactional'].type_of_simple = 'A';
        element_handler.properties.attr._attr_properties['{}transactional'].local_facets = {}
        element_handler.properties.attr._attr_properties['{}transactional'].facets = basic_stuff.inherit_facets(element_handler.properties.attr._attr_properties['{}transactional']);
    end
    do
        element_handler.properties.attr._attr_properties['{}http_method'] = {};

        element_handler.properties.attr._attr_properties['{}http_method'].base = {};
        element_handler.properties.attr._attr_properties['{}http_method'].base.ns = 'http://www.w3.org/2001/XMLSchema';
        element_handler.properties.attr._attr_properties['{}http_method'].base.name = 'token';
        element_handler.properties.attr._attr_properties['{}http_method'].bi_type = {};
        element_handler.properties.attr._attr_properties['{}http_method'].bi_type.ns = 'http://www.w3.org/2001/XMLSchema';
        element_handler.properties.attr._attr_properties['{}http_method'].bi_type.name = 'token';
        element_handler.properties.attr._attr_properties['{}http_method'].bi_type.id = '0';
        element_handler.properties.attr._attr_properties['{}http_method'].properties = {};
        element_handler.properties.attr._attr_properties['{}http_method'].properties.schema_type = '{http://www.w3.org/2001/XMLSchema}token';
        element_handler.properties.attr._attr_properties['{}http_method'].properties.default = '';
        element_handler.properties.attr._attr_properties['{}http_method'].properties.fixed = false;
        element_handler.properties.attr._attr_properties['{}http_method'].properties.use = 'R';
        element_handler.properties.attr._attr_properties['{}http_method'].properties.form = 'U';

        element_handler.properties.attr._attr_properties['{}http_method'].particle_properties = {};
        element_handler.properties.attr._attr_properties['{}http_method'].particle_properties.q_name = {};
        element_handler.properties.attr._attr_properties['{}http_method'].particle_properties.q_name.ns = '';
        element_handler.properties.attr._attr_properties['{}http_method'].particle_properties.q_name.local_name = 'http_method';
        element_handler.properties.attr._attr_properties['{}http_method'].particle_properties.generated_name = 'http_method';

        element_handler.properties.attr._attr_properties['{}http_method'].type_handler = require('org.w3.2001.XMLSchema.token_handler'):instantiate();

        element_handler.properties.attr._attr_properties['{}http_method'].super_element_content_type = require('org.w3.2001.XMLSchema.token_handler'):instantiate();
        element_handler.properties.attr._attr_properties['{}http_method'].type_of_simple = 'A';
        element_handler.properties.attr._attr_properties['{}http_method'].local_facets = {}
        element_handler.properties.attr._attr_properties['{}http_method'].local_facets.enumeration = {};
        element_handler.properties.attr._attr_properties['{}http_method'].local_facets.enumeration[1] = 'GET';
        element_handler.properties.attr._attr_properties['{}http_method'].local_facets.enumeration[2] = 'PUT';
        element_handler.properties.attr._attr_properties['{}http_method'].local_facets.enumeration[3] = 'POST';
        element_handler.properties.attr._attr_properties['{}http_method'].local_facets.enumeration[4] = 'DELETE';
        element_handler.properties.attr._attr_properties['{}http_method'].facets = basic_stuff.inherit_facets(element_handler.properties.attr._attr_properties['{}http_method']);
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
    do
        element_handler.properties.attr._attr_properties['{}db_schema_name'] = {};

        element_handler.properties.attr._attr_properties['{}db_schema_name'].base = {};
        element_handler.properties.attr._attr_properties['{}db_schema_name'].base.ns = 'http://www.w3.org/2001/XMLSchema';
        element_handler.properties.attr._attr_properties['{}db_schema_name'].base.name = 'token';
        element_handler.properties.attr._attr_properties['{}db_schema_name'].bi_type = {};
        element_handler.properties.attr._attr_properties['{}db_schema_name'].bi_type.ns = 'http://www.w3.org/2001/XMLSchema';
        element_handler.properties.attr._attr_properties['{}db_schema_name'].bi_type.name = 'token';
        element_handler.properties.attr._attr_properties['{}db_schema_name'].bi_type.id = '16';
        element_handler.properties.attr._attr_properties['{}db_schema_name'].properties = {};
        element_handler.properties.attr._attr_properties['{}db_schema_name'].properties.schema_type = '{http://www.w3.org/2001/XMLSchema}token';
        element_handler.properties.attr._attr_properties['{}db_schema_name'].properties.default = '';
        element_handler.properties.attr._attr_properties['{}db_schema_name'].properties.fixed = false;
        element_handler.properties.attr._attr_properties['{}db_schema_name'].properties.use = 'O';
        element_handler.properties.attr._attr_properties['{}db_schema_name'].properties.form = 'U';

        element_handler.properties.attr._attr_properties['{}db_schema_name'].particle_properties = {};
        element_handler.properties.attr._attr_properties['{}db_schema_name'].particle_properties.q_name = {};
        element_handler.properties.attr._attr_properties['{}db_schema_name'].particle_properties.q_name.ns = '';
        element_handler.properties.attr._attr_properties['{}db_schema_name'].particle_properties.q_name.local_name = 'db_schema_name';
        element_handler.properties.attr._attr_properties['{}db_schema_name'].particle_properties.generated_name = 'db_schema_name';

        element_handler.properties.attr._attr_properties['{}db_schema_name'].type_handler = require('org.w3.2001.XMLSchema.token_handler'):instantiate();

        element_handler.properties.attr._attr_properties['{}db_schema_name'].super_element_content_type = require('org.w3.2001.XMLSchema.token_handler'):instantiate();
        element_handler.properties.attr._attr_properties['{}db_schema_name'].type_of_simple = 'A';
        element_handler.properties.attr._attr_properties['{}db_schema_name'].local_facets = {}
        element_handler.properties.attr._attr_properties['{}db_schema_name'].facets = basic_stuff.inherit_facets(element_handler.properties.attr._attr_properties['{}db_schema_name']);
    end
    element_handler.properties.attr._generated_attr = {};
    element_handler.properties.attr._generated_attr['http_method'] = '{}http_method';
    element_handler.properties.attr._generated_attr['db_schema_name'] = '{}db_schema_name';
    element_handler.properties.attr._generated_attr['transactional'] = '{}transactional';
    element_handler.properties.attr._generated_attr['name'] = '{}name';
end

-- element_handler.properties.content_model
do
    element_handler.properties.content_model = {
        generated_subelement_name = '_sequence_group',
        max_occurs = 1,
        min_occurs = 1,
        top_level_group = true,
        group_type = 'S',
        'documentation',
        'query_param',
        'input',
        'output',
    };
end

-- element_handler.properties.content_fsa_properties
do
    element_handler.properties.content_fsa_properties = {
        {symbol_type = 'cm_begin', symbol_name = '_sequence_group', generated_symbol_name = '_sequence_group', min_occurs = 1, max_occurs = 1, cm = element_handler.properties.content_model}
        ,{symbol_type = 'element', symbol_name = '{}documentation', generated_symbol_name = '{}documentation', min_occurs = 1, max_occurs = 1, wild_card_type = 0, generated_name = 'documentation', cm = element_handler.properties.content_model}
        ,{symbol_type = 'element', symbol_name = '{}query_param', generated_symbol_name = '{}query_param', min_occurs = 0, max_occurs = -1, wild_card_type = 0, generated_name = 'query_param', cm = element_handler.properties.content_model}
        ,{symbol_type = 'element', symbol_name = '{}input', generated_symbol_name = '{}input', min_occurs = 0, max_occurs = 1, wild_card_type = 0, generated_name = 'input', cm = element_handler.properties.content_model}
        ,{symbol_type = 'element', symbol_name = '{}output', generated_symbol_name = '{}output', min_occurs = 0, max_occurs = 1, wild_card_type = 0, generated_name = 'output', cm = element_handler.properties.content_model}
        ,{symbol_type = 'cm_end', symbol_name = '_sequence_group', generated_symbol_name = '_sequence_group', cm_begin_index = 1, cm = element_handler.properties.content_model}
    };
end

do
    element_handler.properties.declared_subelements = {
        '{}documentation'
        ,'{}query_param'
        ,'{}input'
        ,'{}output'
    };
end

do
    element_handler.properties.subelement_properties = {};
    do
        element_handler.properties.subelement_properties['{}output'] = 
            (basic_stuff.get_element_handler('http://evpoco.tekenlight.org/idl_spec', 'output_dtls_type'):
            new_instance_as_local_element({ns = '', local_name = 'output', generated_name = 'output',
                    root_element = false, min_occurs = 0, max_occurs = 1}));
    end

    do
        element_handler.properties.subelement_properties['{}input'] = 
            (basic_stuff.get_element_handler('http://evpoco.tekenlight.org/idl_spec', 'input_dtls_type'):
            new_instance_as_local_element({ns = '', local_name = 'input', generated_name = 'input',
                    root_element = false, min_occurs = 0, max_occurs = 1}));
    end

    do
        element_handler.properties.subelement_properties['{}query_param'] = 
            (basic_stuff.get_element_handler('http://evpoco.tekenlight.org/idl_spec', 'input_dtls_type'):
            new_instance_as_local_element({ns = '', local_name = 'query_param', generated_name = 'query_param',
                    root_element = false, min_occurs = 0, max_occurs = -1}));
    end

    element_handler.properties.subelement_properties['{}documentation'] = {};
    do
element_handler.properties.subelement_properties['{}documentation'].super_element_content_type = require('org.w3.2001.XMLSchema.string_handler'):instantiate();

element_handler.properties.subelement_properties['{}documentation'].type_of_simple = 'A';

        do
            element_handler.properties.subelement_properties['{}documentation'].properties = {};
            element_handler.properties.subelement_properties['{}documentation'].properties.element_type = 'S';
            element_handler.properties.subelement_properties['{}documentation'].properties.content_type = 'S';
            element_handler.properties.subelement_properties['{}documentation'].properties.schema_type = '{http://www.w3.org/2001/XMLSchema}string';
            element_handler.properties.subelement_properties['{}documentation'].properties.bi_type = {};
            element_handler.properties.subelement_properties['{}documentation'].properties.bi_type.ns = 'http://www.w3.org/2001/XMLSchema';
            element_handler.properties.subelement_properties['{}documentation'].properties.bi_type.name = 'string';
            element_handler.properties.subelement_properties['{}documentation'].properties.bi_type.id = '1';
            element_handler.properties.subelement_properties['{}documentation'].properties.attr = {};
            element_handler.properties.subelement_properties['{}documentation'].properties.attr._attr_properties = {};
            element_handler.properties.subelement_properties['{}documentation'].properties.attr._generated_attr = {};
        end

        do
            element_handler.properties.subelement_properties['{}documentation'].particle_properties = {};
            element_handler.properties.subelement_properties['{}documentation'].particle_properties.q_name = {};
            element_handler.properties.subelement_properties['{}documentation'].particle_properties.q_name.ns = '';
            element_handler.properties.subelement_properties['{}documentation'].particle_properties.q_name.local_name = 'documentation';
            element_handler.properties.subelement_properties['{}documentation'].particle_properties.generated_name = 'documentation';
        end

        -- Simple type properties
        do
            element_handler.properties.subelement_properties['{}documentation'].base = {};
            element_handler.properties.subelement_properties['{}documentation'].base.ns = 'http://www.w3.org/2001/XMLSchema';
            element_handler.properties.subelement_properties['{}documentation'].base.name = 'string';
            element_handler.properties.subelement_properties['{}documentation'].local_facets = {};
            element_handler.properties.subelement_properties['{}documentation'].facets = basic_stuff.inherit_facets(element_handler.properties.subelement_properties['{}documentation']);
        end

        do
            element_handler.properties.subelement_properties['{}documentation'].type_handler = require('org.w3.2001.XMLSchema.string_handler'):instantiate();
            element_handler.properties.subelement_properties['{}documentation'].get_attributes = basic_stuff.get_attributes;
            element_handler.properties.subelement_properties['{}documentation'].is_valid = basic_stuff.simple_is_valid;
            element_handler.properties.subelement_properties['{}documentation'].to_xmlua = basic_stuff.simple_to_xmlua;
            element_handler.properties.subelement_properties['{}documentation'].get_unique_namespaces_declared = basic_stuff.simple_get_unique_namespaces_declared;
            element_handler.properties.subelement_properties['{}documentation'].parse_xml = basic_stuff.parse_xml;
        end

        element_handler.properties.subelement_properties['{}documentation'].particle_properties.root_element = false;
        element_handler.properties.subelement_properties['{}documentation'].particle_properties.min_occurs = 1;
        element_handler.properties.subelement_properties['{}documentation'].particle_properties.max_occurs = 1;
    end

end

do
    element_handler.properties.generated_subelements = {
        ['documentation'] = element_handler.properties.subelement_properties['{}documentation']
        ,['query_param'] = element_handler.properties.subelement_properties['{}query_param']
        ,['input'] = element_handler.properties.subelement_properties['{}input']
        ,['output'] = element_handler.properties.subelement_properties['{}output']
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
