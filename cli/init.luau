local inquire_project = require('@cli/project/inquire')
local process = require('@lune/process')
local create = require('@lib/init')

local tool_name = process.args[1]
local tool = create.tools[tool_name]
assert(not tool_name or tool, `invalid tool '{tool_name}'`)

if not tool_name then
    inquire_project()

    for _,s_tool: any in create.tools do s_tool.setup() end
    create.language.setup()
    create.editor.setup()
    create.project.setup()
else

    tool.setup()
end
create.save()
