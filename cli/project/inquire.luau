local inquisitor = require("@cli/inquisitor")
local project = require('@lib/project')
local infer = require('@utils/infer')

-- main
local function inquire()
    local project = project.project

    -- root
    local q = inquisitor(project)
    local env = q.enum {
        name = 'environment',
        { name = 'roblox' },
        { name = 'lune' },
        { name = 'luau' },
    }
    local kind = q.enum {
        name = 'kind',
        default_index = if project.directories.lib then 1
            elseif project.directories.plugin then 2
            elseif env == 'roblox' then 3
            elseif project.directories.cli then 5
            else 4,

        { name = 'package' },
        if env == 'roblox' then { name = 'plugin' } else nil :: any,
        if env == 'roblox' then { name = 'game' } else nil :: any,

        if env == 'lune' then { name = 'script', desc = 'terminal scripts, such for building, or deploy' } else nil :: any,
        if env == 'lune' then { name = 'cli' } else nil :: any,
    }
    if env == 'roblox' and kind == 'package' then
        q.enum {
            name = 'side',
            { name = 'client' },
            { name = 'shared' },
            { name = 'server' },
        }
    end
    if kind ~= 'game' then
        q.str {
            name = 'entrypoint',
            default = if kind == 'package' then 'lib' elseif kind == 'terminal' then 'cli' else kind
        }
    end

    local name = q.identifier { name = 'name' }
    local host = q.identifier { name = 'host' }
    q.version { name = 'version', default = "0.1.0" }

    q.str { name = 'description', optional = true }
    q.enum {
        name = 'license',
        optional = true,
        { name = 'MIT' },
    }
    q.bool { name = 'private' }

    -- repo
    local repo_type, repo_url
    local q_repository = q.struct { name = 'repository' } do
        repo_type = q_repository.enum {
            name = 'type',
            optional = true,
            default_index = 1,
            { name = 'git' }
        }
        repo_url = q_repository.str {
            name = 'url',
            default = if repo_type == 'git' then `https://github.com/{host}/{name}` else nil
        }
    end

    -- pages
    q.str { name = 'homepage', optional = true, default = repo_url and `{repo_url}#readme` }

    local q_bugs = q.struct { name = 'bugs' } do
        q_bugs.str { name = 'url', optional = true, default = repo_url and `{repo_url}/issues` }
    end

    if #project.authors == 0 then
        local author = q.str { name = 'author', default = project.host .. if infer.await_git_email() then ` <{infer.await_git_email()}>` else '' }
        table.insert(project.authors, author)
    end

    -- stylua
    local q_stylua = q.struct { name = 'stylua' } do
        q_stylua.enum {
            name = 'syntax',
            optional = true,
            { name = 'All' },
            { name = 'Lua51' },
            { name = 'Lua52' },
            { name = 'Lua53' },
            { name = 'Lua54' },
            { name = 'LuaJit' },
            { name = 'Luau' },
            { name = 'CfxLua' },
        }
        q_stylua.int { name = 'column_width', optional = true, default = 4 }
        q_stylua.enum {
            name = 'line_endings',
            optional = true,
            { name = 'Unix' },
            { name = 'Windows' }
        }
        q_stylua.enum {
            name = 'ident_type',
            optional = true,
            { name = 'Tabs' },
            { name = 'Space' }
        }
        q_stylua.int { name = 'ident_width', default = 4, optional = true }
        q_stylua.enum {
            name = 'quote_style',
            optional = true,
            { name = 'AutoPreferDouble' },
            { name = 'AutoPreferSingle' },
            { name = 'ForceDouble' },
            { name = 'ForceSingle' },
        }
        q_stylua.enum {
            name = 'call_parentheses',
            optional = true,
            { name = 'Always' },
            { name = 'NoSingleString' },
            { name = 'NoSingleTable' },
            { name = 'None' },
            { name = 'Input' },
        }
        q_stylua.enum {
            name = 'space_after_function_names',
            optional = true,
            { name = 'Never' },
            { name = 'Definitions' },
            { name = 'Calls' },
            { name = 'Always' },
        }
        q_stylua.enum {
            name = 'collapse_simple_statement',
            optional = true,
            { name = 'Never' },
            { name = 'FunctionOnly' },
            { name = 'Conditionaly' },
            { name = 'Always' },
        }
        local value = q_stylua.bool { name = 'sort_requires', optional = true }
        project.stylua.sort_requires = { enabled = value }
    end
    return inquire
end

return inquire