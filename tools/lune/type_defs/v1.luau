-- 0.0.1	-- luneTypes.d.luau
-- 0.5.0	-- docs/luneTypes.d.luau

local fs = require('@lune/fs')
local github_file = require('@utils/github/file')
local language = require('@lib/language')
local semver = require('@pkg/semver')

-- defs
local local_type_def_path = 'defs/lune.d.luau'
type path = string

-- functions
local function await_write_type_defs(version: semver.version)
	local version_ref = `v{version}`
	local path = if semver.is_oldest(version, semver.parse '0.5.0') then 'luneTypes.d.luau' else 'docs/luneTypes.d.luau'

	local success, result = pcall(github_file.read_file, 'lune-org', 'lune', path, version_ref)
	if success then
		if result == nil then return end
	else
		warn(`failed to get type defs:\n`, result)
		return
	end

	fs.writeFile(local_type_def_path, result)
	language.add_global_def('lune', local_type_def_path)
end

-- module
return table.freeze {
	await_write_type_defs = await_write_type_defs,
}
