local project = require('@lib/project').project
local editor = require('@lib/editor')
local file = require('@lib/file')
local toolchain = require('@lib/toolchain')
local tracker = require('@lib/tracker')

local dom = require('@self/dom')
local github_release = require('@utils/github/release')
local merge = require('@utils/merge')

local pesde = require('@tools/pesde')
local vsc = require('@tools/vsc')
local wally = require('@tools/wally')

-- vars
local sup = false

local places = {}
local synced_paths = {}
local tree = dom.node('DataModel')
merge({ tree = tree }, file.read_json('dev.project.json'))

-- functions
local function save()
	if not sup then return end
	file.write_json('dev.project.json', { name = project.name, tree = tree })
end

local function add_system_path(system_path: string, roblox_path: { string }, place: string?)
	local tree = places[place] or tree
	local node = dom.get_node(tree, roblox_path)

	local joined_path = table.concat(roblox_path, '.')
	if node['$path'] and node['$path'] ~= system_path then
		warn(`roblox path ({joined_path}) already is being synced by {node['$path']}`)
	end
	node['$path'] = system_path
	synced_paths[system_path] = joined_path
end
local function set_properties(roblox_path: { string }, properties: { [string]: any })
	merge(dom.get_node(tree, roblox_path)['$properties'], properties)
end

local function setup(input_version: string?)
	if sup then return end
	sup = true

	local version = input_version
		or github_release.get_latest_version('rojo-rbx', 'rojo')
		or error("couldn't find latest version for rojo")
	toolchain.install_github('rojo-rbx', 'rojo', version)
	toolchain.install_pesde('pesde', 'rojo', version)

	pesde.manifest.scripts.roblox_sync_config_generator = '.pesde/scripts/roblox_sync_config_generator.luau'
	pesde.manifest.scripts.sourcemap_generator = '.pesde/scripts/sourcemap_generator.luau'

	pesde.manifest.place = {
		server = 'game.ServerScriptService.packages',
		shared = 'game.ReplicatedStorage.packages',
	}
	wally.manifest.place = {
		server = 'game.ServerScriptService.packages',
		shared = 'game.ReplicatedStorage.packages',
	}

	add_system_path('roblox_packages', { 'ReplicatedStorage', 'packages' })
	add_system_path('roblox_server_packages', { 'ServerScriptService', 'packages' })

	tracker.ignore_globs('sourcemap.json', '**/dist/**')
	editor.hide_globs('sourcemap.json', '**/dist/**')
	editor.lock_globs('sourcemap.json', '**/dist/**')
	vsc.recommend_extensions('evaera.vscode-rojo')

	merge(vsc.settings, {
		['luau-lsp.sourcemap.rojoProjectFile'] = 'dev.project.json',
		['luau-lsp.diagnostics.strictDatamodelTypes'] = true,
		['luau-lsp.sourcemap.includeNonScripts'] = true,
		['luau-lsp.diagnostics.workspace'] = true,
	})

	if project.kind == 'game' then
		file.write_default_str('server/init.server.luau')
		file.write_default_str('client/init.client.luau')
		file.write_default_str('config/init.toml')
		file.write_default_str('shared/.gitkeep')

		add_system_path('server', { 'ServerScriptService', 'server' })
		add_system_path('client', { 'ReplicatedStorage', 'client' })
		add_system_path('config', { 'ReplicatedStorage', 'config' })
		add_system_path('shared', { 'ReplicatedStorage', 'shared' })
	elseif project.kind == 'package' then
		add_system_path(assert(project.entrypoint), { 'ReplicatedStorage', 'packages', project.name })
	elseif project.kind == 'plugin' then
		add_system_path(assert(project.entrypoint), { 'ServerStorage', project.name })
	end
end

-- module
return table.freeze {
	places = places,
	tree = tree,
	dom = dom,

	save = save,
	setup = setup,
	set_properties = set_properties,
	add_system_path = add_system_path,
}
