local package_manager = require('@lib/packages')
local project = require("@lib/project")
local editor = require('@lib/editor')

local pesde = require("@tools/pesde")
local git = require('@tools/git')
local vsc = require('@tools/vsc')
local lsp = require('@tools/lsp')

-- functions
local function save()
    pesde.save()
    git.save()
    vsc.save()
    lsp.save()
end

-- module
return table.freeze {
    save = save,
    project = project,
    package_manager = package_manager,
    editor = editor,
    tools = {
        pesde = pesde,
        git = git,
        vsc = vsc,
        lsp = lsp,
    }
}