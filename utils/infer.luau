local process = require('@lune/process')
local task = require('@lune/task')
local fs = require('@lune/fs')
local cwd = process.cwd

-- functions
local entry_points
local function await_entry_points()
    if entry_points then return entry_points end
    entry_points = {}
    for _,child in fs.readDir('.') do
        local name = string.match(child, '(.*)%.luau?$') or child
        entry_points[name] = if fs.isFile(child) then string.match(child, '%.luau?$') and child
            elseif fs.isFile(`{child}/init.luau`) then `{child}/init.luau`
            elseif fs.isFile(`{child}/init.lua`) then `{child}/init.lua`
            else nil
    end
    return entry_points
end

local user: string?
local function await_git_user(): string?
    if user then return user end
    local r = process.spawn('git', {'config', 'user.name'})
    while r.stdout == '' do
        task.wait()
        assert(r.stderr == '', r.stderr)
    end
    user = string.match(r.stdout, "^%s*([-_%w]+)%s*$")
    return user
end

local email: string?
local function await_git_email(): string?
    if email then return email end
    local r = process.spawn('git', {'config', 'user.email'})
    while r.stdout == '' do
        task.wait()
        assert(r.stderr == '', r.stderr)
    end
    email = string.match(r.stdout, `(%S+)`)
    return email
end

local function get_folder_name()
    return string.match(cwd, "([%w_%-]+)[\\/]?$")
end

-- module
return table.freeze {
    get_folder_name = get_folder_name,
    await_entry_points = await_entry_points,

    await_git_email = await_git_email,
    await_git_user = await_git_user,
}