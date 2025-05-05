local merge = require('@utils/merge')
local file = require('@lib/file')

-- defs
export type manifest = { [string]: any }

-- module
local manifest: manifest = {
    directories = {}
}
merge(manifest, file.read_json('package.json') or {})

-- end
return manifest