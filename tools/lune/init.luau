local language = require('@lib/language')
local toolchain = require('@lib/toolchain')

local luau = require('@tools/luau')
local pesde = require('@tools/pesde')

-- vars
local sup = false
local version = '0.9.2'

-- functions
local function save()
	if not sup then return end
end
local function setup()
	if sup then return end
	sup = true

	luau.setup()

	toolchain.install_github('feliptibell', 'lune', version)
	pesde.manifest.engines.lune = version

	language.add_alias('lune', `~/.lune/.typedefs/{version}/`)
end

-- module
return table.freeze {
	save = save,
	setup = setup,
}
