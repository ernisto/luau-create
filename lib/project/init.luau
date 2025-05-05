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
    return npm
end
local function await_maybe_extract_wally()

    local wally = wally.package
    local name, host = string.match(wally.name or '', "(%w[_]+)/(%w[_]+)")

    wally.environment = 'roblox'
    wally.side = wally.realm
    wally.name = name
    wally.host = host
    return wally
end
local function await_maybe_extract_pesde()

    local name, host = string.match(pesde.name or '', "(%w[_]+)/([%w_]+)")
    local target = pesde.target

    pesde.name = if name and name:gsub('_', '-') == infer.get_folder_name() then nil else name
    pesde.host = if host and host:gsub('_', '-') == infer.await_git_user() then nil else name
    pesde.repository = pesde.repository and { type = 'git', url = pesde.repository }
    pesde.environment = target and target.environment
    pesde.kind = if target.lib then 'package' elseif target.bin then 'terminal' else 'application'
    pesde.entrypoint = target and (target.lib or target.bin)
    return pesde
end

local project: project = merge(
    {},
    await_maybe_extract_npm() or {},
    await_maybe_extract_wally() or {},
    await_maybe_extract_pesde() or {}
)

-- module
return table.freeze {
    project = project,
}
