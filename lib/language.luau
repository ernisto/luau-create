local tracker = require('@lib/tracker')
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
    if luau.rc.aliases[alias] and luau.rc.aliases[alias] ~= path then warn(`alias '{alias}' already defined`) end
    luau.rc.aliases[alias] = path
end

local function setup()
    tracker.set_attribute('*.luau', 'text', 'eol=lf')
end

-- module
return table.freeze {
    setup = setup,
    ignore_diagnostic_globs = ignore_diagnostic_globs,
    ignore_import_globs = ignore_import_globs,
    add_globals = add_globals,
    add_alias = add_alias,
}
