local pesde = require('@tools/pesde/manifest')
local wally = require('@tools/wally/manifest')
local npm = require('@tools/npm/manifest')

local semver = require('@pkg/semver')
local infer = require("@utils/infer")
local merge = require("@utils/merge")

-- defs
export type project = {
    inquire: () -> (),

    environment: 'roblox' | 'lune' | 'luau',
    kind: 'package' | 'terminal' | 'script' | 'plugin' | 'game',
    side: 'client' | 'shared' | 'server'?,

    entrypoint: string?,
    directories: { [string]: string },

    name: string,
    host: string,
    version: semver.Version,
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
    return table.clone(npm)
end
local function await_maybe_extract_wally()
    local wally = wally.package
    local project = table.clone(wally)

    local name, host = string.match(wally.name or '', "(%w[_]+)/(%w[_]+)")

    project.repository = pesde.repository and { type = 'git', url = pesde.repository }
    project.environment = 'roblox'
    project.side = wally.realm
    project.name = name
    project.host = host
    return project
end
local function await_maybe_extract_pesde()
    local project = table.clone(pesde)

    local name, host = string.match(pesde.name or '', "(%w[_]+)/([%w_]+)")
    local target = pesde.target

    project.name = if name and name:gsub('_', '-') == infer.get_folder_name() then nil else name
    project.host = if host and host:gsub('_', '-') == infer.await_git_user() then nil else name
    project.repository = pesde.repository and { type = 'git', url = pesde.repository }
    project.environment = target and target.environment
    project.kind = if target.lib then 'package' elseif target.bin then 'terminal' else 'application'
    project.entrypoint = target and (target.lib or target.bin)

    return project
end

local project: project = {
    host = infer.await_git_user(),
    name = infer.get_folder_name(),
    directories = infer.await_entry_points(),
    environment = nil :: any, --infer_environment()
    license = nil, -- infer
    repository = { type = 'git', url = `https://github.com/{infer.await_git_user()}/{infer.get_folder_name()}` },
    authors = infer.await_git_user() and {
        assert(infer.await_git_user())
            .. if infer.await_git_email() then ` <{infer.await_git_email()}>` else ''
    }
} :: any

-- vars
project.kind = if project.directories.lib then 'package'
    elseif project.directories.plugin then 'plugin'
    elseif project.environment == 'roblox' then 'game'
    elseif project.directories.cli then 'terminal'
    else 'script'

project.entrypoint = if project.kind == 'game' then nil
    elseif project.kind == 'package' then 'lib'
    elseif project.kind == 'terminal' then 'cli'
    else project.kind

project.homepage = `{assert(project.repository).url}#readme`
project.bugs = {
    url = `{assert(project.repository).url}/issues`
}

merge(project, await_maybe_extract_npm() or {}, await_maybe_extract_wally() or {}, await_maybe_extract_pesde() or {})

-- module
return project
