local fs = require('@lune/fs')
local process = require('@lune/process')

local test_dirs = {
	['luau-pkg'] = { '--environment luau', '--kind package', '--description test', '--license none', '--yes' },
}

for dir, args in test_dirs do
	fs.writeDir(`test/{dir}`)
	local output = process.create(
		'pwsh',
		{ '-c', `"start pwsh '-c lune run ../../cli {table.concat(args :: any, ' ')} | pause'"` },
		{ cwd = `./test/{dir}`, shell = true }
	)

	local err = output.stderr:readToEnd()
	assert(err == '', err)

	local result = output.stdout:readToEnd()
	print(result)
end
