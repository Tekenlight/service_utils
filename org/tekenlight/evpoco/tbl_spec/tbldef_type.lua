local basic_stuff = require("lua_schema.basic_stuff");
local eh_cache = require("lua_schema.eh_cache");

local element_handler = {};
element_handler.__name__ = 'tbldef_type';

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

eh_cache.add('{http://evpoco.tekenlight.org/tbl_spec}tbldef_type', _factory);


do
    element_handler.properties = {};
    element_handler.properties.element_type = 'C';
    element_handler.properties.content_type = 'C';
    element_handler.properties.schema_type = '{http://evpoco.tekenlight.org/tbl_spec}tbldef_type';
    element_handler.properties.q_name = {};
    element_handler.properties.q_name.ns = 'http://evpoco.tekenlight.org/tbl_spec'
    element_handler.properties.q_name.local_name = 'tbldef_type'

    -- No particle properties for a typedef

    element_handler.properties.attr = {};
    element_handler.properties.attr._attr_properties = {};
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
        element_handler.properties.attr._attr_properties['{}sync'] = {};

        element_handler.properties.attr._attr_properties['{}sync'].base = {};
        element_handler.properties.attr._attr_properties['{}sync'].base.ns = 'http://www.w3.org/2001/XMLSchema';
        element_handler.properties.attr._attr_properties['{}sync'].base.name = 'boolean';
        element_handler.properties.attr._attr_properties['{}sync'].bi_type = {};
        element_handler.properties.attr._attr_properties['{}sync'].bi_type.ns = 'http://www.w3.org/2001/XMLSchema';
        element_handler.properties.attr._attr_properties['{}sync'].bi_type.name = 'boolean';
        element_handler.properties.attr._attr_properties['{}sync'].bi_type.id = '15';
        element_handler.properties.attr._attr_properties['{}sync'].properties = {};
        element_handler.properties.attr._attr_properties['{}sync'].properties.schema_type = '{http://www.w3.org/2001/XMLSchema}boolean';
        element_handler.properties.attr._attr_properties['{}sync'].properties.default = '';
        element_handler.properties.attr._attr_properties['{}sync'].properties.fixed = false;
        element_handler.properties.attr._attr_properties['{}sync'].properties.use = 'R';
        element_handler.properties.attr._attr_properties['{}sync'].properties.form = 'U';

        element_handler.properties.attr._attr_properties['{}sync'].particle_properties = {};
        element_handler.properties.attr._attr_properties['{}sync'].particle_properties.q_name = {};
        element_handler.properties.attr._attr_properties['{}sync'].particle_properties.q_name.ns = '';
        element_handler.properties.attr._attr_properties['{}sync'].particle_properties.q_name.local_name = 'sync';
        element_handler.properties.attr._attr_properties['{}sync'].particle_properties.generated_name = 'sync';

        element_handler.properties.attr._attr_properties['{}sync'].type_handler = require('org.w3.2001.XMLSchema.boolean_handler'):instantiate();

        element_handler.properties.attr._attr_properties['{}sync'].super_element_content_type = require('org.w3.2001.XMLSchema.boolean_handler'):instantiate();
        element_handler.properties.attr._attr_properties['{}sync'].type_of_simple = 'A';
        element_handler.properties.attr._attr_properties['{}sync'].local_facets = {}
        element_handler.properties.attr._attr_properties['{}sync'].facets = basic_stuff.inherit_facets(element_handler.properties.attr._attr_properties['{}sync']);
    end
    do
        element_handler.properties.attr._attr_properties['{}database_schema'] = {};

        element_handler.properties.attr._attr_properties['{}database_schema'].base = {};
        element_handler.properties.attr._attr_properties['{}database_schema'].base.ns = 'http://www.w3.org/2001/XMLSchema';
        element_handler.properties.attr._attr_properties['{}database_schema'].base.name = 'token';
        element_handler.properties.attr._attr_properties['{}database_schema'].bi_type = {};
        element_handler.properties.attr._attr_properties['{}database_schema'].bi_type.ns = 'http://www.w3.org/2001/XMLSchema';
        element_handler.properties.attr._attr_properties['{}database_schema'].bi_type.name = 'token';
        element_handler.properties.attr._attr_properties['{}database_schema'].bi_type.id = '16';
        element_handler.properties.attr._attr_properties['{}database_schema'].properties = {};
        element_handler.properties.attr._attr_properties['{}database_schema'].properties.schema_type = '{http://www.w3.org/2001/XMLSchema}token';
        element_handler.properties.attr._attr_properties['{}database_schema'].properties.default = '';
        element_handler.properties.attr._attr_properties['{}database_schema'].properties.fixed = false;
        element_handler.properties.attr._attr_properties['{}database_schema'].properties.use = 'R';
        element_handler.properties.attr._attr_properties['{}database_schema'].properties.form = 'U';

        element_handler.properties.attr._attr_properties['{}database_schema'].particle_properties = {};
        element_handler.properties.attr._attr_properties['{}database_schema'].particle_properties.q_name = {};
        element_handler.properties.attr._attr_properties['{}database_schema'].particle_properties.q_name.ns = '';
        element_handler.properties.attr._attr_properties['{}database_schema'].particle_properties.q_name.local_name = 'database_schema';
        element_handler.properties.attr._attr_properties['{}database_schema'].particle_properties.generated_name = 'database_schema';

        element_handler.properties.attr._attr_properties['{}database_schema'].type_handler = require('org.w3.2001.XMLSchema.token_handler'):instantiate();

        element_handler.properties.attr._attr_properties['{}database_schema'].super_element_content_type = require('org.w3.2001.XMLSchema.token_handler'):instantiate();
        element_handler.properties.attr._attr_properties['{}database_schema'].type_of_simple = 'A';
        element_handler.properties.attr._attr_properties['{}database_schema'].local_facets = {}
        element_handler.properties.attr._attr_properties['{}database_schema'].facets = basic_stuff.inherit_facets(element_handler.properties.attr._attr_properties['{}database_schema']);
    end
    do
        element_handler.properties.attr._attr_properties['{}tablespace'] = {};

        element_handler.properties.attr._attr_properties['{}tablespace'].base = {};
        element_handler.properties.attr._attr_properties['{}tablespace'].base.ns = 'http://www.w3.org/2001/XMLSchema';
        element_handler.properties.attr._attr_properties['{}tablespace'].base.name = 'token';
        element_handler.properties.attr._attr_properties['{}tablespace'].bi_type = {};
        element_handler.properties.attr._attr_properties['{}tablespace'].bi_type.ns = 'http://www.w3.org/2001/XMLSchema';
        element_handler.properties.attr._attr_properties['{}tablespace'].bi_type.name = 'token';
        element_handler.properties.attr._attr_properties['{}tablespace'].bi_type.id = '16';
        element_handler.properties.attr._attr_properties['{}tablespace'].properties = {};
        element_handler.properties.attr._attr_properties['{}tablespace'].properties.schema_type = '{http://www.w3.org/2001/XMLSchema}token';
        element_handler.properties.attr._attr_properties['{}tablespace'].properties.default = '';
        element_handler.properties.attr._attr_properties['{}tablespace'].properties.fixed = false;
        element_handler.properties.attr._attr_properties['{}tablespace'].properties.use = 'R';
        element_handler.properties.attr._attr_properties['{}tablespace'].properties.form = 'U';

        element_handler.properties.attr._attr_properties['{}tablespace'].particle_properties = {};
        element_handler.properties.attr._attr_properties['{}tablespace'].particle_properties.q_name = {};
        element_handler.properties.attr._attr_properties['{}tablespace'].particle_properties.q_name.ns = '';
        element_handler.properties.attr._attr_properties['{}tablespace'].particle_properties.q_name.local_name = 'tablespace';
        element_handler.properties.attr._attr_properties['{}tablespace'].particle_properties.generated_name = 'tablespace';

        element_handler.properties.attr._attr_properties['{}tablespace'].type_handler = require('org.w3.2001.XMLSchema.token_handler'):instantiate();

        element_handler.properties.attr._attr_properties['{}tablespace'].super_element_content_type = require('org.w3.2001.XMLSchema.token_handler'):instantiate();
        element_handler.properties.attr._attr_properties['{}tablespace'].type_of_simple = 'A';
        element_handler.properties.attr._attr_properties['{}tablespace'].local_facets = {}
        element_handler.properties.attr._attr_properties['{}tablespace'].facets = basic_stuff.inherit_facets(element_handler.properties.attr._attr_properties['{}tablespace']);
    end
    element_handler.properties.attr._generated_attr = {};
    element_handler.properties.attr._generated_attr['name'] = '{}name';
    element_handler.properties.attr._generated_attr['tablespace'] = '{}tablespace';
    element_handler.properties.attr._generated_attr['package'] = '{}package';
    element_handler.properties.attr._generated_attr['database_schema'] = '{}database_schema';
    element_handler.properties.attr._generated_attr['sync'] = '{}sync';
end

-- element_handler.properties.content_model
do
    element_handler.properties.content_model = {
        generated_subelement_name = '_sequence_group',
        top_level_group = true,
        min_occurs = 1,
        max_occurs = 1,
        group_type = 'S',
        'columns',
        'indexes',
    };
end

-- element_handler.properties.content_fsa_properties
do
    element_handler.properties.content_fsa_properties = {
        {symbol_type = 'cm_begin', symbol_name = '_sequence_group', generated_symbol_name = '_sequence_group', min_occurs = 1, max_occurs = 1, cm = element_handler.properties.content_model}
        ,{symbol_type = 'element', symbol_name = '{}columns', generated_symbol_name = '{}columns', min_occurs = 1, max_occurs = 1, wild_card_type = 0, generated_name = 'columns', cm = element_handler.properties.content_model}
        ,{symbol_type = 'element', symbol_name = '{}indexes', generated_symbol_name = '{}indexes', min_occurs = 0, max_occurs = 1, wild_card_type = 0, generated_name = 'indexes', cm = element_handler.properties.content_model}
        ,{symbol_type = 'cm_end', symbol_name = '_sequence_group', generated_symbol_name = '_sequence_group', cm_begin_index = 1, cm = element_handler.properties.content_model}
    };
end

do
    element_handler.properties.declared_subelements = {
        '{}columns'
        ,'{}indexes'
    };
end

do
    element_handler.properties.subelement_properties = {};
    do
        element_handler.properties.subelement_properties['{}indexes'] = 
            (basic_stuff.get_element_handler('http://evpoco.tekenlight.org/tbl_spec', 'indexes_type'):
            new_instance_as_local_element({ns = '', local_name = 'indexes', generated_name = 'indexes',
                    root_element = false, min_occurs = 0, max_occurs = 1}));
    end

    do
        element_handler.properties.subelement_properties['{}columns'] = 
            (basic_stuff.get_element_handler('http://evpoco.tekenlight.org/tbl_spec', 'columns_type'):
            new_instance_as_local_element({ns = '', local_name = 'columns', generated_name = 'columns',
                    root_element = false, min_occurs = 1, max_occurs = 1}));
    end

end

do
    element_handler.properties.generated_subelements = {
        ['columns'] = element_handler.properties.subelement_properties['{}columns']
        ,['indexes'] = element_handler.properties.subelement_properties['{}indexes']
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
