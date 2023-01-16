local basic_stuff = require("lua_schema.basic_stuff");
local eh_cache = require("lua_schema.eh_cache");

local element_handler = {};



local mt = { __index = element_handler; };
local _factory = {};

_factory.new_instance_as_root = function(self)
    return basic_stuff.instantiate_element_as_doc_root(mt);
end

_factory.new_instance_as_ref = function(self, element_ref_properties)
    return basic_stuff.instantiate_element_as_ref(mt, { ns = '',
                                                        local_name = 'partner',
                                                        generated_name = element_ref_properties.generated_name,
                                                        min_occurs = element_ref_properties.min_occurs,
                                                        max_occurs = element_ref_properties.max_occurs,
                                                        root_element = element_ref_properties.root_element});
end

eh_cache.add('{}partner', _factory);

do
    element_handler.properties = {};
    element_handler.properties.element_type = 'C';
    element_handler.properties.content_type = 'C';
    element_handler.properties.schema_type = '{}partner';
    element_handler.properties.attr = {};
    element_handler.properties.attr._attr_properties = {};
    element_handler.properties.attr._generated_attr = {};
end

do
    element_handler.particle_properties = {};
    element_handler.particle_properties.q_name = {};
    element_handler.particle_properties.q_name.ns = '';
    element_handler.particle_properties.q_name.local_name = 'partner';
    element_handler.particle_properties.generated_name = 'partner';
end

-- element_handler.properties.content_model
do
    element_handler.properties.content_model = {
        group_type = 'S',
        min_occurs = 1,
        max_occurs = 1,
        top_level_group = true,
        generated_subelement_name = '_sequence_group',
        'name',
        'address',
    };
end

-- element_handler.properties.content_fsa_properties
do
    element_handler.properties.content_fsa_properties = {
        {symbol_type = 'cm_begin', symbol_name = '_sequence_group', generated_symbol_name = '_sequence_group', min_occurs = 1, max_occurs = 1, cm = element_handler.properties.content_model}
        ,{symbol_type = 'element', symbol_name = '{}name', generated_symbol_name = '{}name', min_occurs = 1, max_occurs = 1, wild_card_type = 0, generated_name = 'name', cm = element_handler.properties.content_model}
        ,{symbol_type = 'element', symbol_name = '{}address', generated_symbol_name = '{}address', min_occurs = 1, max_occurs = 1, wild_card_type = 0, generated_name = 'address', cm = element_handler.properties.content_model}
        ,{symbol_type = 'cm_end', symbol_name = '_sequence_group', generated_symbol_name = '_sequence_group', cm_begin_index = 1, cm = element_handler.properties.content_model}
    };
end

do
    element_handler.properties.declared_subelements = {
        '{}name'
        ,'{}address'
    };
end

do
    element_handler.properties.subelement_properties = {};
    element_handler.properties.subelement_properties['{}address'] = {};
    do
element_handler.properties.subelement_properties['{}address'].super_element_content_type = require('org.w3.2001.XMLSchema.string_handler'):instantiate();

element_handler.properties.subelement_properties['{}address'].type_of_simple = 'A';

        do
            element_handler.properties.subelement_properties['{}address'].properties = {};
            element_handler.properties.subelement_properties['{}address'].properties.element_type = 'S';
            element_handler.properties.subelement_properties['{}address'].properties.content_type = 'S';
            element_handler.properties.subelement_properties['{}address'].properties.schema_type = '{http://www.w3.org/2001/XMLSchema}string';
            element_handler.properties.subelement_properties['{}address'].properties.bi_type = {};
            element_handler.properties.subelement_properties['{}address'].properties.bi_type.ns = 'http://www.w3.org/2001/XMLSchema';
            element_handler.properties.subelement_properties['{}address'].properties.bi_type.name = 'string';
            element_handler.properties.subelement_properties['{}address'].properties.bi_type.id = '1';
            element_handler.properties.subelement_properties['{}address'].properties.attr = {};
            element_handler.properties.subelement_properties['{}address'].properties.attr._attr_properties = {};
            element_handler.properties.subelement_properties['{}address'].properties.attr._generated_attr = {};
        end

        do
            element_handler.properties.subelement_properties['{}address'].particle_properties = {};
            element_handler.properties.subelement_properties['{}address'].particle_properties.q_name = {};
            element_handler.properties.subelement_properties['{}address'].particle_properties.q_name.ns = '';
            element_handler.properties.subelement_properties['{}address'].particle_properties.q_name.local_name = 'address';
            element_handler.properties.subelement_properties['{}address'].particle_properties.generated_name = 'address';
        end

        -- Simple type properties
        do
            element_handler.properties.subelement_properties['{}address'].base = {};
            element_handler.properties.subelement_properties['{}address'].base.ns = 'http://www.w3.org/2001/XMLSchema';
            element_handler.properties.subelement_properties['{}address'].base.name = 'string';
            element_handler.properties.subelement_properties['{}address'].local_facets = {};
            element_handler.properties.subelement_properties['{}address'].facets = basic_stuff.inherit_facets(element_handler.properties.subelement_properties['{}address']);
        end

        do
            element_handler.properties.subelement_properties['{}address'].type_handler = require('org.w3.2001.XMLSchema.string_handler'):instantiate();
            element_handler.properties.subelement_properties['{}address'].get_attributes = basic_stuff.get_attributes;
            element_handler.properties.subelement_properties['{}address'].is_valid = basic_stuff.simple_is_valid;
            element_handler.properties.subelement_properties['{}address'].to_xmlua = basic_stuff.simple_to_xmlua;
            element_handler.properties.subelement_properties['{}address'].get_unique_namespaces_declared = basic_stuff.simple_get_unique_namespaces_declared;
            element_handler.properties.subelement_properties['{}address'].parse_xml = basic_stuff.parse_xml;
        end

        element_handler.properties.subelement_properties['{}address'].particle_properties.root_element = false;
        element_handler.properties.subelement_properties['{}address'].particle_properties.min_occurs = 1;
        element_handler.properties.subelement_properties['{}address'].particle_properties.max_occurs = 1;
    end

    element_handler.properties.subelement_properties['{}name'] = {};
    do
element_handler.properties.subelement_properties['{}name'].super_element_content_type = require('org.w3.2001.XMLSchema.string_handler'):instantiate();

element_handler.properties.subelement_properties['{}name'].type_of_simple = 'A';

        do
            element_handler.properties.subelement_properties['{}name'].properties = {};
            element_handler.properties.subelement_properties['{}name'].properties.element_type = 'S';
            element_handler.properties.subelement_properties['{}name'].properties.content_type = 'S';
            element_handler.properties.subelement_properties['{}name'].properties.schema_type = '{http://www.w3.org/2001/XMLSchema}string';
            element_handler.properties.subelement_properties['{}name'].properties.bi_type = {};
            element_handler.properties.subelement_properties['{}name'].properties.bi_type.ns = 'http://www.w3.org/2001/XMLSchema';
            element_handler.properties.subelement_properties['{}name'].properties.bi_type.name = 'string';
            element_handler.properties.subelement_properties['{}name'].properties.bi_type.id = '1';
            element_handler.properties.subelement_properties['{}name'].properties.attr = {};
            element_handler.properties.subelement_properties['{}name'].properties.attr._attr_properties = {};
            element_handler.properties.subelement_properties['{}name'].properties.attr._generated_attr = {};
        end

        do
            element_handler.properties.subelement_properties['{}name'].particle_properties = {};
            element_handler.properties.subelement_properties['{}name'].particle_properties.q_name = {};
            element_handler.properties.subelement_properties['{}name'].particle_properties.q_name.ns = '';
            element_handler.properties.subelement_properties['{}name'].particle_properties.q_name.local_name = 'name';
            element_handler.properties.subelement_properties['{}name'].particle_properties.generated_name = 'name';
        end

        -- Simple type properties
        do
            element_handler.properties.subelement_properties['{}name'].base = {};
            element_handler.properties.subelement_properties['{}name'].base.ns = 'http://www.w3.org/2001/XMLSchema';
            element_handler.properties.subelement_properties['{}name'].base.name = 'string';
            element_handler.properties.subelement_properties['{}name'].local_facets = {};
            element_handler.properties.subelement_properties['{}name'].facets = basic_stuff.inherit_facets(element_handler.properties.subelement_properties['{}name']);
        end

        do
            element_handler.properties.subelement_properties['{}name'].type_handler = require('org.w3.2001.XMLSchema.string_handler'):instantiate();
            element_handler.properties.subelement_properties['{}name'].get_attributes = basic_stuff.get_attributes;
            element_handler.properties.subelement_properties['{}name'].is_valid = basic_stuff.simple_is_valid;
            element_handler.properties.subelement_properties['{}name'].to_xmlua = basic_stuff.simple_to_xmlua;
            element_handler.properties.subelement_properties['{}name'].get_unique_namespaces_declared = basic_stuff.simple_get_unique_namespaces_declared;
            element_handler.properties.subelement_properties['{}name'].parse_xml = basic_stuff.parse_xml;
        end

        element_handler.properties.subelement_properties['{}name'].particle_properties.root_element = false;
        element_handler.properties.subelement_properties['{}name'].particle_properties.min_occurs = 1;
        element_handler.properties.subelement_properties['{}name'].particle_properties.max_occurs = 1;
    end

end

do
    element_handler.properties.generated_subelements = {
        ['name'] = element_handler.properties.subelement_properties['{}name']
        ,['address'] = element_handler.properties.subelement_properties['{}address']
    };
end

do
    element_handler.type_handler = element_handler;
    element_handler.get_attributes = basic_stuff.get_attributes;
    element_handler.is_valid = basic_stuff.complex_type_is_valid;
    element_handler.to_xmlua = basic_stuff.struct_to_xmlua;
    element_handler.get_unique_namespaces_declared = basic_stuff.complex_get_unique_namespaces_declared;
    element_handler.parse_xml = basic_stuff.parse_xml;
end



return _factory;
