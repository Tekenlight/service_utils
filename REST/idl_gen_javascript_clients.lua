-- JAVASCRIPT OUTPUT GENERATOR
-- idl_gen.lua owns XML parsing. This module receives that parsed interface and
-- renders only the JS factory and its declaration; no package/install work occurs.
-- C supplies the coordinator's shared write/validation helpers without a cyclic require.
local M = {}
M.header = '// AUTO-GENERATED from BIOP IDL. Do not edit manually.\n'
function M.generate(iface, target, module, C)
    assert(target:match('%.js$'), 'JavaScript output must end in .js')
    assert(C.identifier(module), 'Invalid service module')
    local name = iface._attr.name
    assert(C.identifier(name), 'Invalid JavaScript service name: ' .. tostring(name))
    local types, entries, declarations, seen = {}, {}, {}, {}
    local verbs = { GET=true, POST=true, PUT=true, PATCH=true, DELETE=true }
    for _, method in ipairs(iface.method) do
        local attr = method._attr
        assert(C.identifier(attr.name) and not seen[attr.name], 'Invalid/duplicate method: ' .. tostring(attr.name))
        assert(verbs[attr.http_method], 'Unsupported HTTP verb: ' .. tostring(attr.http_method))
        seen[attr.name] = true
        types[#types + 1] = ' *   ' .. attr.name .. ': ServiceMethod'
        entries[#entries + 1] = '            ' .. attr.name .. ': ' .. C.json.encode(attr.http_method:lower()) .. ','
        declarations[#declarations + 1] = '    ' .. attr.name .. ': ServiceMethod;'
    end
    local code = M.header .. [[import { createServiceRoutine } from "WebUI_Framework";

/**
 * @typedef {Object} ServiceMethodOptions
 * @property {Object} [params] - Query parameters
 * @property {Object} [body] - Request body
 */
/** @typedef {(options: ServiceMethodOptions) => Promise<any>} ServiceMethod */

/**
 * @param {Object} session
 * @returns {{
]] .. table.concat(types, ',\n') .. '\n * }}\n */\nexport const ' .. name .. [[ = (session) =>
    createServiceRoutine({
        session,
        module: ]] .. C.json.encode(module) .. ',\n        servicePath: ' .. C.json.encode(name) .. [[,
        defaultMethods: false,
        methods: {
]] .. table.concat(entries, '\n') .. [[

        },
    });
]]
    C.write(target, code)
    C.write(target:gsub('%.js$', '.d.ts'), M.header .. [[export interface ServiceMethodOptions {
    params?: object;
    body?: object;
}
export type ServiceMethod = (options: ServiceMethodOptions) => Promise<any>;
export declare const ]] .. name .. ': (session: object) => {\n'
        .. table.concat(declarations, '\n') .. '\n};\n')
    return name
end
return M
