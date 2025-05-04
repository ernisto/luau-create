local language = require('@lib/language')
local tracker = require('@lib/tracker')
local editor = require('@lib/editor')
local file = require('@lib/file')

local merge = require('@utils/merge')

-- vars
local manifest: { [string]: any } = {
    directories = {}
}
merge(manifest, file.read_json('package.json') or {})

-- functions
local function save()
    file.write_json('package.json', manifest)
end

local function setup()
    editor.hide_globs('node_modules/**', 'package.json')
    editor.lock_globs('node_modules/**')
    tracker.ignore_globs('node_modules/**')
    language.ignore_import_globs('**/node_modules/**')
    language.ignore_diagnostic_globs('node_modules/**')
end

-- module
return table.freeze {
    save = save,
    setup = setup,
    manifest = manifest,
}
