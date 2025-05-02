local editor = require('@lib/editor')
local lsp = require('@lib/lsp')
local git = require('@lib/git')

local serde = require("@lune/serde")
local fs = require("@lune/fs")

local merge = require('@lib/merge')

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
local manifest = merge(if fs.isFile('pesde.toml') then serde.decode('toml', fs.readFile('pesde.toml')) else {}, {
    includes = {},
    engine = {},
    target = {
        scripts = {}
    },
    authors = {},
    scripts = get_scripts('scripts') or {},
    dependencies = {},
    dev_dependencies = {},
})

-- functions
local function save()
    fs.writeFile('pesde.toml', serde.encode('toml', manifest, true))
end

local enabled = false
local function setup()
    if enabled then return end
    enabled = true

    editor.hide_globs('*_packages/**', '.pesde')
    editor.lock_globs('*_packages/**', '.pesde')
    git.ignore_globs('*_packages/**', '.pesde')
    lsp.ignore_import_globs('**/.pesde/**')
    lsp.ignore_diagnostic_globs('*_packages/**', '.pesde')
end

-- module
return table.freeze {
    save = save,
    setup = setup,
    manifest = manifest,
}
