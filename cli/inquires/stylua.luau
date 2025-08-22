local inquisitor = require('@cli/inquisitor')
local stylua = require('@tools/stylua')

-- module
local function inquire()
	local q_stylua = inquisitor(stylua.manifest)

	q_stylua.enum {
		name = 'syntax',
		optional = true,
		default_index = 2,
		{ name = 'All' },
		{ name = 'Luau' },
		{ message = 'Cfx Lua', value = 'CfxLua' },
		{ message = 'Lua Jit', value = 'LuaJIT' },
		{ message = 'Lua 5.1', value = 'Lua51' },
		{ message = 'Lua 5.2', value = 'Lua52' },
		{ message = 'Lua 5.3', value = 'Lua53' },
		{ message = 'Lua 5.4', value = 'Lua54' },
	}
	q_stylua.int { name = 'column_width', default = 120, optional = true }
	q_stylua.enum {
		name = 'line_endings',
		default_index = 1,
		optional = true,
		{ name = 'Unix' },
		{ name = 'Windows' },
	}
	q_stylua.enum {
		name = 'indent_type',
		optional = true,
		default_index = 1,
		{ name = 'Tabs' },
		{ name = 'Space' },
	}
	q_stylua.int { name = 'indent_width', default = 4, optional = true }
	q_stylua.enum {
		name = 'quote_style',
		optional = true,
		default_index = 1,
		{ name = 'AutoPreferDouble' },
		{ name = 'AutoPreferSingle' },
		{ name = 'ForceDouble' },
		{ name = 'ForceSingle' },
	}
	q_stylua.enum {
		name = 'call_parentheses',
		default_index = 1,
		optional = true,
		{ name = 'Always' },
		{ name = 'NoSingleString' },
		{ name = 'NoSingleTable' },
		{ name = 'None' },
		{ name = 'Input' },
	}
	q_stylua.enum {
		name = 'space_after_function_names',
		default_index = 1,
		optional = true,
		{ name = 'Never' },
		{ name = 'Definitions' },
		{ name = 'Calls' },
		{ name = 'Always' },
	}
	q_stylua.enum {
		name = 'collapse_simple_statement',
		default_index = 1,
		optional = true,
		{ name = 'Never' },
		{ name = 'FunctionOnly' },
		{ name = 'Conditionaly' },
		{ name = 'Always' },
	}
	local value = q_stylua.bool { name = 'sort_requires', optional = true }
	stylua.manifest.sort_requires = { enabled = value }
end

return inquire
