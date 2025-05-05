local project = require('@lib/project').project
local language = require('@lib/language')
local tracker = require('@lib/tracker')
local editor = require('@lib/editor')
local file = require('@lib/file')

local infer = require('@utils/infer')

-- vars
local sup = false
local manifest = require('@self/manifest')

-- functions
local function save()
    if not sup then return end
    file.write_toml('pesde.toml', manifest)
end

local function setup()
    if sup then return end
    sup = true
    
    editor.hide_globs('*_packages/**', '.pesde', 'pesde.toml')
    editor.lock_globs('*_packages/**', '.pesde')
    tracker.ignore_globs('*_packages/**', '.pesde')
    language.ignore_import_globs('**/.pesde/**')
    language.ignore_diagnostic_globs('*_packages/**', '.pesde')

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
    manifest.target.cli = infer.await_entry_points().cli
    manifest.target.environment = project.environment

    manifest.indices = {
        default = "https://github.com/pesde-pkg/index"
    }

    if project.kind == 'script' then
        manifest.target.scripts = manifest.scripts
    end
    if project.environment == 'roblox' then
        manifest.wally_indices = {
            default = "https://github.com/UpliftGames/wally-index"
        }
        if project.side == 'server' then
            manifest.target.environment = 'roblox_server'
        end
    end
end

-- module
return table.freeze {
    save = save,
    setup = setup,
    manifest = manifest,
}
