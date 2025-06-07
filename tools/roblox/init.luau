local project = require('@lib/project').project
local editor = require('@lib/editor')
local file = require('@lib/file')
local tracker = require('@lib/tracker')

local lsp = require('@tools/lsp')
local luau = require('@tools/luau')
local merge = require('@utils/merge')
local pesde = require('@tools/pesde')
local rojo = require('@tools/rojo')
local vsc = require('@tools/vsc')
local wally = require('@tools/wally')

-- vars
local sup = false

-- functions
local function save()
	if not sup then return end
end

local function add_system_path(system_path: string, roblox_path: { string })
	rojo.add_system_path(system_path, roblox_path)
end

local function setup()
	if sup then return end
	sup = true

	luau.setup()
	lsp.setup()

	tracker.set_attribute('*.rbxm', 'binary')
	tracker.set_attribute('*.rbxl', 'binary')
	tracker.ignore_globs('*.rbxl.lock')
	tracker.ignore_globs('*.rbxl')
	editor.hide_globs('.rbxl')

	merge(vsc.settings, {
		['luau-lsp.platform.type'] = 'roblox',
		['luau-lsp.bytecode.vectorCtor'] = 'new',
		['luau-lsp.bytecode.vectorLib'] = 'Vector3',
		['luau-lsp.bytecode.vectorType'] = 'Vector3',

		['luau-lsp.completion.imports.stringRequires.enabled'] = project.kind ~= 'game',
		['luau-lsp.completion.imports.requireStyle'] = if project.kind == 'game'
			then 'alwaysAbsolute'
			else 'alwaysRelative',
		['luau-lsp.types.robloxSecurityLevel'] = if project.side == 'plugin'
			then 'PluginSecurity'
			else 'LocalUserSecurity',
	})

	if pesde.sup() then
		add_system_path('roblox_packages', { 'ReplicatedStorage', 'packages' })
		add_system_path('roblox_server_packages', { 'ServerScriptService', 'packages' })
	end
	if wally.sup() then
		add_system_path('Packages', { 'ReplicatedStorage', 'packages' })
		add_system_path('DevPackages', { 'ServerStorage', 'packages' })
		add_system_path('ServerPackages', { 'ServerScriptService', 'packages' })
	end

	if project.kind == 'game' then
		add_system_path('assets', { 'ReplicatedStorage', 'assets' })
		file.write_default_str('assets/models/.gitkeep')

		add_system_path('config', { 'ReplicatedStorage', 'config' })
		file.write_default_str('config/init.toml')

		add_system_path('shared', { 'ReplicatedStorage', 'shared' })
		file.write_default_str('shared/.gitkeep')

		add_system_path('client', { 'ReplicatedStorage', 'client' })
		file.write_default_str('client/init.client.luau')

		add_system_path('server', { 'ServerScriptService', 'server' })
		file.write_default_str('server/init.server.luau')
	elseif project.kind == 'package' then
		add_system_path(assert(project.entrypoint), { 'ReplicatedStorage', 'packages', project.name })
	elseif project.kind == 'plugin' then
		add_system_path(assert(project.entrypoint), { 'ServerStorage', project.name })
	end
end

-- module
return table.freeze {
	save = save,
	setup = setup,
	add_system_path = add_system_path,
}
