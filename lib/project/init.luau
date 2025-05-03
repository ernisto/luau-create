local pesde = require("../package_manager/pesde")
local wally = require("../package_manager/wally")
local npm = require("../package_manager/npm")

local semver = require('@pkg/semver')
local utils = require("../utils")
local merge = require("@lib/merge")

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

local project = merge(
    {} :: project,
    await_maybe_extract_npm() or {},
    await_maybe_extract_wally() or {},
    await_maybe_extract_pesde() or {}
)

-- functions
local function setup()
    
end

-- module
return table.freeze {
    setup = setup,
    project = project,
}
