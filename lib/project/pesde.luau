local pesde = require('@lib/package_manager/pesde')
local project = require('@lib/project').project
local utils = require('@lib/utils')

-- vars
local manifest = pesde.manifest

-- functions
local function setup()
    pesde.setup()

    -- manifest
    local entry_folder_name = project.entrypoint and project.entrypoint:match("^(.-)/")
    manifest.engine = {
        pesde = "^0.6.0",
        lune = if project.environment == 'lune' then "^0.9.0" else nil,
    }

    manifest.name = `{project.host}/{project.name:gsub('-', '_')}`
    manifest.version = tostring(project.version)
    manifest.description = project.description
    manifest.license = project.license
    manifest.authors = project.authors
    manifest.repository = project.repository and project.repository.url
    manifest.private = project.private

    manifest.includes = {
        "pesde.toml",
        "README.md",
        "LICENSE",
        "docs/**/*.md",
        if entry_folder_name then `{entry_folder_name}/**` else project.entrypoint :: any
    }
    
    manifest.target.lib = if project.kind == 'package' then project.entrypoint else nil
    manifest.target.cli = utils.await_entry_points().cli
    manifest.target.environment = project.environment

    manifest.indices = {
        default = "https://github.com/pesde-pkg/index"
    }

    if project.kind == 'script' then
        manifest.target.scripts = manifest.scripts
    end

    if project.environment == 'roblox' then
        
        if project.side == 'server' then manifest.target.environment = 'roblox_server' end
        manifest.dev_dependencies.scripts = { name = "pesde/scripts_rojo", version = "^0.1.0", target = "lune" }

        manifest.scripts.roblox_sync_config_generator = ".pesde/scripts/roblox_sync_config_generator.luau"
        manifest.scripts.sourcemap_generator = ".pesde/scripts/sourcemap_generator.luau"

        manifest.place = {
            shared = "game.ReplicatedStorage.packages",
            server = "game.ServerScriptService.packages",
        }
        manifest.wally_indices = {
            default = "https://github.com/UpliftGames/wally-index"
        }
    end
end

-- module
return table.freeze {
    setup = setup
}