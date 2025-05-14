local create = require('@lib/init')
local inquisitor = require('@cli/inquisitor')
local project = require('@lib/project')

-- module
local function inquire()
	local result = {}
	local q = inquisitor(result)

	q.enum {
		name = 'toolchain_manager',
		{ name = 'none' },
		{ name = 'pesde' },
		{ name = 'rokit' },
		{ name = 'aftman' },
		{ name = 'foreman' },
		{ name = 'npm' },
	}
	result.package_managers = if result.toolchain_manager == 'pesde'
		then { 'pesde' }
		else q.multiselect {
			name = 'package_manager',
			{ name = 'pesde' },
			{ name = 'npm' },
			if project.project.environment == 'roblox' then { name = 'wally' } else nil :: any,
		}

	q.multiselect { name = 'code_editors', { name = 'vsc' }, { name = 'zed' }, { name = 'nvim' } }
	q.enum { name = 'version_tracker', { name = 'none' }, { name = 'git' } }

	q.multiselect {
		name = 'luau_tools',
		{ name = 'lsp' },
		{ name = 'stylua' },
		{ name = 'selene' },
		if create.tools.darklua then { name = 'darklua' } else nil :: any,
	}

	if project.project.environment == 'roblox' then
		q.enum {
			name = 'roblox_syncer',
			optional = true,
			{ name = 'rojo' },
			if create.tools.argon then { name = 'argon' } else nil :: any,
		}
		q.enum {
			name = 'cloud_sync',
			optional = true,
			{ name = 'none' },
			{ name = 'asphalt' },
			if project.project.kind == 'game' and create.tools.mantle then { name = 'mantle' } else nil :: any,
		}
		if project.project.kind == 'game' then
			q.enum {
				name = 'remote_idl',
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
