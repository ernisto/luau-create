local editor = require('@lib/editor')
local project = require('@lib/project')
local tracker = require('@lib/tracker')

local merge = require('@utils/merge')
local rojo = require('@tools/rojo')
local vsc = require('@tools/vsc')

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

	tracker.set_attribute('*.rbxm', 'binary')
	tracker.set_attribute('*.rbxl', 'binary')
	tracker.ignore_globs('*.rbxl')
	editor.hide_globs('.rbxl')

	merge(vsc.settings, {
		['luau-lsp.platform.type'] = 'roblox',
		['luau-lsp.bytecode.vectorCtor'] = 'new',
		['luau-lsp.bytecode.vectorLib'] = 'Vector3',
		['luau-lsp.bytecode.vectorType'] = 'Vector3',

		['luau-lsp.completion.imports.stringRequires.enabled'] = project.project.kind ~= 'game',
		['luau-lsp.completion.imports.requireStyle'] = if project.project.kind == 'game'
			then 'alwaysAbsolute'
			else 'alwaysRelative',
		['luau-lsp.types.robloxSecurityLevel'] = if project.project.kind == 'plugin'
			then 'PluginSecurity'
			else 'LocalUserSecurity',
	})
end

-- module
return table.freeze {
	save = save,
	setup = setup,
	add_system_path = add_system_path,
}
