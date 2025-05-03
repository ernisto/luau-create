local lsp = require('@tools/lsp')

-- functions
type glob = string
local function ignore_import_globs(...: glob)
    lsp.ignore_import_globs(...)
end
local function ignore_diagnostic_globs(...: glob)
    lsp.ignore_diagnostic_globs(...)
end

-- module
return table.freeze {
    ignore_import_globs = ignore_import_globs,
    ignore_diagnostic_globs = ignore_diagnostic_globs,
}
