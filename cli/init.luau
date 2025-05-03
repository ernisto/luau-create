local inquire_project = require('@cli/project/inquire')
local process = require('@lune/process')
local create = require('@lib/init')

local pesde = require('@tools/pesde/setup')
local project = require('@lib/project')
local lsp = require("@tools/lsp")

local tool_name = process.args[1]
local tool = create.tools[tool_name]
assert(not tool_name or tool, `invalid tool '{tool_name}'`)

if not tool_name then

    inquire_project()

    project.setup()
    pesde.setup()
    lsp.setup()
else
    tool.setup()
end

create.save()
