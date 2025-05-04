local merge = require('@utils/merge')
local file = require('@lib/file')

-- vars
local sup = false
local tasks = {}
local hidden_globs = {}
local locked_globs = {}
local recommended_extensions = {}
local settings = { ['files.readonlyInclude'] = locked_globs, ['files.exclude'] = hidden_globs, ['files.associations'] = {} }
merge({ recommendations = recommended_extensions }, file.read_json('.vscode/extensions.json'))
merge({ tasks = tasks }, file.read_json('.vscode/tasks.json'))
merge(settings, file.read_json('.vscode/settings.json'))

-- functions
local function save()
    if not sup then return end
    file.write_json('./.vscode/extensions.json', { recommendations = recommended_extensions })
    file.write_json('./.vscode/settings.json', settings)
    file.write_json('./.vscode/tasks.json', { version = "2.0.0", tasks = tasks })
end

type extension_id = string
local function recommend_extensions(...: extension_id)
    for _,extension_id in {...} do
        if table.find(recommended_extensions, extension_id) then continue end
        table.insert(recommended_extensions, extension_id)
    end
end

type glob = string
local function hide_globs(...: glob)
    for _,glob in {...} do
        hidden_globs[glob] = true
    end
end
local function lock_globs(...: glob)
    for _,glob in {...} do
        locked_globs[glob] = true
    end
end

local function setup()
    if sup then return end
    sup = true

    hide_globs('.vscode')
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
