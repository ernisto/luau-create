local create = require('@lib/init')
local project = require('@lib/project')
local stdio = require('@lune/stdio')

local function inquire()
	local toolchain_manager =
		stdio.prompt('select', 'toolchain manager', { 'none', 'pesde', 'rokit', 'aftman', 'foreman', 'npm' })
	local package_managers = if toolchain_manager == 2
		then { 2 }
		else stdio.prompt(
			'multiselect',
			'package manager',
			{ 'pesde', 'npm', project.project.environment == 'roblox' and 'wally' or nil :: any }
		)

	local editors = stdio.prompt('multiselect', 'code editors', { 'vsc', 'zed', 'nvim' })
	local trackers = stdio.prompt('select', 'version tracker', { 'none', 'git' })

	local language_tools = stdio.prompt(
		'multiselect',
		'luau tools',
		{ 'lsp', 'stylua', 'selene', create.tools.darklua and 'darklua' :: any }
	)

	local roblox_sync, remote_lib, cloud_sync
	if project.project.environment == 'roblox' then
		roblox_sync = stdio.prompt('select', 'roblox syncer', { 'rojo', create.tools.argon and 'argon' :: any })

		remote_lib = project.project.kind == 'game'
			and stdio.prompt('select', 'remote IDL', { 'none', 'blink', create.tools.zap and 'zap' :: any })

		cloud_sync = stdio.prompt(
			'select',
			'cloud sync',
			{ 'none', 'asphalt', project.project.kind == 'game' and create.tools.mantle and 'mantle' :: any }
		)
	end

	return {
		toolchain_manager = toolchain_manager,
		package_managers = package_managers,
		editors = editors,
		trackers = trackers,
		language_tools = language_tools,
		roblox_sync = roblox_sync,
		remote_lib = remote_lib,
		cloud_sync = cloud_sync,
	}
end

return inquire
