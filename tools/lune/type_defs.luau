local file = require('@lib/file')
local fs = require('@lune/fs')
local github_file = require('@utils/github/file')
local task = require('@lune/task')

-- 0.0.1	-- luneTypes.d.luau
-- 0.5.0	-- docs/luneTypes.d.luau
-- 0.6.2	-- docs/typedefs/*
-- 0.7.5	-- types/*
-- 0.9.0	-- crates/**/types.d.luau

-- defs
local local_type_def_path = `{file.get_home_dir()}/.lune/.typedefs/%s/%s.luau`
local type_defs_path = '~/.lune/.typedefs/%s/'

-- functions
local function await_write_type_def(version: string, crate_name: string, crate_file: github_file.RepositoryFile)
	local version_ref = `v{version}`
	if fs.isFile(local_type_def_path:format(version, crate_name)) then
		-- print('already exists def for', crate_name)
		return
	end
	-- error(`cavalo {version} {crate_name}: {local_type_def_path:format(version, crate_name)}`)

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
local function write_type_defs_async(version: string)
	local version_ref = `v{version}`
	local files = github_file.list_files('lune-org', 'lune', 'crates', version_ref)
	for _, crate_file in files do
		local crate_name = crate_file.name:match('^lune%-std%-(.*)')
		if not crate_name then continue end
		task.spawn(await_write_type_def, version, crate_name, crate_file)
	end
	return type_defs_path:format(version)
end

-- print(write_type_defs_async('0.8.3'))

-- module
return table.freeze {
	write_type_defs_async = write_type_defs_async,
}
