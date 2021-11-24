local basic_stuff = require("lua_schema.basic_stuff");
local eh_cache = require("lua_schema.eh_cache");

local element_handler = {};
element_handler.__name__ = 'input_dtls_type';

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

eh_cache.add('{http://evpoco.tekenlight.org/idl_spec}input_dtls_type', _factory);


do
    element_handler.properties = {};
    element_handler.properties.element_type = 'C';
    element_handler.properties.content_type = 'E';
    element_handler.properties.schema_type = '{http://evpoco.tekenlight.org/idl_spec}input_dtls_type';
    element_handler.properties.q_name = {};
    element_handler.properties.q_name.ns = 'http://evpoco.tekenlight.org/idl_spec'
    element_handler.properties.q_name.local_name = 'input_dtls_type'

    -- No particle properties for a typedef

    element_handler.properties.attr = {};
    element_handler.properties.attr._attr_properties = {};
    do
        element_handler.properties.attr._attr_properties['{}namespace'] = {};

        element_handler.properties.attr._attr_properties['{}namespace'].base = {};
        element_handler.properties.attr._attr_properties['{}namespace'].base.ns = 'http://www.w3.org/2001/XMLSchema';
        element_handler.properties.attr._attr_properties['{}namespace'].base.name = 'token';
        element_handler.properties.attr._attr_properties['{}namespace'].bi_type = {};
        element_handler.properties.attr._attr_properties['{}namespace'].bi_type.ns = 'http://www.w3.org/2001/XMLSchema';
        element_handler.properties.attr._attr_properties['{}namespace'].bi_type.name = 'token';
        element_handler.properties.attr._attr_properties['{}namespace'].bi_type.id = '16';
        element_handler.properties.attr._attr_properties['{}namespace'].properties = {};
        element_handler.properties.attr._attr_properties['{}namespace'].properties.schema_type = '{http://www.w3.org/2001/XMLSchema}token';
        element_handler.properties.attr._attr_properties['{}namespace'].properties.default = '';
        element_handler.properties.attr._attr_properties['{}namespace'].properties.fixed = false;
        element_handler.properties.attr._attr_properties['{}namespace'].properties.use = 'R';
        element_handler.properties.attr._attr_properties['{}namespace'].properties.form = 'U';

        element_handler.properties.attr._attr_properties['{}namespace'].particle_properties = {};
        element_handler.properties.attr._attr_properties['{}namespace'].particle_properties.q_name = {};
        element_handler.properties.attr._attr_properties['{}namespace'].particle_properties.q_name.ns = '';
        element_handler.properties.attr._attr_properties['{}namespace'].particle_properties.q_name.local_name = 'namespace';
        element_handler.properties.attr._attr_properties['{}namespace'].particle_properties.generated_name = 'namespace';

        element_handler.properties.attr._attr_properties['{}namespace'].type_handler = require('org.w3.2001.XMLSchema.token_handler'):instantiate();

        element_handler.properties.attr._attr_properties['{}namespace'].super_element_content_type = require('org.w3.2001.XMLSchema.token_handler'):instantiate();
        element_handler.properties.attr._attr_properties['{}namespace'].type_of_simple = 'A';
        element_handler.properties.attr._attr_properties['{}namespace'].local_facets = {}
        element_handler.properties.attr._attr_properties['{}namespace'].facets = basic_stuff.inherit_facets(element_handler.properties.attr._attr_properties['{}namespace']);
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
    element_handler.properties.attr._generated_attr = {};
    element_handler.properties.attr._generated_attr['namespace'] = '{}namespace';
    element_handler.properties.attr._generated_attr['name'] = '{}name';
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
