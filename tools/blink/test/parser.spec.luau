local display = require('./display')
local fs = require('@lune/fs')
local parser = require('../parser')

local code = fs.readFile('tools/blink/test/battery.blink')
local ast = parser.parse(code)

-- abstract syntax tree
print(display(ast))
