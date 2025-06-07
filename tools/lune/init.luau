local github_release = require('@utils/github/release')
local toolchain = require('@lib/toolchain')

local luau = require('@tools/luau')
local pesde = require('@tools/pesde')

-- vars
local sup = false
local type_defs = require('@self/type_defs')

-- functions
local function save()
	if not sup then return end
end
local function setup(input_version: string?)
	if sup then return end
	sup = true

	local version = input_version
		or github_release.get_latest_version('lune-org', 'lune')
		or error("couldn't find latest version for lune")
	luau.setup()

	toolchain.install_github('feliptibell', 'lune', version)
	pesde.manifest.engines.lune = `^{version}`

	type_defs.write_type_defs_async(version)
end

-- module
return table.freeze {
	save = save,
	setup = setup,
}
