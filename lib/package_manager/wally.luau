local editor = require('@lib/editor')
local lsp = require('@lib/lsp')
local git = require('@lib/git')

local serde = require("@lune/serde")
local fs = require("@lune/fs")

local merge = require('@lib/merge')

-- vars
local manifest = merge(if fs.isFile('wally.toml') then serde.decode('toml', fs.readFile('wally.toml')) else {}, {
    package = {
        exclude = {},
        authors = {},
        dependencies = {},
    },
    ['dev-dependencies'] = {},
    ['server-dependencies'] = {},
})

-- functions
local function save()
    fs.writeFile('wally.toml', serde.encode('toml', manifest, true))
end

local enabled = false
local function setup()
    if enabled then return end
    enabled = true

    editor.hide_globs('*Packages/**')
    editor.lock_globs('*Packages/**')
    git.ignore_globs('*Packages/**')
    lsp.ignore_import_globs('**/_Index/**')
    lsp.ignore_diagnostic_globs('*Packages/**')
end

-- module
return table.freeze {
    save = save,
    setup = setup,
    manifest = manifest,
}
