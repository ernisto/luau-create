local tracker = require('@lib/tracker')
local editor = require('@lib/editor')
local rojo = require('@tools/rojo')

-- vars
local sup = false

-- functions
local function save()
    if not sup then return end
end

local function add_system_path(system_path: string, roblox_path: {string})
    rojo.add_system_path(system_path, roblox_path)
end

local function setup()
    if sup then return end
    sup = true
    tracker.set_attribute('*.rbxm', 'binary')
    tracker.set_attribute('*.rbxl', 'binary')
    tracker.ignore_globs('*.rbxl')
    editor.hide_globs('.rbxl')
end

-- module
return table.freeze {
    save = save,
    setup = setup,
    add_system_path = add_system_path,
}
