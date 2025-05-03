local tracker = require('@lib/tracker')
local editor = require('@lib/editor')
local luau = require('@lib/luau')

local serde = require("@lune/serde")
local fs = require("@lune/fs")

local merge = require('@utils/merge')

-- utils
local function get_scripts(root: string)
    local scripts = {}
    if not fs.isDir(root) then return end
    for _,name_ext in fs.readDir('scripts') do
        local name = string.match(name_ext, "(.-)%.luau?$")
        if not name then continue end
        if not fs.isFile(name) then continue end
        scripts[name] = `{root}/{name_ext}`
    end
end

-- vars
local default = {
    includes = {},
    engine = {},
    target = {
        scripts = {}
    },
    authors = {},
    scripts = get_scripts('scripts') or {},
    dependencies = {},
    dev_dependencies = {},
}
local manifest = merge(default, if fs.isFile('pesde.toml') then serde.decode('toml', fs.readFile('pesde.toml')) else {})

-- functions
local function save()
    fs.writeFile('pesde.toml', serde.encode('toml', manifest, true))
end

local function setup()
    editor.hide_globs('*_packages/**', '.pesde')
    editor.lock_globs('*_packages/**', '.pesde')
    tracker.ignore_globs('*_packages/**', '.pesde')
    luau.ignore_import_globs('**/.pesde/**')
    luau.ignore_diagnostic_globs('*_packages/**', '.pesde')
end

-- module
return table.freeze {
    save = save,
    setup = setup,
    manifest = manifest,
}
