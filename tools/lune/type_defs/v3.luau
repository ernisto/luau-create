-- for lune 0.9.0	-- crates/**/types.d.luau

local file = require('@lib/file')
local fs = require('@lune/fs')
local github_file = require('@utils/github/file')
local language = require('@lib/language')
local semver = require('@utils/semver')
local task = require('@lune/task')

-- defs
local local_type_def_path = `{file.get_home_dir()}/.lune/.typedefs/%s/%s.luau`

-- functions
local function await_write_type_def(version: string, crate_name: string, crate_file: github_file.RepositoryFile)
	local version_ref = `v{version}`
	if fs.isFile(local_type_def_path:format(version, crate_name)) then
		warn('already exists def for', crate_name)
		return
	end

	local success, result =
		pcall(github_file.read_file, 'lune-org', 'lune', `{crate_file.path}/types.d.luau`, version_ref)
	if success then
		if result == nil then return end
	else
		warn(`failed to get type defs of '{crate_file.name}':\n`, result)
		return
	end

	fs.writeFile(local_type_def_path:format(version, crate_name), result)
end
local function write_type_defs_async(version: semver.Version)
	local version_ref = `v{version}`
	if version < semver '0.9.0' then return end

	local files = github_file.list_files('lune-org', 'lune', 'crates', version_ref)
	for _, crate_file in files do
		local crate_name = crate_file.name:match('^lune%-std%-(.*)')
		if not crate_name then continue end
		task.spawn(await_write_type_def, tostring(version), crate_name, crate_file)
	end

	language.add_alias('lune', `~/.lune/.typedefs/{version}/`)
end

-- module
return table.freeze {
	write_type_defs_async = write_type_defs_async,
}
