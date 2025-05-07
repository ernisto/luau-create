local editor = require("@lib/editor")
local merge = require('@utils/merge')
local file = require('@lib/file')
local toolchain = require("@lib/toolchain")

local version = '1.0.0-rc.8'

-- vars
local sup = false
local manifest = {}
merge(manifest, file.read_toml('asphalt.toml') or {})

-- functions
local function save()
    if not sup then return end
    file.write_toml('asphalt.toml', manifest)
end
local function setup()
    if sup then return end
    sup = true

    toolchain.install_github('jacktabscode', 'asphalt', version)
    toolchain.install_pesde('pesde', 'asphalt', version)

    file.ensure_existing_chain('assets')
    editor.hide_globs('asphalt.toml')
end

-- module
return table.freeze {
    save = save,
    setup = setup,
    manifest = manifest,
}