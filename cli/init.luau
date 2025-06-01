local args = require('@cli/args')
local create = require('@lib/init')
local inquire_project = require('@cli/inquires/project')
local inquire_tools = require('@cli/inquires/tools')

for _, tool_name in ipairs(args.current) do
	local tool = create.tools[tool_name]
	assert(not tool_name or tool, `invalid tool '{tool_name}'`)

	tool.setup()
end

if not args.current[1] then
	inquire_project()
	local tools = inquire_tools()
	for _, tool in tools do
		for _, tool in (if type(tool) == 'table' then tool else { tool }) do
			if create.tools[tool] then
				create.tools[tool].setup()
			else
				warn(`unknown tool '{tool}'`)
			end
		end
	end

	create.editor.setup()
end
create.save()
