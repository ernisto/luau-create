local file = require('@lib/file')
local merge = require('@utils/merge')

-- defs
export type manifest = { [string]: any }

-- vars
local manifest: manifest = {
    package = {
        exclude = {},
        authors = {},
        dependencies = {},
    },
    ['dev-dependencies'] = {},
    ['server-dependencies'] = {},
}
merge(manifest, file.read_toml('wally.toml') or {})

-- end
return manifest
