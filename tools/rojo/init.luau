local tracker = require('@lib/tracker')
local project = require('@lib/project')
local editor = require('@lib/editor')
local file = require('@lib/file')

local merge = require('@utils/merge')
local vsc = require('@tools/vsc')
local dom = require('./dom')

-- vars
local tree = dom.node('DataModel')
merge({ tree = tree }, file.read_json('dev.project.json'))

local places = {}
local synced_paths = {}

-- functions
local function save()
    file.write_json('dev.project.json', { name = project.project.name, tree = tree })
end

local function add_system_path(system_path: string, roblox_path: {string}, place: string?)

    local tree = places[place] or tree
    local node = dom.get_node(tree, roblox_path)

    local joined_path = table.concat(roblox_path, '.')
    if node['$path'] ~= system_path then
        warn(`roblox path ({joined_path}) already is being synced by {node['$path']}`)
    end
    node['$path'] = system_path
    synced_paths[system_path] = joined_path
end
local function set_properties(roblox_path: {string}, properties: { [string]: any })
    merge(dom.get_node(tree, roblox_path)['$properties'], properties)
end

local function setup()
    tracker.ignore_globs('sourcemap.json', 'dist/**')
    editor.hide_globs('sourcemap.json', 'dist/**')
    editor.lock_globs('sourcemap.json', 'dist/**')
    vsc.recommend_extensions('evaera.vscode-rojo')

    if project.project.kind == 'game' then
        file.write_str('test/init.luau', '')
        file.write_str('story/print.story.luau', '')
        file.write_str('server/init.server.luau', '')
        file.write_str('client/init.client.luau', '')
        file.write_str('config/init.toml', '')
        file.write_str('shared/.gitkeep', '')
    end
end

-- module
return table.freeze {
    places = places,
    tree = tree,
    dom = dom,

    save = save,
    setup = setup,
    set_properties = set_properties,
    add_system_path = add_system_path,
}
