local package_manager = require('@lib/packages')
local project = require("@lib/project")
local editor = require('@lib/editor')
local tools = table.freeze {

    -- environment
    roblox = require('@tools/roblox'),
    rojo = require('@tools/rojo'),

    -- package
    pesde = require('@tools/pesde'),
    wally = require('@tools/wally'),
    npm = require('@tools/npm'),

    -- language
    luau = require('@tools/luau'),
    lsp = require('@tools/lsp'),

    -- editor
    github = require('@tools/github'),
    git = require('@tools/git'),
    vsc = require('@tools/vsc'),
}


-- functions
local function save()
    for _,tool: any in tools do tool.save() end
end

-- module
return table.freeze {
    save = save,
    project = project,
    package_manager = package_manager,
    editor = editor,
    tools = tools
}