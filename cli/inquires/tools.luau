local create = require('@lib')
local inquire_stylua = require('@cli/inquires/stylua')
local inquisitor = require('@cli/inquisitor')
local mantle = require('@tools/mantle')
local project = require('@lib/project')
local rojo = require('@tools/rojo')

-- module
local function inquire()
	local result = { environment = project.project.environment, language = 'luau' }
	local q = inquisitor(result)

	q.enum {
		name = 'toolchain_manager',
		default_index = 2,
		optional = true,
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

	q.enum { name = 'version_tracker', default_index = 1, optional = true, { name = 'git' } }
	result.github = q.bool { message = 'setup github ?', default = true } and 'github'

	q.multiselect {
		name = 'code_editors',
		default_indexes = { 1 },
		{ name = 'vsc' },
		{ name = 'zed' },
		{ name = 'nvim' },
	}

	local tools = q.multiselect {
		name = 'luau_tools',
		default_indexes = { 1, 2 },
		{ name = 'lsp' },
		{ name = 'stylua' },
		{ name = 'selene' },
		if create.tools.darklua then { name = 'darklua' } else nil :: any,
	}
	if table.find(tools, 'stylua') then inquire_stylua() end

	if project.project.environment == 'roblox' then
		q.enum {
			name = 'roblox_syncer',
			default_index = 1,
			optional = true,
			{ name = 'rojo' },
			if create.tools.argon then { name = 'argon' } else nil :: any,
		}
		local cloud_sync = q.multiselect {
			name = 'cloud_sync',
			default_indexes = { 1, 2 },
			{ name = 'asphalt' },
			if project.project.kind == 'game' then { name = 'mantle' } else nil :: any,
		}
		if project.project.kind == 'game' then
			q.enum {
				name = 'remote_idl',
				default_index = 1,
				optional = true,
				{ name = 'blink' },
				if create.tools.zap then { 'zap' } else nil :: any,
			}
			if table.find(cloud_sync, 'mantle') then
				mantle.preferences.output_generator = q.bool {
					message = 'read output from roblox ?',
					default = true,
				}
			end
			rojo.preferences.manage_assets = q.bool {
				message = 'manage assets with rojo ?',
				default = true,
			}
		end
	end
	return result
end

return inquire
