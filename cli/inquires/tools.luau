local create = require('@lib/init')
local inquisitor = require('@cli/inquisitor')
local project = require('@lib/project')

-- module
local function inquire()
	local result = {}
	local q = inquisitor(result)

	q.enum {
		name = 'toolchain_manager',
		default_index = 2,
		{ name = 'none' },
		{ name = 'pesde' },
		{ name = 'rokit' },
		{ name = 'aftman' },
		{ name = 'foreman' },
		{ name = 'npm' },
	}
	q.multiselect {
		name = 'package_manager',
		default_indexes = { 1 },
		{ name = 'pesde' },
		{ name = 'npm' },
		if project.project.environment == 'roblox' then { name = 'wally' } else nil :: any,
	}

	q.enum { name = 'version_tracker', default_index = 2, { name = 'none' }, { name = 'git' } }
	q.multiselect {
		name = 'code_editors',
		default_indexes = { 1 },
		{ name = 'vsc' },
		{ name = 'zed' },
		{ name = 'nvim' },
	}

	q.multiselect {
		name = 'luau_tools',
		default_indexes = { 1, 2 },
		{ name = 'lsp' },
		{ name = 'stylua' },
		{ name = 'selene' },
		if create.tools.darklua then { name = 'darklua' } else nil :: any,
	}

	if project.project.environment == 'roblox' then
		q.enum {
			name = 'roblox_syncer',
			default_index = 1,
			optional = true,
			{ name = 'rojo' },
			if create.tools.argon then { name = 'argon' } else nil :: any,
		}
		q.enum {
			name = 'cloud_sync',
			default_index = 2,
			optional = true,
			{ name = 'none' },
			{ name = 'asphalt' },
			if project.project.kind == 'game' and create.tools.mantle then { name = 'mantle' } else nil :: any,
		}
		if project.project.kind == 'game' then
			q.enum {
				name = 'remote_idl',
				default_index = 2,
				optional = true,
				{ name = 'none' },
				{ name = 'blink' },
				if create.tools.zap then { 'zap' } else nil :: any,
			}
		end
	end
	return result
end

return inquire
