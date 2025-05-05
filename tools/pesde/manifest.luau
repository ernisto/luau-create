local file = require("@lib/file")
local fs = require("@lune/fs")
local merge = require("@utils/merge")

-- defs
export type manifest = { [string]: any }

-- functions
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

-- module
local manifest: manifest = {
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
merge(manifest, file.read_toml('pesde.toml') or {})

-- end
return manifest