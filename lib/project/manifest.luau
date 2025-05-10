local pesde = require('@tools/pesde/manifest')
local wally = require('@tools/wally/manifest')
local npm = require('@tools/npm/manifest')
local stylua = require('@tools/stylua/manifest')

local license = require('@self/licenses')
local semver = require('@pkg/semver')
local infer = require("@utils/infer")
local merge = require("@utils/merge")

-- defs
export type project = {
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
    license: license.license_name?,
    authors: {string},

    homepage: string,
    repository: {
        type: 'git' | string,
        url: string,
    }?,
    funding: {
        type: 'individual' | 'patreon',
        url: string,
    }?,
    bugs: {
        email: string?,
        url: string?
    }?,

    cpu: {npm.cpu}?,
    os: {npm.os}?,
    stylua: stylua.manifest
}

-- functions
local none: any = nil
local function concat_people(people: npm.people): string
    if type(people) == 'string' then return people end
    return people.name
        .. (people.email and ` <{people.email}>` or '')
        .. (people.url and ` ({people.url})` or '')
end
local function await_maybe_extract_npm()
    local project: project = table.clone(npm) :: any

    local peoples = {npm.author, unpack(npm.contribuitors) }
    for index, people in peoples do peoples[index] = concat_people(people :: any) end

    local host, name = string.match(npm.name or '', "(%w[_]+)/(%w[_]+)")
    project.entrypoint = npm.main
    project.authors = peoples :: any
    project.host = host :: any
    project.name = name :: any
    return project
end
local function await_maybe_extract_wally()
    local wally = wally.package
    local project: project = table.clone(wally) :: any

    local host, name = string.match(wally.name or '', "(%w[_]+)/(%w[_]+)")
    project.repository = wally.repository and { type = 'git', url = wally.repository }
    project.environment = 'roblox'
    project.side = wally.realm
    project.name = name :: any
    project.host = host :: any
    return project
end
local function await_maybe_extract_pesde()
    local project: project = table.clone(pesde) :: any

    local host, name = string.match(pesde.name or '', "(%w[_]+)/([%w_]+)")
    local target = pesde.target

    project.name = if name and name:gsub('_', '-') == infer.get_folder_name() then none else name
    project.host = if host and host:gsub('_', '-') == infer.await_git_user() then none else host
    project.repository = pesde.repository and { type = 'git', url = pesde.repository }
    project.environment = if target and target.environment ~= 'roblox_server' then target.environment else none
    project.kind = if target.lib then 'package' elseif target.bin then 'terminal' elseif target.scripts then 'script' else none
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
project.funding = {
    type = 'patreon',
    url = `https://github.com/sponsors/{project.host}`,
}
project.bugs = {
    url = `{assert(project.repository).url}/issues`,
    email = infer.await_git_email(),
}

merge(project, await_maybe_extract_npm() or {}, await_maybe_extract_wally() or {}, await_maybe_extract_pesde() or {})

-- module
return project
