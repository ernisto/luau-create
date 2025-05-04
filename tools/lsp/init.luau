local merge = require('@utils/merge')
local vsc = require('@tools/vsc')

-- vars
local ignore_diagnostics = {}
local ignore_imports = {}
local sup = false

-- functions
local function save()
    if not sup then return end
end

type glob = string
local function ignore_import_globs(...: glob)
    for _,glob in {...} do
        if table.find(ignore_diagnostics, glob) then continue end
        table.insert(ignore_diagnostics, glob)
    end
end
local function ignore_diagnostic_globs(...: glob)
    for _,glob in {...} do
        if table.find(ignore_imports, glob) then continue end
        table.insert(ignore_imports, glob)
    end
end

local function setup()
    if sup then return end
    sup = true
    merge(vsc.settings, {
        ['luau-lsp.completion.imports.ignoreGlobs'] = ignore_imports,
        ['luau-lsp.ignoreGlobs'] = ignore_diagnostics,
    })

    vsc.recommend_extensions('JohnnyMorganz.luau-lsp')
end

-- module
return table.freeze {
    setup = setup,
    save = save,
    ignore_import_globs = ignore_import_globs,
    ignore_diagnostic_globs = ignore_diagnostic_globs,
}