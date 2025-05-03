local tracker = require('@lib/tracker')
local editor = require('@lib/editor')
local luau = require('@lib/luau')

local serde = require("@lune/serde")
local fs = require("@lune/fs")

local merge = require('@utils/merge')

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

local function setup()
    editor.hide_globs('*Packages/**')
    editor.lock_globs('*Packages/**')
    tracker.ignore_globs('*Packages/**')
    luau.ignore_import_globs('**/_Index/**')
    luau.ignore_diagnostic_globs('*Packages/**')
end

-- module
return table.freeze {
    save = save,
    setup = setup,
    manifest = manifest,
}
