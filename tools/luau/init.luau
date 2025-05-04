local tracker = require('@lib/tracker')
local editor = require('@lib/editor')
local file = require('@lib/file')
local merge = require('@utils/merge')

-- defs
type luaurc = {
    languageMode: 'strict' | 'nonstrict' | 'nocheck'?,
    lintErrors: boolean?,
    typeErrors: boolean?,
    aliases: { [string]: string },
    globals: { string },
    lint: { [string]: boolean },
}

-- vars
local rc: luaurc = {
    languageMode = 'strict',
    aliases = {},
    globals = {},
    lint = {},
}
local sup = false

-- functions
local function save()
    if not sup then return end
    file.write_json('.luaurc', rc)
end

local function setup()
    if sup then return end
    sup = true
    merge(rc, file.read_json('.luaurc'))

    editor.hide_globs('.luaurc')
    tracker.set_attribute('*.luau', 'text')
end

-- module
return table.freeze {
    rc = rc,
    save = save,
    setup = setup,
}