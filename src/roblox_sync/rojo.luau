local file = require('@lib/file')
local project = {}

-- functions
local function sync_folder(roblox_path: string, sys_path: string)
    
end

local function setup()
    
end
local function build()
    file.add('default.project.json', '')
end

-- module
return table.freeze {
    setup = setup,
    build = build,
}