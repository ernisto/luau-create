local file = require('@lib/file')
local fs = require('@lune/fs')
local merge = require('@utils/merge')
local license = require('@lib/project/licenses')

-- defs
export type dependency = pesde_dependency | wally_dependency | github_dependency | workspace_dependency | path_dependency
export type pesde_dependency = { name: string, version: version, index: string?, target: environment? }
export type wally_dependency = { wally: string, version: version, index: string? }
export type github_dependency = { repo: string, rev: sha | tag | branch, path: path }
export type workspace_dependency = { workspace: string, version: version }
export type path_dependency = { path: path }

type sha = string
type tag = string
type branch = string

export type environment = 'luau' | 'lune' | 'roblox' | 'roblox_server'
type version = string
type glob = string
type author = string
type url = string
type path = string
type roblox_path = string
export type manifest = {
	name: string?,
	version: version?,
	description: string?,

	license: license.license_name?,
	authors: { author },

	private: boolean?,
	repository: url?,

	scripts: {
		roblox_sync_config_generator: path?,
		sourcemap_generator: path?,
		[string]: path,
	},

	includes: { glob },
	target: {
		environment: environment?,
		scripts: { [string]: path },
		build_files: { path }?,
		lib: path?,
		bin: path?,
	},
	place: { shared: roblox_path?, server: roblox_path? },
	wally_indices: { default: url, [string]: url }?,
	indices: { default: url, [string]: url },

	engines: { pesde: version, [string]: version },
	workspace_members: { glob },

	patches: { [string]: { [string]: path } },
	overrides: { [string]: dependency },

	dependencies: { [string]: dependency },
	dev_dependencies: { [string]: dependency },
	peer_dependencies: { [string]: dependency },
}

-- functions
local function get_scripts(root: string)
	local scripts = {}
	if not fs.isDir(root) then return end
	for _, name_ext in fs.readDir('scripts') do
		local name = string.match(name_ext, '(.-)%.luau?$')
		if not name then continue end
		if not fs.isFile(name) then continue end
		scripts[name] = `{root}/{name_ext}`
	end
end

-- module
local manifest: manifest = {
	scripts = get_scripts('scripts') or {},
	authors = {},

	includes = {},
	target = {
		build_files = {},
		scripts = {},
	},

	wally_indices = {} :: any,
	indices = {} :: any,

	engines = { pesde = '' },
	workspace_members = {},
	place = {},

	patches = {},
	overrides = {},

	dependencies = {},
	dev_dependencies = {},
	peer_dependencies = {},
}
merge(manifest, file.read_toml('pesde.toml') or {})

-- end
return manifest
