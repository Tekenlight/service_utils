-- BIOP CLIENT COORDINATOR
-- Read in this order:
--   1. Filesystem/JSON helpers (internal implementation, not separate modules).
--   2. Build graph and per-IDL receipts: genmake -> gidl -> parsed interface.
--   3. Package assembly and publication: no XML parsing or generation here.
--   4. Frontend sync/ensure/check/use: independent of a schema checkout.
-- Only main() executes commands; requiring this module from genmake/idl_gen is safe.
-- Shared helpers for the opt-in API client build and distribution tools.
local json = require('cjson')
local lfs = require('lfs')
local C = {}
C.json, C.lfs = json, lfs
function C.quote(s) return "'" .. tostring(s):gsub("'", "'\\''") .. "'" end
function C.exists(p) return lfs.attributes(p) ~= nil end
function C.read(p)
    local f = assert(io.open(p, 'rb'), 'Cannot read ' .. p)
    local s = f:read('*a'); f:close(); return s
end
function C.keys(t)
    local keys = {}; for k in pairs(t) do keys[#keys + 1] = k end
    table.sort(keys); return keys
end
function C.encode(v)
    if type(v) ~= 'table' then return json.encode(v) end
    local items = {}
    if #v > 0 then
        for _, x in ipairs(v) do items[#items + 1] = C.encode(x) end
        return '[' .. table.concat(items, ',') .. ']'
    end
    for _, k in ipairs(C.keys(v)) do items[#items + 1] = json.encode(k) .. ':' .. C.encode(v[k]) end
    return '{' .. table.concat(items, ',') .. '}'
end
function C.load(p) return json.decode(C.read(p)) end
function C.run(command)
    local ok, _, status = os.execute(command)
    assert(ok == true or ok == 0, 'Command failed (' .. tostring(status) .. '): ' .. command)
end
function C.capture(command)
    local f = assert(io.popen(command, 'r')); local s = f:read('*a')
    local ok = f:close(); assert(ok, 'Command failed: ' .. command)
    return s
end
function C.mkdir(p, public)
    C.run((public and 'umask 022; ' or '') .. 'mkdir -p ' .. C.quote(p))
end
function C.parent(p) return p:match('^(.*)/[^/]+$') or '.' end
function C.write(p, s, public)
    if C.exists(p) and C.read(p) == s then
        if public then C.run('chmod 0644 ' .. C.quote(p)) end
        return false
    end
    C.mkdir(C.parent(p))
    -- A unique temporary file in the destination filesystem permits atomic rename.
    local tmp = C.capture('mktemp ' .. C.quote(p .. '.tmp.XXXXXX')):gsub('%s+$', '')
    local ok, err = pcall(function()
        local f = assert(io.open(tmp, 'wb')); assert(f:write(s)); assert(f:close())
        if public then C.run('chmod 0644 ' .. C.quote(tmp)) end
        assert(os.rename(tmp, p))
    end)
    if not ok then os.remove(tmp); error(err) end
    return true
end
function C.sha(p)
    return assert(C.capture('openssl dgst -sha256 ' .. C.quote(p)):match('(%x+)%s*$'), 'Cannot hash ' .. p)
end
function C.identifier(s)
    return type(s) == 'string' and s:match('^[A-Za-z_$][A-Za-z0-9_$]*$') ~= nil
end
function C.version(s)
    assert(type(s) == 'string' and s:match('^%d+%.%d+%.%d+$'), 'Expected an explicit x.y.z artifact version')
    return s
end
function C.relative(s)
    assert(type(s) == 'string' and s ~= '' and s:sub(1, 1) ~= '/' and not s:find('\\'), 'Expected a relative path')
    for part in s:gmatch('[^/]+') do assert(part ~= '..' and part ~= '.', 'Unsafe relative path: ' .. s) end
    return s
end
function C.files(dir)
    local out = {}
    if C.exists(dir) then
        for name in lfs.dir(dir) do if name ~= '.' and name ~= '..' then out[#out + 1] = name end end
    end
    table.sort(out); return out
end
function C.tree(dir, prefix, out)
    prefix, out = prefix or '', out or {}
    for _, name in ipairs(C.files(dir)) do
        local path, rel = dir .. '/' .. name, prefix .. name
        local mode = lfs.symlinkattributes(path, 'mode')
        if mode == 'directory' then C.tree(path, rel .. '/', out)
        else assert(mode == 'file', 'Unexpected non-file: ' .. path); out[rel] = C.sha(path) end
    end
    return out
end
function C.remove_tree(path)
    if lfs.symlinkattributes(path, 'mode') == 'directory' then
        for _, name in ipairs(C.files(path)) do C.remove_tree(path .. '/' .. name) end
        assert(lfs.rmdir(path))
    elseif lfs.symlinkattributes(path) then assert(os.remove(path)) end
end
function C.lock(path, fn)
    C.mkdir(C.parent(path))
    assert(lfs.mkdir(path), 'Another client operation is running (lock: ' .. path .. ')')
    local ok, result = pcall(fn)
    lfs.rmdir(path)
    if not ok then error(result, 0) end
    return result
end
function C.store()
    local root = os.getenv('BIOP_CLIENTS_HOME')
    if not root then
        local config = os.getenv('BIOP_CLIENTS_CONFIG') or '/usr/local/etc/biop-clients.json'
        if C.exists(config) then root = C.load(config).storage_root end
    end
    root = root or '/usr/local/share/biop/api-clients'
    assert(root:sub(1, 1) == '/', 'Client storage root must be absolute')
    return root
end

-- 2/3. BUILD GRAPH, PACKAGE ASSEMBLY AND PUBLICATION
local G = require('idl_gen_javascript_clients')
local OUT = 'build/api-clients'
local function config()
    local cfg = assert(loadfile('api-clients.lua'))()
    assert(cfg.package == '@biop/api-clients', 'Unsupported client package')
    C.version(cfg.version)
    assert(type(cfg.modules) == 'table' and #cfg.modules > 0, 'Configure client modules')
    assert(type(cfg.framework_version) == 'string', 'Configure framework_version')
    return cfg
end
local function fingerprint()
    -- Record code identity, not installation paths: source-checkout and installed
    -- copies of the same generators should produce matching receipt fingerprints.
    local files = {}
    for _, name in ipairs({'biop_clients', 'idl_gen_javascript_clients', 'idl_gen'}) do
        local file = assert(package.searchpath(name, package.path))
        files[#files + 1] = name .. ':' .. C.sha(file)
    end
    return table.concat(files, '\n')
end
-- BUILD GRAPH: called by genmake, not a generator. Every entry becomes one
-- grouped Make rule: Lua mapping + JS + declarations + receipt are produced by
-- one gidl invocation, even with make -j or when just one output was deleted.
function C.client_targets()
    local cfg, targets = config(), {}
    local seen = {}
    for _, mod in ipairs(cfg.modules) do
        assert(C.identifier(mod.name) and C.identifier(mod.runtime), 'Invalid client module')
        assert(not seen[mod.name], 'Duplicate client module'); seen[mod.name] = true
        local dir = C.relative(mod.idl)
        assert(C.exists(dir), 'Missing IDL directory: ' .. dir)
        for _, filename in ipairs(C.files(dir)) do
            if filename:match('%.xml$') then
                local base = filename:sub(1, -5)
                assert(C.identifier(base) and base ~= 'index', 'Invalid IDL filename')
                targets[#targets + 1] = { source=dir .. '/' .. filename, runtime=mod.runtime,
                    javascript=OUT .. '/package/' .. mod.name .. '/' .. base .. '.js',
                    declaration=OUT .. '/package/' .. mod.name .. '/' .. base .. '.d.ts',
                    receipt=OUT .. '/state/' .. mod.name .. '/' .. base .. '.json' }
            end
        end
    end
    return targets
end
function C.generator_sources()
    local paths = {}
    for _, name in ipairs({'biop_clients', 'idl_gen_javascript_clients', 'idl_gen'}) do
        paths[#paths + 1] = assert(package.searchpath(name, package.path), 'Install updated service_utils first')
    end
    return paths
end
-- PER-IDL RECEIPT: idl_gen passes its already-parsed interface here. Write the
-- receipt last so assembly never mistakes a partial generation for a complete one.
function C.generate_client(iface, source, javascript, runtime, receipt)
    C.lock(receipt .. '.lock', function()
        local name = G.generate(iface, javascript, runtime, C)
        local declaration = javascript:gsub('%.js$', '.d.ts')
        C.write(receipt, C.encode({name=name, hash=C.sha(source), runtime=runtime,
            generator=fingerprint(), output_hash=C.sha(javascript), declaration_hash=C.sha(declaration)}) .. '\n')
        -- Make uses timestamps, including when a source was touched without edits.
        C.run('touch ' .. C.quote(javascript) .. ' ' .. C.quote(declaration) .. ' ' .. C.quote(receipt))
    end)
end
local function revision()
    local p = io.popen('git rev-parse HEAD 2>/dev/null')
    local s = p:read('*a'):gsub('%s+$', ''); p:close()
    return s ~= '' and s or 'unversioned'
end
-- ASSEMBLY ENTRY POINT: all per-IDL grouped targets must have completed first.
-- Receipts carry the interface name, avoiding a second XML parse just for indexes.
-- This function deliberately fails on missing/stale outputs instead of generating
-- them behind Make's back. It runs once after Make satisfies the prerequisites.
function C.build()
    local cfg = config()
    return C.lock(OUT .. '/.lock', function()
        local pkgdir = OUT .. '/package'
        local files, groups, inputs = {}, {}, {}
        local generator = fingerprint()
        local seen_modules = {}
        -- Phase A: consume receipts and verify each per-IDL output. Interface
        -- names can differ from filenames; the receipt supplies the parsed name.
        for _, mod in ipairs(cfg.modules) do
            assert(C.identifier(mod.name) and C.identifier(mod.runtime), 'Invalid module configuration')
            assert(not seen_modules[mod.name], 'Duplicate client module'); seen_modules[mod.name] = true
            local directory = C.relative(mod.idl)
            assert(C.exists(directory), 'Missing IDL directory: ' .. directory)
            local services, seen = {}, {}
            for _, filename in ipairs(C.files(directory)) do
                if filename:match('%.xml$') then
                    local source = directory .. '/' .. filename
                    local base = filename:sub(1, -5)
                    assert(C.identifier(base) and base ~= 'index', 'Invalid/reserved IDL filename: ' .. filename)
                    local rel = mod.name .. '/' .. base .. '.js'
                    local decl = rel:gsub('%.js$', '.d.ts')
                    local hash = C.sha(source)
                    inputs[source] = hash
                    -- gidl owns generation. Assembly only consumes its committed receipt.
                    local receipt = OUT .. '/state/' .. mod.name .. '/' .. base .. '.json'
                    assert(C.exists(receipt), 'Missing client receipt: run make before biop-clients build: ' .. source)
                    local generated = C.load(receipt)
                    assert(generated.hash == hash and generated.generator == generator and generated.runtime == mod.runtime,
                        'Stale client receipt: run make -B api-clients: ' .. source)
                    assert(C.exists(pkgdir .. '/' .. rel) and C.sha(pkgdir .. '/' .. rel) == generated.output_hash,
                        'Missing/changed JavaScript output: run make -B api-clients: ' .. rel)
                    assert(C.exists(pkgdir .. '/' .. decl) and C.sha(pkgdir .. '/' .. decl) == generated.declaration_hash,
                        'Missing/changed declaration output: run make -B api-clients: ' .. decl)
                    local name = generated.name
                    assert(not seen[name], 'Duplicate service in ' .. mod.name .. ': ' .. name); seen[name] = true
                    services[#services + 1] = { name=name, file=base }
                    files[rel] = true
                    files[decl] = true

                end
            end
            table.sort(services, function(a, b) return a.name < b.name end)
            -- Phase B: assemble static imports and explicit lazy getters. The
            -- declaration index mirrors these getters for npm-package IntelliSense.
            local imports, properties, exports, declarations = {}, {}, {}, {}
            for _, svc in ipairs(services) do
                imports[#imports + 1] = 'import { ' .. svc.name .. ' } from "./' .. svc.file .. '.js";'
                exports[#exports + 1] = svc.name
                properties[#properties + 1] = '    get ' .. svc.name .. '() {\n        return ' .. svc.name .. '(session);\n    },'
                declarations[#declarations + 1] = '    readonly ' .. svc.name .. ': ReturnType<typeof ' .. svc.name .. '>;'
            end
            local factory = 'create' .. mod.name:sub(1,1):upper() .. mod.name:sub(2) .. 'Client'
            local index = G.header .. table.concat(imports, '\n') .. '\nexport { ' .. table.concat(exports, ', ') .. ' };\n\n'
                .. '/** @param {Object} session */\nexport const ' .. factory .. ' = (session) => ({\n'
                .. table.concat(properties, '\n') .. '\n});\n'
            C.write(pkgdir .. '/' .. mod.name .. '/index.js', index)
            C.write(pkgdir .. '/' .. mod.name .. '/index.d.ts', G.header .. table.concat(imports, '\n')
                .. '\nexport { ' .. table.concat(exports, ', ') .. ' };\nexport declare const ' .. factory
                .. ': (session: object) => {\n' .. table.concat(declarations, '\n') .. '\n};\n')
            files[mod.name .. '/index.js'] = true
            files[mod.name .. '/index.d.ts'] = true
            groups[#groups + 1] = {name=mod.name, factory=factory}
        end
        local lines, bound, declarations, declared_bound = {G.header}, {}, {G.header}, {}
        -- Root exports compose the per-module factories without binding services
        -- globally. Every consumer still supplies its own session object.
        local exports = { ['.']='./index.js', ['./package.json']='./package.json' }
        for _, group in ipairs(groups) do
            lines[#lines + 1] = 'import * as ' .. group.name .. ' from "./' .. group.name .. '/index.js";'
            lines[#lines + 1] = 'import { ' .. group.factory .. ' } from "./' .. group.name .. '/index.js";'
            lines[#lines + 1] = 'export { ' .. group.name .. ', ' .. group.factory .. ' };'
            declarations[#declarations + 1] = 'import * as ' .. group.name .. ' from "./' .. group.name .. '/index.js";'
            declarations[#declarations + 1] = 'import { ' .. group.factory .. ' } from "./' .. group.name .. '/index.js";'
            declarations[#declarations + 1] = 'export { ' .. group.name .. ', ' .. group.factory .. ' };'
            bound[#bound + 1] = '    ' .. group.name .. 'Client: ' .. group.factory .. '(session),'
            declared_bound[#declared_bound + 1] = '    ' .. group.name .. 'Client: ReturnType<typeof ' .. group.factory .. '>;'
            exports['./' .. group.name] = './' .. group.name .. '/index.js'
            exports['./' .. group.name .. '/*'] = './' .. group.name .. '/*.js'
        end
        lines[#lines + 1] = '\n/** @param {Object} session */\nexport const createServiceClients = (session) => ({\n'
            .. table.concat(bound, '\n') .. '\n});\n'
        C.write(pkgdir .. '/index.js', table.concat(lines, '\n'))
        declarations[#declarations + 1] = 'export declare const createServiceClients: (session: object) => {\n'
            .. table.concat(declared_bound, '\n') .. '\n};\n'
        C.write(pkgdir .. '/index.d.ts', table.concat(declarations, '\n'))
        C.write(pkgdir .. '/package.json', C.encode({name=cfg.package, version=cfg.version, private=true,
            type='module', main='./index.js', types='./index.d.ts', exports=exports, sideEffects=false,
            peerDependencies={WebUI_Framework=cfg.framework_version}}) .. '\n')
        files['index.js'], files['index.d.ts'], files['package.json'], files['build-info.json'] = true, true, true, true
        C.write(pkgdir .. '/build-info.json', C.encode({schema_revision=revision(), inputs=inputs,
            generator=generator, config_sha256=C.sha('api-clients.lua')}) .. '\n')
        -- Only this dedicated generated tree is reconciled; deleted IDLs cannot leak into releases.
        for rel in pairs(C.tree(pkgdir)) do if not files[rel] then assert(os.remove(pkgdir .. '/' .. rel)) end end
        local artifact = 'biop-api-clients-' .. cfg.version .. '.tgz'
        -- Phase C: package only after every input/output has been verified.
        -- Development can explicitly allow replacing contents at the same version.
        local release = OUT .. '/releases/' .. cfg.version
        local content = C.tree(pkgdir)
        local repack = true
        if C.exists(release .. '/manifest.json') then
            local prev = C.load(release .. '/manifest.json')
            repack = C.encode(prev.files) ~= C.encode(content)
            assert(not repack or cfg.allow_version_reuse == true,
                'Client contents changed: increment api-clients.lua version')
            assert(C.sha(release .. '/' .. artifact) == prev.sha256, 'Existing build artifact is corrupt')
        end
        if repack then
            C.mkdir(OUT .. '/staging')
            -- npm owns the npm archive format. No lifecycle scripts or network are required.
            C.run('npm pack ' .. C.quote('./' .. pkgdir) .. ' --ignore-scripts --pack-destination '
                .. C.quote(OUT .. '/staging') .. ' --cache ' .. C.quote(OUT .. '/npm-cache'))
            local temp = OUT .. '/staging/' .. artifact
            assert(C.exists(temp), 'npm did not produce expected artifact: ' .. artifact)
            C.mkdir(release)
            C.write(release .. '/' .. artifact, C.read(temp))
            C.write(release .. '/manifest.json', C.encode({package=cfg.package, version=cfg.version,
                language='javascript', format='npm', artifact=artifact, sha256=C.sha(temp), files=content}) .. '\n')
            os.remove(temp)
        end
        C.write(OUT .. '/selected.json', C.encode({version=cfg.version}) .. '\n')
        print('API clients ready: ' .. release .. '/' .. artifact)
    end)
end
-- DEPLOY ENTRY POINT: validate the completed release and copy it to shared storage.
-- It never calls npm in a frontend or rebuilds an artifact during sudo deploy.
function C.publish()
    local cfg = config()
    assert(C.load(OUT .. '/selected.json').version == cfg.version, 'Build the configured clients before deploy')
    local release = OUT .. '/releases/' .. cfg.version
    local manifest = C.load(release .. '/manifest.json')
    assert(manifest.version == cfg.version and manifest.package == cfg.package, 'Artifact/config mismatch')
    assert(C.sha(release .. '/' .. manifest.artifact) == manifest.sha256, 'Build artifact checksum mismatch')
    -- A deploy must not publish an artifact left behind by an older schema/config checkout.
    local info = C.load(OUT .. '/package/build-info.json')
    assert(info.config_sha256 == C.sha('api-clients.lua'), 'Client config changed: build again')
    assert(info.generator == fingerprint(), 'Client generator changed: build again')
    local inputs = {}
    for _, mod in ipairs(cfg.modules) do
        for _, name in ipairs(C.files(mod.idl)) do
            if name:match('%.xml$') then inputs[mod.idl .. '/' .. name] = C.sha(mod.idl .. '/' .. name) end
        end
    end
    assert(C.encode(inputs) == C.encode(info.inputs), 'IDLs changed: build again')
    assert(C.encode(C.tree(OUT .. '/package')) == C.encode(manifest.files), 'Package changed: build again')
    local destination = C.store() .. '/' .. cfg.version .. '/javascript/npm'
    C.mkdir(C.store(), true)
    C.lock(C.store() .. '/.publish-lock', function()
        if C.exists(destination .. '/manifest.json') then
            local old = C.load(destination .. '/manifest.json')
            assert(C.sha(destination .. '/' .. old.artifact) == old.sha256, 'Deployed artifact checksum mismatch')
            assert(C.encode(old) == C.encode(manifest) or cfg.allow_version_reuse == true,
                'Refusing to replace deployed clients: increment the artifact version')
        end
        do
            C.mkdir(destination, true)
            C.write(destination .. '/' .. manifest.artifact, C.read(release .. '/' .. manifest.artifact), true)
            -- The manifest is the commit marker and is installed last.
            C.write(destination .. '/manifest.json', C.encode(manifest) .. '\n', true)
        end
    end)
    print('API clients published: ' .. destination)
end

-- 4. FRONTEND DISTRIBUTION AND COMMAND DISPATCH
local function selected()
    local pkg = C.load('package.json')
    local spec = (pkg.dependencies or {})['@biop/api-clients']
    local version = type(spec) == 'string' and spec:match('^file:biop%-api%-clients%-(%d+%.%d+%.%d+)%.tgz$')
    assert(version, 'Set dependencies["@biop/api-clients"] to file:biop-api-clients-<x.y.z>.tgz')
    return pkg, version, spec:sub(6)
end
local function manifest_for(version, artifact)
    local local_manifest = artifact:gsub('%.tgz$', '.manifest.json')
    local shared = C.store() .. '/' .. version .. '/javascript/npm'
    local manifest
    if C.exists(shared .. '/manifest.json') then manifest = C.load(shared .. '/manifest.json')
    elseif C.exists(local_manifest) then manifest = C.load(local_manifest)
    else error('API clients ' .. version .. ' are not deployed and no verified local copy exists; build and deploy biop_schema first') end
    assert(manifest.package == '@biop/api-clients' and manifest.version == version
        and manifest.language == 'javascript' and manifest.format == 'npm'
        and manifest.artifact == artifact, 'Unexpected client artifact manifest')
    assert(type(manifest.sha256) == 'string' and #manifest.sha256 == 64 and manifest.sha256:match('^%x+$'), 'Invalid artifact checksum')
    assert(type(manifest.files) == 'table' and manifest.files['package.json'], 'Missing package content checksums')
    for path, hash in pairs(manifest.files) do
        C.relative(path)
        assert(type(hash) == 'string' and #hash == 64 and hash:match('^%x+$'), 'Invalid package file checksum')
    end
    return manifest, shared, local_manifest
end
local function local_valid(artifact, manifest)
    return C.exists(artifact) and C.sha(artifact) == manifest.sha256
end
local function verify_archive(artifact, manifest)
    local pkg = C.json.decode(C.capture('tar -xOf ' .. C.quote(artifact) .. ' package/package.json'))
    assert(pkg.name == manifest.package and pkg.version == manifest.version, 'Tarball package identity mismatch')
end
local function installed_valid(manifest)
    local dir = 'node_modules/@biop/api-clients'
    if not C.exists(dir .. '/package.json') then return false end
    local ok, pkg = pcall(C.load, dir .. '/package.json')
    if not ok then return false end
    if pkg.name ~= manifest.package or pkg.version ~= manifest.version then return false end
    local readable, files = pcall(C.tree, dir)
    return readable and C.encode(files) == C.encode(manifest.files)
end
local function sync()
    local _, version, artifact = selected()
    local manifest, shared, local_manifest = manifest_for(version, artifact)
    if not local_valid(artifact, manifest) then
        local source = shared .. '/' .. artifact
        assert(C.exists(source), 'Missing shared tarball for ' .. version .. '; deploy this version first')
        assert(C.sha(source) == manifest.sha256, 'Shared tarball checksum mismatch')
        C.write(artifact, C.read(source))
        print('Synchronized ' .. artifact)
    end
    verify_archive(artifact, manifest)
    C.write(local_manifest, C.encode(manifest) .. '\n')
    return manifest, artifact
end
local function ensure()
    local manifest = sync()
    if not installed_valid(manifest) then
        -- Suppress install lifecycle scripts to avoid recursively invoking this coordinator.
        -- This installs only the client package; setup runs a normal install for a new app.
        local _, _, artifact = selected()
        local installed, backup = 'node_modules/@biop/api-clients', '.biop-clients.lock/previous'
        local had_previous = C.exists(installed)
        if had_previous then assert(os.rename(installed, backup)) end
        local ok, err = pcall(function()
            C.run('npm install --ignore-scripts --no-audit --no-fund --no-package-lock --no-save ' .. C.quote('./' .. artifact))
            assert(installed_valid(manifest), 'Installed API client contents do not match the selected artifact')
        end)
        if not ok then
            C.remove_tree(installed)
            if had_previous then assert(os.rename(backup, installed), 'Failed to restore previous client installation') end
            error(err)
        end
        C.remove_tree(backup)
        print('Installed API clients ' .. manifest.version)
    else print('API clients ' .. manifest.version .. ' already installed') end
end
local function check()
    local _, version, artifact = selected()
    local manifest = manifest_for(version, artifact)
    assert(local_valid(artifact, manifest), 'Missing/stale client tarball: run biop-clients sync')
    verify_archive(artifact, manifest)
    assert(installed_valid(manifest), 'Missing/stale installed clients: run biop-clients ensure')
    print('API clients ' .. version .. ' verified')
end
local function use(version)
    C.version(version)
    local _, old_version = selected()
    if old_version == version then return ensure() end
    local original = C.read('package.json')
    local lock = C.exists('package-lock.json') and C.read('package-lock.json') or nil
    -- Validate and locate the requested version before changing consumer metadata.
    manifest_for(version, 'biop-api-clients-' .. version .. '.tgz')
    local updated, count = original:gsub('("@biop/api%-clients"%s*:%s*")file:biop%-api%-clients%-%d+%.%d+%.%d+%.tgz(")',
        '%1file:biop-api-clients-' .. version .. '.tgz%2')
    assert(count == 1, 'Expected exactly one API client dependency')
    C.write('package.json', updated)
    local ok, err = pcall(ensure)
    if not ok then
        C.write('package.json', original)
        if lock then C.write('package-lock.json', lock) end
        error(tostring(err) .. '\nDependency selection restored. Run biop-clients ensure to restore the previously installed version.')
    end
end
function C.main(args)
    local cmd = args[1]
    local ok, err = pcall(function()
        assert((cmd == 'use' and #args == 2) or (cmd ~= 'use' and #args == 1),
            'Usage: biop-clients <build|publish|sync|ensure|check|use VERSION>')
        if cmd == 'build' or cmd == 'publish' then return C[cmd]() end
        local actions = {sync=sync, ensure=ensure, check=check, use=function() use(args[2]) end}
        assert(actions[cmd], 'Unknown biop-clients command: ' .. tostring(cmd))
        return C.lock('.biop-clients.lock', actions[cmd])
    end)
    if not ok then io.stderr:write('biop-clients: ' .. tostring(err) .. '\n'); os.exit(1) end
end

if arg and arg[0] and arg[0]:match('biop_clients%.lua$') then C.main(arg) end
return C
