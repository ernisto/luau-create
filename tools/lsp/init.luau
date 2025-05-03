local vsc = require('@tools/vsc')

local ignore_imports = vsc.settings['luau-lsp.completion.imports.ignoreGlobs'] or {}
vsc.settings['luau-lsp.completion.imports.ignoreGlobs'] = ignore_imports

local ignore_diagnostics = vsc.settings['luau-lsp.ignoreGlobs'] or {}
vsc.settings['luau-lsp.ignoreGlobs'] = ignore_diagnostics

-- functions
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
    vsc.recommend_extensions('JohnnyMorganz.luau-lsp')
end

-- module
return table.freeze {
    setup = setup,
    save = table.pack,
    ignore_import_globs = ignore_import_globs,
    ignore_diagnostic_globs = ignore_diagnostic_globs,
}