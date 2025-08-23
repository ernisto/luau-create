-- 0.6.2	-- docs/typedefs/*
-- 0.7.5	-- types/*  -- PascalCase
-- 0.7.8    -- types/*  -- lowercase

local file = require('@lib/file')
local fs = require('@lune/fs')
local github_file = require('@utils/github/file')
local language = require('@lib/language')
local semver = require('@pkg/semver')
local task = require('@lune/task')

-- defs
local local_type_def_path = `{file.get_home_dir()}/.lune/.typedefs/%s/%s.luau`
type path = string

-- functions
local function await_write_type_def(version: string, crate_name: path, type_def_file: github_file.RepositoryFile)
	local version_ref = `v{version}`
	if fs.isFile(local_type_def_path:format(version, crate_name)) then
		warn('already exists def for', crate_name)
		return
	end

	local success, result = pcall(github_file.read_file, 'lune-org', 'lune', type_def_file.path, version_ref)
	if success then
		if result == nil then return end
	else
		warn(`failed to get type defs for '{crate_name}':\n`, result)
		return
	end

	fs.writeFile(local_type_def_path:format(version, type_def_file), result)
end
local function write_type_defs_async(version: semver.version)
	if semver.is_oldest(version, semver.parse '0.6.2') then return end
	local path = if semver.is_oldest(version, semver.parse '0.7.5') then 'docs/typedefs' else 'types'

	local version_ref = `v{version}`
	local files = github_file.list_files('lune-org', 'lune', path, version_ref)

	for _, type_def_file in files do
		local crate_name = type_def_file.name:match('(.*)%.luau$')
		if not crate_name then continue end

		task.spawn(await_write_type_def, tostring(version), crate_name:lower(), type_def_file)
	end

	language.add_alias('lune', `~/.lune/.typedefs/{version}/`)
end

-- module
return table.freeze {
	write_type_defs_async = write_type_defs_async,
}
