local merge = require('@utils/merge')
local file = require('@lib/file')

--defs
type url = string
type tool = {
    github: string?,
    gitlab: string?,
    source: string?,
    version: string,
}

-- module
type manifest = {
    hosts: { [string]: { souce: url, protocol: string } }?,
    tools: { [string]: tool }
}
local manifest: manifest = {
    tools = {}
}
merge(manifest, file.read_toml('foreman.toml') or {})

return manifest