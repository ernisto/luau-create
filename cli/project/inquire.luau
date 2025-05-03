local inquisitor = require("@cli/inquisitor")
local project = require('@lib/project')
local utils = require('@lib/utils')

-- main
local function inquire()

    local project = project.project

    local entry_points = utils.await_entry_points()
    local infered_user = utils.await_git_user()
    local folder_name = utils.get_folder_name()

    -- root
    local q = inquisitor(project)
    local env = q.enum {
        name = 'environment',
        { name = 'roblox' },
        { name = 'lute' },
        { name = 'lune' },
        { name = 'luau' },
    }
    local kind = q.enum {
        name = 'kind',
        default_index = if entry_points.lib then 1
            elseif entry_points.plugin then 2
            elseif env == 'roblox' then 3
            elseif entry_points.cli then 5
            else 4,

        { name = 'package' },
        if env == 'roblox' then { name = 'plugin' } else nil :: any,
        if env == 'roblox' then { name = 'game' } else nil :: any,

        if env ~= 'roblox' then { name = 'script', desc = 'terminal scripts, such for building, or deploy' } else nil :: any,
        if env ~= 'roblox' and env ~= 'luau' then { name = 'terminal' } else nil :: any,
    }
    if env == 'roblox' and kind == 'package' then
        q.enum {
            name = 'side',
            { name = 'client' },
            { name = 'shared' },
            { name = 'server' },
        }
    end
    if kind ~= 'plugin' and kind ~= 'game' then
        q.str {
            name = 'entrypoint',
            default = `{if kind == 'package' then 'lib' else kind}/init.luau` or select(2, next(entry_points))
        }
    end

    local name = q.identifier { name = 'name', default = folder_name }
    local host = q.identifier { name = 'host', default = infered_user }
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
        local author = q.str { name = 'author', default = project.host .. if utils.await_git_email() then ` <{utils.await_git_email()}>` else '' }
        table.insert(project.authors, author)
    end

    return inquire
end

return inquire