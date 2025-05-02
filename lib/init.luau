local package_manager = require('@lib/package_manager')
local editor = require('@lib/editor')
local git = require('@lib/git')
local lsp = require('@lib/lsp')

-- functions
local function save()
    package_manager.save()
    editor.save()
    git.save()
    lsp.save()
end

-- module
return table.freeze {
    save = save,
    pesde = require("./package_manager/pesde"),
    project = require("./project")
}