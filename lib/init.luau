local package_manager = require('@lib/packages')
local roblox_sync = require('@lib/roblox_sync')
local project = require("@lib/project")
local editor = require('@lib/editor')

local github = require('@tools/github')
local pesde = require("@tools/pesde")
local rojo = require('@tools/rojo')
local luau = require('@tools/luau')
local git = require('@tools/git')
local vsc = require('@tools/vsc')
local lsp = require('@tools/lsp')

-- functions
local function save()
    github.save()
    pesde.save()
    rojo.save()
    luau.save()
    git.save()
    vsc.save()
    lsp.save()
end

-- module
return table.freeze {
    save = save,
    project = project,
    package_manager = package_manager,
    roblox_sync = roblox_sync,
    editor = editor,
    tools = {
        github = github,
        pesde = pesde,
        rojo = rojo,
        luau = luau,
        git = git,
        vsc = vsc,
        lsp = lsp,
    }
}