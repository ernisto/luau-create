local tracker = require('@lib/tracker')
local editor = require('@lib/editor')
local luau = require('@lib/luau')

local serde = require("@lune/serde")
local fs = require("@lune/fs")

local merge = require('@utils/merge')

-- vars
local manifest = merge(if fs.isFile('package.json') then serde.decode('json', fs.readFile('package.json')) else {}, {
    directories = {}
})

-- functions
local function save()
    fs.writeFile('package.json', serde.encode('json', manifest, true))
end

local function setup()
    editor.hide_globs('node_modules/**')
    editor.lock_globs('node_modules/**')
    tracker.ignore_globs('node_modules/**')
    luau.ignore_import_globs('**/node_modules/**')
    luau.ignore_diagnostic_globs('node_modules/**')
end

-- module
return table.freeze {
    save = save,
    setup = setup,
    manifest = manifest,
}
