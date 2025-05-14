local args = require('@cli/args')
local fs = require('@lune/fs')
local process = require('@lune/process')

local test_dirs = {
	['luau-pkg'] = { environment = 'luau', kind = 'package', description = 'test', license = 'none' },
	['lune-pkg'] = { environment = 'lune', kind = 'package', description = 'test', license = 'none' },
	['roblox-pkg'] = { environment = 'roblox', kind = 'package', description = 'test', license = 'none' },
	['roblox-plugin'] = { environment = 'roblox', kind = 'plugin', description = 'test', license = 'none' },
	['roblox-game'] = { environment = 'roblox', kind = 'game', description = 'test', license = 'none' },
	['roblox-server-pkg'] = {
		environment = 'roblox',
		kind = 'package',
		side = 'server',
		description = 'test',
		license = 'none',
	},
}

for dir, test_args in test_dirs do
	fs.writeDir(`test/{dir}`)
	local output = process.create(
		'lune',
		{ 'run', '../../cli', '--yes', unpack(args.split(test_args :: any)) },
		{ cwd = `./test/{dir}` }
	)

	local result = output.stdout:readToEnd()
	print(result)

	local err = output.stderr:readToEnd()
	assert(err == '', err)
end
