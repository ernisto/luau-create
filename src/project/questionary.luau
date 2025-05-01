local question = require('@lib/question')
local semver = require('@pkg/semver')

local process = require('@lune/process')
local serde = require('@lune/serde')
local fs = require('@lune/fs')
local cwd = process.cwd

local function maybe_from_npm()
    if not fs.isFile('package.json') then return end
    local content = fs.readFile('package.json')

    local data = serde.decode('json', content)

    data.author = data.host
    return data
end
local function maybe_from_wally()
    if not fs.isFile('wally.toml') then return end
    local content = fs.readFile('wally.toml')

    local data = serde.decode('toml', content)
    local name, host = string.match(data.name, "(%w[_]+)/(%w[_]+)")

    data.environment = 'roblox'
    data.name = name
    data.host = host
    return data
end
local function maybe_from_pesde()
    if not fs.isFile('pesde.toml') then return end
    local content = fs.readFile('pesde.toml')

    local data = serde.decode('toml', content)
    local name, host = string.match(data.name, "(%w[_]+)/([%w_]+)")
    local target = data.target

    data.name = name
    data.host = host
    data.environment = target and target.environment
    data.kind = if target.lib then 'package' elseif target.bin then 'plugin' else 'application'
    data.entrypoint = target and target.lib
    return data
end

local function infer_project_name()
    return string.match(cwd, "([%w_%-]+)[\\/]?$")
end
local function infer_entrypoint(): string?
    if fs.isDir(cwd..'/src') then return 'src/init.luau' end
    if fs.isDir(cwd..'/lib') then return 'lib/init.luau' end
    if fs.isDir(cwd..'/bin') then return 'cli/init.luau' end
    return
end

local function parse_identifier(input: string)
    return string.match(input, "^%w+$")
end
local function parse_version(input: string)
    return semver.parse(input):unpack()
end

return question.struct {
    name = 'project',
    presets = {
        npm = maybe_from_npm(),
        wally = maybe_from_wally(),
        pesde = maybe_from_pesde(),
    },

    question.enum {
        name = 'environment',
        { name = 'roblox' },
        { name = 'lune' },
        { name = 'luau' },
    },
    question.enum {
        name = 'kind',
        -- default_index = if infer_entrypoint() then 0 else 0,
        { name = 'application' },
        { name = 'package' },
        { name = 'plugin' }
    },
    question.str { name = 'name', default = infer_project_name(), parse = parse_identifier },
    question.str { name = 'host' },
    question.str { name = 'version', default = "0.1.0", parse = parse_version, },
    question.str { name = 'description' },
    question.str { name = 'entrypoint', default = infer_entrypoint() },
    question.enum {
        name = 'license',
        { name = 'MIT' }
    },
    question.str { name = 'homepage', default = function(ctx: any) return `https://github.com/{ctx.host}/{ctx.name}#readme` end },
    question.struct { name = 'repository',
        question.str { name = 'type', default = 'git' },
        question.str { name = 'url', default = function(ctx: any) return `git+https://github.com/{ctx.host}/{ctx.name}.git` end }
    },
    question.struct { name = 'bugs',
        question.str { name = 'url', default = function(ctx: any) return `https://github.com/{ctx.host}/{ctx.name}/issues` end }
    },
}