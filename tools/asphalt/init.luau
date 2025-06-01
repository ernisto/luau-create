local editor = require('@lib/editor')
local file = require('@lib/file')
local github_release = require('@utils/github/release')
local toolchain = require('@lib/toolchain')

-- vars
local sup = false
local manifest = require('@self/manifest')

-- functions
local function save()
	if not sup then return end
	file.write_toml('asphalt.toml', manifest)
end
local function setup(input_version: string?)
	if sup then return end
	sup = true

	local version = input_version
		or github_release.get_latest_version('jacktabscode', 'asphalt')
		or error("couldn't find latest version for asphalt")
	toolchain.install_github('jacktabscode', 'asphalt', version)
	toolchain.install_pesde('pesde', 'asphalt', version)

	file.ensure_existing_chain('assets')
	editor.hide_globs('asphalt.toml')
end

-- module
return table.freeze {
	save = save,
	setup = setup,
	manifest = manifest,
}
