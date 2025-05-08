local fs = require("@lune/fs")
local display = require("./display")
local parser = require("../parser")

local code = fs.readFile('tools/blink/test/merge.blink')
local ast = parser.parse(code)

-- abstract syntax tree
print(display(ast, {}))