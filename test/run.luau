local fs = require('@lune/fs')
local process = require('@lune/process')
local task = require('@lune/task')

fs.writeDir('test/luau-pkg')
local r = process.create('lune', { 'run', '../../cli' }, { cwd = 'test/luau-pkg' })
task.wait(0.1)
print(r.stdout:readToEnd())
print(r.stderr:readToEnd())
