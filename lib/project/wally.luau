local wally = require('@lib/package_manager/wally')
local project = require('@lib/project').project
local utils = require('@lib/utils')

-- vars
local manifest = wally.manifest

-- functions
local enabled = false
local function setup()
    if enabled then return end
    enabled = true

    wally.setup()

    -- manifest
    local entry_folder_name = project.entrypoint and project.entrypoint:match("^(.-)/")

    manifest.package.name = `{project.host}/{project.name:gsub('-', '_')}`
    manifest.package.version = tostring(project.version)
    manifest.package.description = project.description
    manifest.package.license = project.license
    manifest.package.authors = project.authors or {
        project.host .. if utils.await_git_email() then ` <{utils.await_git_email()}>` else ''
    }
    manifest.package.repository = project.repository and project.repository.url
    manifest.package.homepage = project.homepage
    manifest.package.private = project.private

    manifest.package.exclude = {}
    manifest.package.include = {
        "wally.toml",
        "README.md",
        "LICENSE",
        "docs/**/*.md",
        if entry_folder_name then `{entry_folder_name}/**` else project.entrypoint :: any
    }

    manifest.package.realm = if project.side == 'server' then 'server' else 'shared'
    manifest.package.index = "https://github.com/UpliftGames/wally-index"

    manifest.place = {
        shared = "game.ReplicatedStorage.packages",
        server = "game.ServerScriptService.packages",
    }
end

-- module
return table.freeze {
    setup = setup
}