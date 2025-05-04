local editor = require("@lib/editor")
local file = require('@lib/file')
local merge = require('@utils/merge')
local tracker = require("../../lib/tracker")

-- vars
local rc = {
    languageMode = 'strict',
    lintErrors = true,
    typeErrors = true,
    aliases = {},
    globals = {},
    lint = {},
}
merge(rc, file.read_json('.luaurc'))

-- functions
local function save()
    file.write_json('.luaurc', rc)
end

local function setup()
    editor.hide_globs('.luaurc')
    tracker.set_attribute('*.luau', 'text')
end

-- module
return table.freeze {
    rc = rc,
    save = save,
    setup = setup,
}