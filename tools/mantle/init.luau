local file = require('@lib/file')
local github_release = require('@utils/github/release')
local merge = require('@utils/merge')
local toolchain = require('@lib/toolchain')
local vsc = require('@tools/vsc')

-- vars
local sup = false

local manifest = {}
merge(manifest, file.read_yaml('mantle.yml'))

-- functions
local function save()
	if not sup then return end
	file.write_yaml('mantle.yml', manifest)
end
local function setup(input_version: string?)
	if sup then return end
	sup = true

	local version = input_version
		or github_release.get_latest_version('blake-mealey', 'mantle')
		or error("couldn't find latest version for mantle")

	toolchain.install_github('blake-mealey', 'mantle', version)
	-- toolchain.install_pesde('pesde', 'mantle', version)

	merge(vsc.settings, {
		['yaml.schemas'] = {
			[`https://mantledeploy.vercel.app/schemas/v{version}/schema.json`] = { 'mantle.yml' },
		},
	})
	file.write_default_str('assets/models/.gitkeep')
	file.write_default_str('assets/sounds/.gitkeep')
	vsc.hide_globs('.mantle-state.yml')
	vsc.lock_globs('.mantle-state.yml')
end

-- module
return table.freeze {
	save = save,
	setup = setup,
}
