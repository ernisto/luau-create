local project = require('@lib/project')
local file = require('@lib/file')

local infer = require('@utils/infer')
local luau = require('@tools/luau')
local lsp = require('@tools/lsp')

-- functions
type glob = string
local function ignore_import_globs(...: glob)
    lsp.ignore_import_globs(...)
end
local function ignore_diagnostic_globs(...: glob)
    lsp.ignore_diagnostic_globs(...)
end
local function add_globals(...: string)
    for _,global in {...} do
        if table.find({...}, global) then continue end
        table.insert(luau.rc.globals, global)
    end
end
local function add_alias(alias: string, path: string)
    luau.add_alias(alias, path)
end

local function setup()
    if project.project.entrypoint then
        file.write_str(project.project.entrypoint)
    end
    for alias, path in infer.await_entry_points() do
        local dir = string.match(path, "(.*)/([^/]+)$")
        add_alias(alias, dir or path)
    end
end

-- module
return table.freeze {
    setup = setup,
    ignore_diagnostic_globs = ignore_diagnostic_globs,
    ignore_import_globs = ignore_import_globs,
    add_globals = add_globals,
    add_alias = add_alias,
}
