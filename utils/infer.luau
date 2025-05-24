local fs = require('@lune/fs')
local process = require('@lune/process')
local task = require('@lune/task')
local cwd = process.cwd

-- functions
local entry_points
local function await_entry_points(): { [string]: string }
	if entry_points then return entry_points end
	entry_points = {}
	for _, child in fs.readDir('.') do
		local name = string.match(child, '(.*)%.luau?$') or child
		entry_points[name] = if fs.isFile(child)
			then string.match(child, '%.luau?$') and child
			elseif fs.isFile(`{child}/init.luau`) then child
			elseif fs.isFile(`{child}/init.lua`) then child
			else nil :: any
	end
	return entry_points
end

local user: string?
local function await_git_user(): string?
	if user then return user end
	local process = process.create('git', { 'config', 'user.name' })
	local output, err

	repeat
		output = process.stdout:readToEnd()
		err = process.stderr:readToEnd()
		assert(err == '', err)
	until output ~= '' or err ~= '' or not task.wait()

	user = string.match(output, '^%s*([-_%w]+)%s*$')
	return user
end

local email: string?
local function await_git_email(): string?
	if email then return email end
	local process = process.create('git', { 'config', 'user.email' })
	local output, err

	repeat
		output = process.stdout:readToEnd()
		err = process.stderr:readToEnd()
		assert(err == '', err)
	until output ~= '' or err ~= '' or not task.wait()

	email = string.match(output, `(%S+)`)
	return email
end

local function get_folder_name()
	return string.match(cwd, '([%w_%-]+)[\\/]?$')
end

-- module
return table.freeze {
	get_folder_name = get_folder_name,
	await_entry_points = await_entry_points,

	await_git_email = await_git_email,
	await_git_user = await_git_user,
}
