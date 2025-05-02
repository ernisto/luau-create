local process = require('@lune/process')
local pesde = require("@lib/project/pesde")
local create = require('@lib/init')
local lsp = require("@lib/lsp")

local tool_name = process.args[1]
local tool = create[tool_name or 'project']
assert(tool, `invalid tool '{tool_name}'`)

tool.setup()
if not tool_name then
    pesde.setup()
    lsp.setup()
end

create.save()
