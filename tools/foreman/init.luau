local editor = require('@lib/editor')
local merge = require('@utils/merge')
local file = require('@lib/file')
local vsc = require('@tools/vsc')

-- vars
local sup = false
local tools = {}
merge({ tools = tools }, file.read_toml('foreman.toml') or {})

-- functions
local function save()
    if not sup then return end
    file.write_toml('foreman.toml', { tools = tools })
end

local function install_github(scope: string, name: string, version: string)
    tools[name] = { github = `{scope}/{name}`, version = version }
end

local function setup()
    if sup then return end
    sup = true

    vsc.recommend_extensions('filiptibell.tooling-language-server')
    editor.hide_globs('foreman.toml')
end

-- module
return table.freeze {
    save = save,
    setup = setup,
    tools = tools,
    install_github = install_github,
}