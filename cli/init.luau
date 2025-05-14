local create = require('@lib/init')
local inquire_project = require('@cli/inquires/project')
local process = require('@lune/process')
local stdio = require('@lune/stdio')

local tool_name = process.args[1]
local tool = create.tools[tool_name]
assert(not tool_name or tool, `invalid tool '{tool_name}'`)

if not tool_name then
	inquire_project()
	local tools = {}
	for name in create.tools do
		table.insert(tools, name)
	end

	local selected = stdio.prompt('multiselect', 'Tools to setup', tools)
	for _, index in selected do
		local _tool = create.tools[tools[index]]
		_tool.setup()
	end
	create.language.setup()
	create.editor.setup()
else
	tool.setup()
end
create.save()
