local args = require('@utils/args')
local create = require('@lib/init')
local inquire_project = require('@cli/inquires/project')
local inquire_tools = require('@cli/inquires/tools')

for _, tool_name in ipairs(args) do
	local tool = create.tools[tool_name]
	assert(not tool_name or tool, `invalid tool '{tool_name}'`)

	tool.setup()
end

if not args[1] then
	inquire_project()
	inquire_tools()

	create.language.setup()
	create.editor.setup()
end
create.save()
