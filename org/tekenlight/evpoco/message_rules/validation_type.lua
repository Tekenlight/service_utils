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
        element_handler.properties.attr._attr_properties['{}ae_condition'] = {};

        element_handler.properties.attr._attr_properties['{}ae_condition'].base = {};
        element_handler.properties.attr._attr_properties['{}ae_condition'].base.ns = 'http://www.w3.org/2001/XMLSchema';
        element_handler.properties.attr._attr_properties['{}ae_condition'].base.name = 'token';
        element_handler.properties.attr._attr_properties['{}ae_condition'].bi_type = {};
        element_handler.properties.attr._attr_properties['{}ae_condition'].bi_type.ns = 'http://www.w3.org/2001/XMLSchema';
        element_handler.properties.attr._attr_properties['{}ae_condition'].bi_type.name = 'token';
        element_handler.properties.attr._attr_properties['{}ae_condition'].bi_type.id = '16';
        element_handler.properties.attr._attr_properties['{}ae_condition'].properties = {};
        element_handler.properties.attr._attr_properties['{}ae_condition'].properties.schema_type = '{http://www.w3.org/2001/XMLSchema}token';
        element_handler.properties.attr._attr_properties['{}ae_condition'].properties.default = '';
        element_handler.properties.attr._attr_properties['{}ae_condition'].properties.fixed = false;
        element_handler.properties.attr._attr_properties['{}ae_condition'].properties.use = 'O';
        element_handler.properties.attr._attr_properties['{}ae_condition'].properties.form = 'U';

        element_handler.properties.attr._attr_properties['{}ae_condition'].particle_properties = {};
        element_handler.properties.attr._attr_properties['{}ae_condition'].particle_properties.q_name = {};
        element_handler.properties.attr._attr_properties['{}ae_condition'].particle_properties.q_name.ns = '';
        element_handler.properties.attr._attr_properties['{}ae_condition'].particle_properties.q_name.local_name = 'ae_condition';
        element_handler.properties.attr._attr_properties['{}ae_condition'].particle_properties.generated_name = 'ae_condition';

        element_handler.properties.attr._attr_properties['{}ae_condition'].type_handler = require('org.w3.2001.XMLSchema.token_handler'):instantiate();

        element_handler.properties.attr._attr_properties['{}ae_condition'].super_element_content_type = require('org.w3.2001.XMLSchema.token_handler'):instantiate();
        element_handler.properties.attr._attr_properties['{}ae_condition'].type_of_simple = 'A';
        element_handler.properties.attr._attr_properties['{}ae_condition'].local_facets = {}
        element_handler.properties.attr._attr_properties['{}ae_condition'].facets = basic_stuff.inherit_facets(element_handler.properties.attr._attr_properties['{}ae_condition']);
    end
    do
        element_handler.properties.attr._attr_properties['{}argument_type'] = {};

        element_handler.properties.attr._attr_properties['{}argument_type'].base = {};
        element_handler.properties.attr._attr_properties['{}argument_type'].base.ns = 'http://www.w3.org/2001/XMLSchema';
        element_handler.properties.attr._attr_properties['{}argument_type'].base.name = 'token';
        element_handler.properties.attr._attr_properties['{}argument_type'].bi_type = {};
        element_handler.properties.attr._attr_properties['{}argument_type'].bi_type.ns = 'http://www.w3.org/2001/XMLSchema';
        element_handler.properties.attr._attr_properties['{}argument_type'].bi_type.name = 'token';
        element_handler.properties.attr._attr_properties['{}argument_type'].bi_type.id = '0';
        element_handler.properties.attr._attr_properties['{}argument_type'].properties = {};
        element_handler.properties.attr._attr_properties['{}argument_type'].properties.schema_type = '{http://www.w3.org/2001/XMLSchema}token';
        element_handler.properties.attr._attr_properties['{}argument_type'].properties.default = '';
        element_handler.properties.attr._attr_properties['{}argument_type'].properties.fixed = false;
        element_handler.properties.attr._attr_properties['{}argument_type'].properties.use = 'R';
        element_handler.properties.attr._attr_properties['{}argument_type'].properties.form = 'U';

        element_handler.properties.attr._attr_properties['{}argument_type'].particle_properties = {};
        element_handler.properties.attr._attr_properties['{}argument_type'].particle_properties.q_name = {};
        element_handler.properties.attr._attr_properties['{}argument_type'].particle_properties.q_name.ns = '';
        element_handler.properties.attr._attr_properties['{}argument_type'].particle_properties.q_name.local_name = 'argument_type';
        element_handler.properties.attr._attr_properties['{}argument_type'].particle_properties.generated_name = 'argument_type';

        element_handler.properties.attr._attr_properties['{}argument_type'].type_handler = require('org.w3.2001.XMLSchema.token_handler'):instantiate();

        element_handler.properties.attr._attr_properties['{}argument_type'].super_element_content_type = require('org.w3.2001.XMLSchema.token_handler'):instantiate();
        element_handler.properties.attr._attr_properties['{}argument_type'].type_of_simple = 'A';
        element_handler.properties.attr._attr_properties['{}argument_type'].local_facets = {}
        element_handler.properties.attr._attr_properties['{}argument_type'].local_facets.enumeration = {};
        element_handler.properties.attr._attr_properties['{}argument_type'].local_facets.enumeration[1] = 'scalar';
        element_handler.properties.attr._attr_properties['{}argument_type'].local_facets.enumeration[2] = 'array';
        element_handler.properties.attr._attr_properties['{}argument_type'].facets = basic_stuff.inherit_facets(element_handler.properties.attr._attr_properties['{}argument_type']);
    end
    do
        element_handler.properties.attr._attr_properties['{}addnl_argument'] = {};

        element_handler.properties.attr._attr_properties['{}addnl_argument'].base = {};
        element_handler.properties.attr._attr_properties['{}addnl_argument'].base.ns = 'http://www.w3.org/2001/XMLSchema';
        element_handler.properties.attr._attr_properties['{}addnl_argument'].base.name = 'token';
        element_handler.properties.attr._attr_properties['{}addnl_argument'].bi_type = {};
        element_handler.properties.attr._attr_properties['{}addnl_argument'].bi_type.ns = 'http://www.w3.org/2001/XMLSchema';
        element_handler.properties.attr._attr_properties['{}addnl_argument'].bi_type.name = 'token';
        element_handler.properties.attr._attr_properties['{}addnl_argument'].bi_type.id = '16';
        element_handler.properties.attr._attr_properties['{}addnl_argument'].properties = {};
        element_handler.properties.attr._attr_properties['{}addnl_argument'].properties.schema_type = '{http://www.w3.org/2001/XMLSchema}token';
        element_handler.properties.attr._attr_properties['{}addnl_argument'].properties.default = '';
        element_handler.properties.attr._attr_properties['{}addnl_argument'].properties.fixed = false;
        element_handler.properties.attr._attr_properties['{}addnl_argument'].properties.use = 'O';
        element_handler.properties.attr._attr_properties['{}addnl_argument'].properties.form = 'U';

        element_handler.properties.attr._attr_properties['{}addnl_argument'].particle_properties = {};
        element_handler.properties.attr._attr_properties['{}addnl_argument'].particle_properties.q_name = {};
        element_handler.properties.attr._attr_properties['{}addnl_argument'].particle_properties.q_name.ns = '';
        element_handler.properties.attr._attr_properties['{}addnl_argument'].particle_properties.q_name.local_name = 'addnl_argument';
        element_handler.properties.attr._attr_properties['{}addnl_argument'].particle_properties.generated_name = 'addnl_argument';

        element_handler.properties.attr._attr_properties['{}addnl_argument'].type_handler = require('org.w3.2001.XMLSchema.token_handler'):instantiate();

        element_handler.properties.attr._attr_properties['{}addnl_argument'].super_element_content_type = require('org.w3.2001.XMLSchema.token_handler'):instantiate();
        element_handler.properties.attr._attr_properties['{}addnl_argument'].type_of_simple = 'A';
        element_handler.properties.attr._attr_properties['{}addnl_argument'].local_facets = {}
        element_handler.properties.attr._attr_properties['{}addnl_argument'].facets = basic_stuff.inherit_facets(element_handler.properties.attr._attr_properties['{}addnl_argument']);
    end
    do
        element_handler.properties.attr._attr_properties['{}condition'] = {};

        element_handler.properties.attr._attr_properties['{}condition'].base = {};
        element_handler.properties.attr._attr_properties['{}condition'].base.ns = 'http://www.w3.org/2001/XMLSchema';
        element_handler.properties.attr._attr_properties['{}condition'].base.name = 'token';
        element_handler.properties.attr._attr_properties['{}condition'].bi_type = {};
        element_handler.properties.attr._attr_properties['{}condition'].bi_type.ns = 'http://www.w3.org/2001/XMLSchema';
        element_handler.properties.attr._attr_properties['{}condition'].bi_type.name = 'token';
        element_handler.properties.attr._attr_properties['{}condition'].bi_type.id = '16';
        element_handler.properties.attr._attr_properties['{}condition'].properties = {};
        element_handler.properties.attr._attr_properties['{}condition'].properties.schema_type = '{http://www.w3.org/2001/XMLSchema}token';
        element_handler.properties.attr._attr_properties['{}condition'].properties.default = '';
        element_handler.properties.attr._attr_properties['{}condition'].properties.fixed = false;
        element_handler.properties.attr._attr_properties['{}condition'].properties.use = 'O';
        element_handler.properties.attr._attr_properties['{}condition'].properties.form = 'U';

        element_handler.properties.attr._attr_properties['{}condition'].particle_properties = {};
        element_handler.properties.attr._attr_properties['{}condition'].particle_properties.q_name = {};
        element_handler.properties.attr._attr_properties['{}condition'].particle_properties.q_name.ns = '';
        element_handler.properties.attr._attr_properties['{}condition'].particle_properties.q_name.local_name = 'condition';
        element_handler.properties.attr._attr_properties['{}condition'].particle_properties.generated_name = 'condition';

        element_handler.properties.attr._attr_properties['{}condition'].type_handler = require('org.w3.2001.XMLSchema.token_handler'):instantiate();

        element_handler.properties.attr._attr_properties['{}condition'].super_element_content_type = require('org.w3.2001.XMLSchema.token_handler'):instantiate();
        element_handler.properties.attr._attr_properties['{}condition'].type_of_simple = 'A';
        element_handler.properties.attr._attr_properties['{}condition'].local_facets = {}
        element_handler.properties.attr._attr_properties['{}condition'].facets = basic_stuff.inherit_facets(element_handler.properties.attr._attr_properties['{}condition']);
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
        element_handler.properties.attr._attr_properties['{}argument'] = {};

        element_handler.properties.attr._attr_properties['{}argument'].base = {};
        element_handler.properties.attr._attr_properties['{}argument'].base.ns = 'http://www.w3.org/2001/XMLSchema';
        element_handler.properties.attr._attr_properties['{}argument'].base.name = 'token';
        element_handler.properties.attr._attr_properties['{}argument'].bi_type = {};
        element_handler.properties.attr._attr_properties['{}argument'].bi_type.ns = 'http://www.w3.org/2001/XMLSchema';
        element_handler.properties.attr._attr_properties['{}argument'].bi_type.name = 'token';
        element_handler.properties.attr._attr_properties['{}argument'].bi_type.id = '16';
        element_handler.properties.attr._attr_properties['{}argument'].properties = {};
        element_handler.properties.attr._attr_properties['{}argument'].properties.schema_type = '{http://www.w3.org/2001/XMLSchema}token';
        element_handler.properties.attr._attr_properties['{}argument'].properties.default = '';
        element_handler.properties.attr._attr_properties['{}argument'].properties.fixed = false;
        element_handler.properties.attr._attr_properties['{}argument'].properties.use = 'R';
        element_handler.properties.attr._attr_properties['{}argument'].properties.form = 'U';

        element_handler.properties.attr._attr_properties['{}argument'].particle_properties = {};
        element_handler.properties.attr._attr_properties['{}argument'].particle_properties.q_name = {};
        element_handler.properties.attr._attr_properties['{}argument'].particle_properties.q_name.ns = '';
        element_handler.properties.attr._attr_properties['{}argument'].particle_properties.q_name.local_name = 'argument';
        element_handler.properties.attr._attr_properties['{}argument'].particle_properties.generated_name = 'argument';

        element_handler.properties.attr._attr_properties['{}argument'].type_handler = require('org.w3.2001.XMLSchema.token_handler'):instantiate();

        element_handler.properties.attr._attr_properties['{}argument'].super_element_content_type = require('org.w3.2001.XMLSchema.token_handler'):instantiate();
        element_handler.properties.attr._attr_properties['{}argument'].type_of_simple = 'A';
        element_handler.properties.attr._attr_properties['{}argument'].local_facets = {}
        element_handler.properties.attr._attr_properties['{}argument'].facets = basic_stuff.inherit_facets(element_handler.properties.attr._attr_properties['{}argument']);
    end
    element_handler.properties.attr._generated_attr = {};
    element_handler.properties.attr._generated_attr['argument'] = '{}argument';
    element_handler.properties.attr._generated_attr['addnl_argument'] = '{}addnl_argument';
    element_handler.properties.attr._generated_attr['argument_type'] = '{}argument_type';
    element_handler.properties.attr._generated_attr['ae_condition'] = '{}ae_condition';
    element_handler.properties.attr._generated_attr['method'] = '{}method';
    element_handler.properties.attr._generated_attr['condition'] = '{}condition';
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
