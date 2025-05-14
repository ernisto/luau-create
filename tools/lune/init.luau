local language = require('@lib/language')
local pesde = require('@tools/pesde')
local toolchain = require('@lib/toolchain')
local version = '0.9.2'

-- vars
local sup = false

-- functions
local function save ()
	if not sup then return end
end
local function setup ()
	if sup then return end
	sup = true

	toolchain.install_github('feliptibell', 'lune', version)
	pesde.manifest.engines.lune = version

	language.add_alias('lune', `~/.lune/.typedefs/{version}/`)
end

-- module
return table.freeze {
	save = save,
	setup = setup,
}
