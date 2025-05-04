local pesde = require("@tools/pesde")
local wally = require("@tools/wally")
local npm = require("@tools/npm")

local semver = require('@pkg/semver')
local infer = require("@utils/infer")
local merge = require("@utils/merge")
local language = require('@lib/language')
local file = require('@lib/file')

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

    manifest.name = if name and name:gsub('_', '-') == infer.get_folder_name() then nil else name
    manifest.host = if host and host:gsub('_', '-') == infer.await_git_user() then nil else name
    manifest.repository = manifest.repository and { type = 'git', url = manifest.repository }
    manifest.environment = target and target.environment
    manifest.kind = if target.lib then 'package' elseif target.bin then 'terminal' else 'application'
    manifest.entrypoint = target and (target.lib or target.bin)
    return manifest
end

local project: project = merge(
    {},
    await_maybe_extract_npm() or {},
    await_maybe_extract_wally() or {},
    await_maybe_extract_pesde() or {}
)

local function setup()
    if project.entrypoint then
        file.write_str(project.entrypoint, '')
        for alias, path: any in infer.await_entry_points() do language.add_alias(alias, path) end
    end
end

-- module
return table.freeze {
    project = project,
    setup = setup,
}
