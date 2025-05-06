local file = require('@lib/file')
local merge = require('@utils/merge')
local license = require('@lib/project/licenses')

-- defs
export type manifest = { 
    package: {
        name: string?,
        description: string?,
        version: version?,

        license: license.license?,
        authors: {author},

        realm: 'server' | 'shared'?,
        registry: url?,
        
        private: boolean?,
        repository: url?,
        homepage: url?,
        
        exclude: {glob},
        include: {glob},
    },
    exclude: {glob},
    include: {glob},
    place: { server: roblox_path?, shared: roblox_path? },
    ['dependencies']: {[string]: string},
    ['dev-dependencies']: {[string]: string},
    ['server-dependencies']: {[string]: string},
}
type roblox_path = string
type version = string
type author = string
type path = string
type glob = string
type url = string

-- vars
local manifest: manifest = {
    package = {
        exclude = {},
        include = {},
        authors = {},
    },
    include = {},
    exclude = {},
    place = {},
    ['dependencies'] = {},
    ['dev-dependencies'] = {},
    ['server-dependencies'] = {},
}
merge(manifest, file.read_toml('wally.toml') or {})

-- end
return manifest
