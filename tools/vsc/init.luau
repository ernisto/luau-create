local serde = require('@lune/serde')
local fs = require('@lune/fs')

if not fs.isDir('./.vscode') then fs.writeDir('./.vscode') end
local recommended_extensions = if fs.isFile('./.vscode/extensions.json') then serde.decode('json', fs.readFile('./.vscode/extensions.json')) else {}
local settings = if fs.isFile('./.vscode/settings.json') then serde.decode('json', fs.readFile('./.vscode/settings.json')) else {}
local tasks = if fs.isFile('./.vscode/tasks.json') then serde.decode('json', fs.readFile('./.vscode/tasks.json')) else {}

local locked_globs = settings['file.readonlyInclude'] or {}
local hidden_globs = settings['file.exclude'] or {}

-- defs
type extension_id = string
type glob = string

-- functions
local function save()
    fs.writeFile('./.vscode/extensions.json', serde.encode('json', recommended_extensions, true))
    fs.writeFile('./.vscode/settings.json', serde.encode('json', settings, true))
    fs.writeFile('./.vscode/tasks.json', serde.encode('json', tasks, true))
end

local function recommend_extensions(...: extension_id)
    for _,extension_id in {...} do
        if table.find(recommended_extensions, extension_id) then continue end
        table.insert(recommended_extensions, extension_id)
    end
end
local function hide_globs(...: glob)
    for _,glob in {...} do
        if table.find(hidden_globs, glob) then continue end
        table.insert(hidden_globs, glob)
    end
end
local function lock_globs(...: glob)
    for _,glob in {...} do
        if table.find(locked_globs, glob) then continue end
        table.insert(locked_globs, glob)
    end
end

local function setup()
    hide_globs(".vscode")
end

-- module
return table.freeze {
    save = save,
    setup = setup,
    settings = settings,

    hide_globs = hide_globs,
    lock_globs = lock_globs,
    recommend_extensions = recommend_extensions,
}
