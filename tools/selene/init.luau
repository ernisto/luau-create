local editor = require('@lib/editor')
local file = require('@lib/file')
local toolchain = require('@lib/toolchain')
local vsc = require('@tools/vsc')

-- vars
local sup = false
local version = '0.28.0'

local manifest = require('@self/manifest')

-- functions
local function save()
	if not sup then return end
	file.write_toml('selene.toml', manifest)
end
local function setup()
	if sup then return end
	sup = true

	toolchain.install_github('kampfkarren', 'selene', version)
	toolchain.install_pesde('pesde', 'selene', version)

	vsc.recommend_extensions('kampfkarren.selene-vscode')
	editor.hide_globs('selene.toml')
end

-- module
return table.freeze {
	save = save,
	setup = setup,
	manifest = manifest,
}
