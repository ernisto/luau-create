local create = require('@lib/init')
local inquire_project = require('@cli/inquires/project')
local inquire_tools = require('@cli/inquires/tools')
local process = require('@lune/process')

local tool_name = process.args[1]
local tool = create.tools[tool_name]
assert(not tool_name or tool, `invalid tool '{tool_name}'`)

if not tool_name then
	inquire_project()
	inquire_tools()

	create.language.setup()
	create.editor.setup()
else
	tool.setup()
end
create.save()
