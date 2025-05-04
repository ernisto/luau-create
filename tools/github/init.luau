local editor = require("../../lib/editor")

-- functions
local function save()
    
end

local function setup()
    editor.hide_globs('.env', '.github')
end

-- module
return table.freeze {
    save = save,
    setup = setup,
}