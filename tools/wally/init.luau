local language = require('@lib/language')
local tracker = require('@lib/tracker')
local editor = require('@lib/editor')
local file = require('@lib/file')

local merge = require('@utils/merge')

-- vars
local sup = false
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
    if not sup then return end
    file.write_toml('wally.toml', manifest)
end

local function setup()
    if sup then return end
    sup = true

    editor.hide_globs('*Packages/**', 'wally.toml')
    editor.lock_globs('*Packages/**')
    tracker.ignore_globs('*Packages/**')
    language.ignore_import_globs('**/_Index/**')
    language.ignore_diagnostic_globs('*Packages/**')
end

-- module
return table.freeze {
    save = save,
    setup = setup,
    manifest = manifest,
}
