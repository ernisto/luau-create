local tracker = require('@lib/tracker')
local editor = require('@lib/editor')
local rojo = require('@tools/rojo')

-- functions
local function add_system_path(system_path: string, roblox_path: {string})
    rojo.add_system_path(system_path, roblox_path)
end

local function setup()
    tracker.set_attribute('*.rbxm', 'binary')
    tracker.set_attribute('*.rbxl', 'binary')
    tracker.ignore_globs('*.rbxl')
    editor.hide_globs('.rbxl')
end

-- module
return table.freeze {
    setup = setup,
    add_system_path = add_system_path,
}
