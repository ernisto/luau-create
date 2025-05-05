local infer = require('@utils/infer')
local project = require('@lib/project').project
local language = require('@lib/language')
local tracker = require('@lib/tracker')
local editor = require('@lib/editor')
local file = require('@lib/file')

-- vars
local sup = false
local manifest = require('@self/manifest')

-- functions
local function save()
    if not sup then return end
    file.write_toml('wally.toml', manifest)
end

local function setup()
    if sup then return end
    sup = true

    editor.hide_globs('*Packages/**', 'wally.toml')
    editor.lock_globs('*Packages/**')
    tracker.ignore_globs('*Packages/**')
    language.ignore_import_globs('**/_Index/**')
    language.ignore_diagnostic_globs('*Packages/**')

    local entry_folder_name = project.entrypoint and project.entrypoint:match("^(.-)/")

    manifest.package.name = `{project.host}/{project.name:gsub('-', '_')}`
    manifest.package.version = tostring(project.version)
    manifest.package.description = project.description
    manifest.package.license = project.license
    manifest.package.authors = project.authors or {
        project.host .. if infer.await_git_email() then ` <{infer.await_git_email()}>` else ''
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
    save = save,
    setup = setup,
    manifest = manifest,
}
