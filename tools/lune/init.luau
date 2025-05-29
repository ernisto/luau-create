local github_release = require('@utils/github/release')
local language = require('@lib/language')
local toolchain = require('@lib/toolchain')

local luau = require('@tools/luau')
local pesde = require('@tools/pesde')

-- vars
local sup = false

-- functions
local function save()
	if not sup then return end
end
local function setup(input_version: string?)
	if sup then return end
	sup = true

	local version = input_version or github_release.get_latest_version('lune-org', 'lune')
	luau.setup()

	toolchain.install_github('feliptibell', 'lune', version)
	pesde.manifest.engines.lune = `^{version}`

	language.add_alias('lune', `~/.lune/.typedefs/{version}/`)
end

-- module
return table.freeze {
	save = save,
	setup = setup,
}
