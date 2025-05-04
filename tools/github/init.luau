local editor = require('@lib/editor')

-- vars
local sup = false

-- functions
local function save()
    if not sup then return end
end

local function setup()
    if sup then return end
    sup = true
    editor.hide_globs('.env', '.github')
end

-- module
return table.freeze {
    save = save,
    setup = setup,
}