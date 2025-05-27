local file = require('@lib/file')
local merge = require('@utils/merge')
local toolchain = require('@lib/toolchain')
local vsc = require('@tools/vsc')

local version = '0.11.18'

-- vars
local sup = false
local manifest = {}
merge(manifest, file.read_str('mantle.yml'))

-- functions
local function save()
	if not sup then return end
	file.write_yaml('mantle.yml', manifest)
end
local function setup()
	if sup then return end
	sup = true

	toolchain.install_github('blake-mealey', 'mantle', version)
	toolchain.install_pesde('pesde', 'mantle', version)

	merge(vsc.settings, {
		['yaml.schemas'] = {
			[`https://mantledeploy.vercel.app/schemas/v{version}/schema.json`] = { 'mantle.yml' },
		},
	})
	vsc.hide_globs('.mantle-state.yml')
	vsc.lock_globs('.mantle-state.yml')
end

-- module
return table.freeze {
	save = save,
	setup = setup,
}
