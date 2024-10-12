local basic_stuff = require("lua_schema.basic_stuff");
local eh_cache = require("lua_schema.eh_cache");

local element_handler = {};



local mt = { __index = element_handler; };
local _factory = {};

_factory.new_instance_as_root = function(self)
    return basic_stuff.instantiate_element_as_doc_root(mt);
end

_factory.new_instance_as_ref = function(self, element_ref_properties)
    return basic_stuff.instantiate_element_as_ref(mt, { ns = 'http://evpoco.tekenlight.org/message_rules',
                                                        local_name = 'app_info',
                                                        generated_name = element_ref_properties.generated_name,
                                                        min_occurs = element_ref_properties.min_occurs,
                                                        max_occurs = element_ref_properties.max_occurs,
                                                        root_element = element_ref_properties.root_element});
end

eh_cache.add('{http://evpoco.tekenlight.org/message_rules}app_info', _factory);

do
    element_handler.properties = {};
    element_handler.properties.element_type = 'C';
    element_handler.properties.content_type = 'C';
    element_handler.properties.schema_type = '{}app_info';
    element_handler.properties.attr = {};
    element_handler.properties.attr._attr_properties = {};
    element_handler.properties.attr._generated_attr = {};
end

do
    element_handler.particle_properties = {};
    element_handler.particle_properties.q_name = {};
    element_handler.particle_properties.q_name.ns = 'http://evpoco.tekenlight.org/message_rules';
    element_handler.particle_properties.q_name.local_name = 'app_info';
    element_handler.particle_properties.generated_name = 'app_info';
end

-- element_handler.properties.content_model
do
    element_handler.properties.content_model = {
        generated_subelement_name = '_sequence_group',
        max_occurs = 1,
        top_level_group = true,
        min_occurs = 1,
        group_type = 'S',
        'rule_set',
        'mappings',
    };
end

-- element_handler.properties.content_fsa_properties
do
    element_handler.properties.content_fsa_properties = {
        {symbol_type = 'cm_begin', symbol_name = '_sequence_group', generated_symbol_name = '_sequence_group', min_occurs = 1, max_occurs = 1, cm = element_handler.properties.content_model}
        ,{symbol_type = 'element', symbol_name = '{}rule_set', generated_symbol_name = '{}rule_set', min_occurs = 0, max_occurs = -1, wild_card_type = 0, generated_name = 'rule_set', cm = element_handler.properties.content_model}
        ,{symbol_type = 'element', symbol_name = '{}mappings', generated_symbol_name = '{}mappings', min_occurs = 0, max_occurs = 1, wild_card_type = 0, generated_name = 'mappings', cm = element_handler.properties.content_model}
        ,{symbol_type = 'cm_end', symbol_name = '_sequence_group', generated_symbol_name = '_sequence_group', cm_begin_index = 1, cm = element_handler.properties.content_model}
    };
end

do
    element_handler.properties.declared_subelements = {
        '{}rule_set'
        ,'{}mappings'
    };
end

do
    element_handler.properties.subelement_properties = {};
    do
        element_handler.properties.subelement_properties['{}rule_set'] = 
            (basic_stuff.get_element_handler('http://evpoco.tekenlight.org/message_rules', 'rule_set_type'):
            new_instance_as_local_element({ns = '', local_name = 'rule_set', generated_name = 'rule_set',
                    root_element = false, min_occurs = 0, max_occurs = -1}));
    end

    do
        element_handler.properties.subelement_properties['{}mappings'] = 
            (basic_stuff.get_element_handler('http://evpoco.tekenlight.org/message_rules', 'mappings_type'):
            new_instance_as_local_element({ns = '', local_name = 'mappings', generated_name = 'mappings',
                    root_element = false, min_occurs = 0, max_occurs = 1}));
    end

end

do
    element_handler.properties.generated_subelements = {
        ['rule_set'] = element_handler.properties.subelement_properties['{}rule_set']
        ,['mappings'] = element_handler.properties.subelement_properties['{}mappings']
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
