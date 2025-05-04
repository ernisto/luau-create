local language = require('@lib/language')
local tracker = require('@lib/tracker')
local editor = require('@lib/editor')
local file = require("@lib/file")

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
local manifest: { [string]: any } = {
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
merge(manifest, file.read_toml('pesde.toml'))

-- functions
local function save()
    fs.writeFile('pesde.toml', serde.encode('toml', manifest, true))
end

local function setup()
    editor.hide_globs('*_packages/**', '.pesde', 'pesde.toml')
    editor.lock_globs('*_packages/**', '.pesde')
    tracker.ignore_globs('*_packages/**', '.pesde')
    language.ignore_import_globs('**/.pesde/**')
    language.ignore_diagnostic_globs('*_packages/**', '.pesde')
end

-- module
return table.freeze {
    save = save,
    setup = setup,
    manifest = manifest,
}
