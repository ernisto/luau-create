local editor = require('@lib/editor')
local lsp = require('@lib/lsp')
local git = require('@lib/git')

local serde = require("@lune/serde")
local fs = require("@lune/fs")

local merge = require('@lib/merge')

-- vars
local manifest = merge(if fs.isFile('package.json') then serde.decode('json', fs.readFile('package.json')) else {}, {
    directories = {}
})

-- functions
local function save()
    fs.writeFile('package.json', serde.encode('json', manifest, true))
end

local enabled = false
local function setup()
    if enabled then return end
    enabled = true

    editor.hide_globs('node_modules/**')
    editor.lock_globs('node_modules/**')
    git.ignore_globs('node_modules/**')
    lsp.ignore_import_globs('**/node_modules/**')
    lsp.ignore_diagnostic_globs('node_modules/**')
end

-- module
return table.freeze {
    save = save,
    setup = setup,
    manifest = manifest,
}
