local fs = require('@lune/fs')
local process = require('@lune/process')

fs.writeDir('test/luau-pkg')
local r = process.create(
    'pwsh',
    {'-c', "\"start pwsh '-c lune run ../../cli --host ernisto | pause'\""},
    { cwd = './test/luau-pkg', shell = true }
)