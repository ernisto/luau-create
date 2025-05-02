local pesde = require("@lib/package_manager/pesde")
local wally = require("@lib/package_manager/wally")
local npm = require("@lib/package_manager/npm")

local inquisitor = require("@lib/inquisitor")
local semver = require('@pkg/semver')
local merge = require("@lib/merge")
local utils = require('@lib/utils')

-- defs
export type project = {
    inquire: () -> (),

    environment: 'roblox' | 'lute' | 'lune' | 'luau',
    kind: 'package' | 'terminal' | 'plugin' | 'script',
    side: 'client' | 'shared' | 'server'?,

    name: string,
    host: string,
    version: semver.Version,
    entrypoint: string?,
    description: string,
    private: boolean,
    license: 'MIT'?,
    authors: {string},

    repository: {
        type: 'git' | string,
        url: string,
    }?,

    homepage: string,
    bugs: {
        url: string
    },
}

-- functions
local function await_maybe_extract_npm()
    local data = npm.manifest
    data.author = data.host
    return data
end
local function await_maybe_extract_wally()

    local manifest = wally.manifest.package
    local name, host = string.match(manifest.name or '', "(%w[_]+)/(%w[_]+)")

    manifest.environment = 'roblox'
    manifest.side = manifest.realm
    manifest.name = name
    manifest.host = host
    return manifest
end
local function await_maybe_extract_pesde()

    local manifest = pesde.manifest
    local name, host = string.match(manifest.name or '', "(%w[_]+)/([%w_]+)")
    local target = manifest.target

    manifest.name = if name and name:gsub('_', '-') == utils.get_folder_name() then nil else name
    manifest.host = if host and host:gsub('_', '-') == utils.await_git_user() then nil else name
    manifest.repository = manifest.repository and { type = 'git', url = manifest.repository }
    manifest.environment = target and target.environment
    manifest.kind = if target.lib then 'package' elseif target.bin then 'terminal' else 'application'
    manifest.entrypoint = target and (target.lib or target.bin)
    return manifest
end

-- main
local project = merge(
    {} :: project,
    await_maybe_extract_npm() or {},
    await_maybe_extract_wally() or {},
    await_maybe_extract_pesde() or {}
)
local function inquire()
    local entry_points = utils.await_entry_points()
    local infered_user = utils.await_git_user()
    local folder_name = utils.get_folder_name()

    -- root
    local q = inquisitor(project)
    local env = q.enum {
        name = 'environment',
        { name = 'roblox' },
        { name = 'lute' },
        { name = 'lune' },
        { name = 'luau' },
    }
    local kind = q.enum {
        name = 'kind',
        default_index = if entry_points.lib then 1
            elseif entry_points.plugin then 2
            elseif env == 'roblox' then 3
            elseif entry_points.cli then 5
            else 4,

        { name = 'package' },
        if env == 'roblox' then { name = 'plugin' } else nil :: any,
        if env == 'roblox' then { name = 'game' } else nil :: any,

        if env ~= 'roblox' then { name = 'script', desc = 'terminal scripts, such for building, or deploy' } else nil :: any,
        if env ~= 'roblox' and env ~= 'luau' then { name = 'terminal' } else nil :: any,
    }
    if env == 'roblox' and kind == 'package' then
        q.enum {
            name = 'side',
            { name = 'client' },
            { name = 'shared' },
            { name = 'server' },
        }
    end
    if kind ~= 'plugin' and kind ~= 'game' then
        q.str {
            name = 'entrypoint',
            default = `{if kind == 'package' then 'lib' else kind}/init.luau` or select(2, next(entry_points))
        }
    end

    local name = q.identifier { name = 'name', default = folder_name }
    local host = q.identifier { name = 'host', default = infered_user }
    q.version { name = 'version', default = "0.1.0" }

    q.str { name = 'description', optional = true }
    q.enum {
        name = 'license',
        optional = true,
        { name = 'MIT' },
    }
    q.bool { name = 'private' }

    -- repo
    local repo_type, repo_url
    local q_repository = q.struct { name = 'repository' } do
        repo_type = q_repository.enum {
            name = 'type',
            optional = true,
            default_index = 1,
            { name = 'git' }
        }
        repo_url = q_repository.str {
            name = 'url',
            default = if repo_type == 'git' then `https://github.com/{host}/{name}` else nil
        }
    end

    -- pages
    q.str { name = 'homepage', optional = true, default = repo_url and `{repo_url}#readme` }

    local q_bugs = q.struct { name = 'bugs' } do
        q_bugs.str { name = 'url', optional = true, default = repo_url and `{repo_url}/issues` }
    end
end

-- module
return table.freeze {
    setup = inquire,
    project = project,
}
