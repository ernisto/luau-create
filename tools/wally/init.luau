local tracker = require('@lib/tracker')
local editor = require('@lib/editor')
local luau = require('@lib/luau')
local file = require('@lib/file')

local merge = require('@utils/merge')

-- vars
local manifest: { [string]: any } = {
    package = {
        exclude = {},
        authors = {},
        dependencies = {},
    },
    ['dev-dependencies'] = {},
    ['server-dependencies'] = {},
}
merge(manifest, file.read_toml('wally.toml') or {})

-- functions
local function save()
    file.write_toml('wally.toml', manifest)
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
