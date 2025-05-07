local tracker = require('@lib/tracker')
local file = require('@lib/file')
local merge = require('@utils/merge')

local rojo = require('@tools/rojo')
local vsc = require('@tools/vsc')

-- vars
local sup = false
local manifest = {}
-- merge(manifest, file.read_str('remotes/init.blink'))

-- functions
local function save()
    if not sup then return end
end
local function setup()
    if sup then return end
    sup = true

    vsc.settings["files.associations"]["*.blink"] = "blink"
    vsc.recommend_extensions('checkraisefold.blink-vscode')
    vsc.hide_globs('dist/**')
    vsc.lock_globs('dist/**')
    tracker.ignore_globs('dist/**')

    file.write_default_str('remotes/init.blink')
    rojo.add_system_path('dist/blink/client', {'ReplicatedStorage', 'client', 'remotes' })
    rojo.add_system_path('dist/blink/server', {'ReplicatedStorage', 'server', 'remotes' })
    rojo.add_system_path('dist/blink/types', {'ReplicatedStorage', 'types' })
end

-- module
return table.freeze {
    save = save,
    setup = setup,
}