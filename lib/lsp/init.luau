local vsc = require('@lib/editor/vsc')

local ignore_imports = vsc.settings['luau-lsp.completion.imports.ignoreGlobs'] or {}
local ignore_diagnostics = vsc.settings['luau-lsp.ignoreGlobs'] or {}

-- functions
local enabled = false
local function setup()
    if enabled then return end
    enabled = true

    vsc.settings['luau-lsp.completion.imports.ignoreGlobs'] = ignore_imports
    vsc.settings['luau-lsp.ignoreGlobs'] = ignore_diagnostics
    vsc.recommend_extensions('JohnnyMorganz.luau-lsp')
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

-- module
return table.freeze {
    setup = setup,
    save = table.pack,
    ignore_import_globs = ignore_import_globs,
    ignore_diagnostic_globs = ignore_diagnostic_globs,
}