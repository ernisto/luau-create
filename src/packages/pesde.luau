local roblox_sync = require('@lib/roblox_sync')
local project = require('@lib/project')
local file = require('@lib/file')
local git = require('@lib/git')

local serde = require('@lune/serde')

-- functions
local manifest = project.manifest
local function setup()
    git.ignore_globs('package manager (pesde)', {
        'roblox_packages',
        'lune_packages',
        'luau_packages',
    })
    file.add('pesde.toml', serde.encode('toml', {
        name = manifest.name
    }))

    if manifest.environment ~= 'roblox' then return end
    roblox_sync.add_folder('ReplicatedStorage/packages', { sys_path = 'roblox_packages' })
    roblox_sync.add_folder('ServerStorage/packages', { sys_path = 'roblox_server_packages' })
end
local function build()
end

-- module
return table.freeze {
    setup = setup,
    build = build,
}