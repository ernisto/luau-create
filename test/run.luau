local args = require('@cli/args')
local fs = require('@lune/fs')
local process = require('@lune/process')
local stdio = require('@lune/stdio')

local test_dirs = {
	['luau-pkg'] = { environment = 'luau', kind = 'package' },
	['lune-pkg'] = { environment = 'lune', kind = 'package' },
	['lune-bin'] = { environment = 'lune', kind = 'cli' },
	['lune-script'] = { environment = 'lune', kind = 'script' },
	['roblox-pkg'] = { environment = 'roblox', kind = 'package' },
	['roblox-plugin'] = { environment = 'roblox', kind = 'plugin' },
	['roblox-game'] = { environment = 'roblox', kind = 'game' },
	['roblox-server-pkg'] = { environment = 'roblox', kind = 'package', side = 'server' },
}

for dir, test_args in test_dirs do
	fs.writeDir(`test/{dir}`)
	local output = process.create('lune', {
		'run',
		'../../cli',
		'--yes',
		'--description',
		'test',
		'--license',
		'MIT',
		unpack(args.split(test_args :: any)),
	}, { cwd = `./test/{dir}` })

	local result = output.stdout:readToEnd()
	stdio.write(result)

	local err = output.stderr:readToEnd()
	assert(err == '', err)
end
