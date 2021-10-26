local basic_stuff = require("lua_schema.basic_stuff");
local eh_cache = require("lua_schema.eh_cache");

local element_handler = {};
element_handler.__name__ = 'validation_type';

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

eh_cache.add('{http://evpoco.tekenlight.org/message_rules}validation_type', _factory);


do
    element_handler.properties = {};
    element_handler.properties.element_type = 'C';
    element_handler.properties.content_type = 'E';
    element_handler.properties.schema_type = '{http://evpoco.tekenlight.org/message_rules}validation_type';
    element_handler.properties.q_name = {};
    element_handler.properties.q_name.ns = 'http://evpoco.tekenlight.org/message_rules'
    element_handler.properties.q_name.local_name = 'validation_type'

    -- No particle properties for a typedef

    element_handler.properties.attr = {};
    element_handler.properties.attr._attr_properties = {};
    do
        element_handler.properties.attr._attr_properties['{}method'] = {};

        element_handler.properties.attr._attr_properties['{}method'].base = {};
        element_handler.properties.attr._attr_properties['{}method'].base.ns = 'http://www.w3.org/2001/XMLSchema';
        element_handler.properties.attr._attr_properties['{}method'].base.name = 'token';
        element_handler.properties.attr._attr_properties['{}method'].bi_type = {};
        element_handler.properties.attr._attr_properties['{}method'].bi_type.ns = 'http://www.w3.org/2001/XMLSchema';
        element_handler.properties.attr._attr_properties['{}method'].bi_type.name = 'token';
        element_handler.properties.attr._attr_properties['{}method'].bi_type.id = '16';
        element_handler.properties.attr._attr_properties['{}method'].properties = {};
        element_handler.properties.attr._attr_properties['{}method'].properties.schema_type = '{http://www.w3.org/2001/XMLSchema}token';
        element_handler.properties.attr._attr_properties['{}method'].properties.default = '';
        element_handler.properties.attr._attr_properties['{}method'].properties.fixed = false;
        element_handler.properties.attr._attr_properties['{}method'].properties.use = 'R';
        element_handler.properties.attr._attr_properties['{}method'].properties.form = 'U';

        element_handler.properties.attr._attr_properties['{}method'].particle_properties = {};
        element_handler.properties.attr._attr_properties['{}method'].particle_properties.q_name = {};
        element_handler.properties.attr._attr_properties['{}method'].particle_properties.q_name.ns = '';
        element_handler.properties.attr._attr_properties['{}method'].particle_properties.q_name.local_name = 'method';
        element_handler.properties.attr._attr_properties['{}method'].particle_properties.generated_name = 'method';

        element_handler.properties.attr._attr_properties['{}method'].type_handler = require('org.w3.2001.XMLSchema.token_handler'):instantiate();

        element_handler.properties.attr._attr_properties['{}method'].super_element_content_type = require('org.w3.2001.XMLSchema.token_handler'):instantiate();
        element_handler.properties.attr._attr_properties['{}method'].type_of_simple = 'A';
        element_handler.properties.attr._attr_properties['{}method'].local_facets = {}
        element_handler.properties.attr._attr_properties['{}method'].facets = basic_stuff.inherit_facets(element_handler.properties.attr._attr_properties['{}method']);
    end
    do
        element_handler.properties.attr._attr_properties['{}package'] = {};

        element_handler.properties.attr._attr_properties['{}package'].base = {};
        element_handler.properties.attr._attr_properties['{}package'].base.ns = 'http://www.w3.org/2001/XMLSchema';
        element_handler.properties.attr._attr_properties['{}package'].base.name = 'token';
        element_handler.properties.attr._attr_properties['{}package'].bi_type = {};
        element_handler.properties.attr._attr_properties['{}package'].bi_type.ns = 'http://www.w3.org/2001/XMLSchema';
        element_handler.properties.attr._attr_properties['{}package'].bi_type.name = 'token';
        element_handler.properties.attr._attr_properties['{}package'].bi_type.id = '16';
        element_handler.properties.attr._attr_properties['{}package'].properties = {};
        element_handler.properties.attr._attr_properties['{}package'].properties.schema_type = '{http://www.w3.org/2001/XMLSchema}token';
        element_handler.properties.attr._attr_properties['{}package'].properties.default = '';
        element_handler.properties.attr._attr_properties['{}package'].properties.fixed = false;
        element_handler.properties.attr._attr_properties['{}package'].properties.use = 'R';
        element_handler.properties.attr._attr_properties['{}package'].properties.form = 'U';

        element_handler.properties.attr._attr_properties['{}package'].particle_properties = {};
        element_handler.properties.attr._attr_properties['{}package'].particle_properties.q_name = {};
        element_handler.properties.attr._attr_properties['{}package'].particle_properties.q_name.ns = '';
        element_handler.properties.attr._attr_properties['{}package'].particle_properties.q_name.local_name = 'package';
        element_handler.properties.attr._attr_properties['{}package'].particle_properties.generated_name = 'package';

        element_handler.properties.attr._attr_properties['{}package'].type_handler = require('org.w3.2001.XMLSchema.token_handler'):instantiate();

        element_handler.properties.attr._attr_properties['{}package'].super_element_content_type = require('org.w3.2001.XMLSchema.token_handler'):instantiate();
        element_handler.properties.attr._attr_properties['{}package'].type_of_simple = 'A';
        element_handler.properties.attr._attr_properties['{}package'].local_facets = {}
        element_handler.properties.attr._attr_properties['{}package'].facets = basic_stuff.inherit_facets(element_handler.properties.attr._attr_properties['{}package']);
    end
    do
        element_handler.properties.attr._attr_properties['{}inputs'] = {};

        element_handler.properties.attr._attr_properties['{}inputs'].base = {};
        element_handler.properties.attr._attr_properties['{}inputs'].base.ns = 'http://www.w3.org/2001/XMLSchema';
        element_handler.properties.attr._attr_properties['{}inputs'].base.name = 'token';
        element_handler.properties.attr._attr_properties['{}inputs'].bi_type = {};
        element_handler.properties.attr._attr_properties['{}inputs'].bi_type.ns = 'http://www.w3.org/2001/XMLSchema';
        element_handler.properties.attr._attr_properties['{}inputs'].bi_type.name = 'token';
        element_handler.properties.attr._attr_properties['{}inputs'].bi_type.id = '16';
        element_handler.properties.attr._attr_properties['{}inputs'].properties = {};
        element_handler.properties.attr._attr_properties['{}inputs'].properties.schema_type = '{http://www.w3.org/2001/XMLSchema}token';
        element_handler.properties.attr._attr_properties['{}inputs'].properties.default = '';
        element_handler.properties.attr._attr_properties['{}inputs'].properties.fixed = false;
        element_handler.properties.attr._attr_properties['{}inputs'].properties.use = 'R';
        element_handler.properties.attr._attr_properties['{}inputs'].properties.form = 'U';

        element_handler.properties.attr._attr_properties['{}inputs'].particle_properties = {};
        element_handler.properties.attr._attr_properties['{}inputs'].particle_properties.q_name = {};
        element_handler.properties.attr._attr_properties['{}inputs'].particle_properties.q_name.ns = '';
        element_handler.properties.attr._attr_properties['{}inputs'].particle_properties.q_name.local_name = 'inputs';
        element_handler.properties.attr._attr_properties['{}inputs'].particle_properties.generated_name = 'inputs';

        element_handler.properties.attr._attr_properties['{}inputs'].type_handler = require('org.w3.2001.XMLSchema.token_handler'):instantiate();

        element_handler.properties.attr._attr_properties['{}inputs'].super_element_content_type = require('org.w3.2001.XMLSchema.token_handler'):instantiate();
        element_handler.properties.attr._attr_properties['{}inputs'].type_of_simple = 'A';
        element_handler.properties.attr._attr_properties['{}inputs'].local_facets = {}
        element_handler.properties.attr._attr_properties['{}inputs'].facets = basic_stuff.inherit_facets(element_handler.properties.attr._attr_properties['{}inputs']);
    end
    element_handler.properties.attr._generated_attr = {};
    element_handler.properties.attr._generated_attr['method'] = '{}method';
    element_handler.properties.attr._generated_attr['inputs'] = '{}inputs';
    element_handler.properties.attr._generated_attr['package'] = '{}package';
end

-- element_handler.properties.content_model
do
    element_handler.properties.content_model = {
    };
end

-- element_handler.properties.content_fsa_properties
do
    element_handler.properties.content_fsa_properties = {
    };
end

do
    element_handler.properties.declared_subelements = {
    };
end

do
    element_handler.properties.subelement_properties = {};
end

do
    element_handler.properties.generated_subelements = {
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
