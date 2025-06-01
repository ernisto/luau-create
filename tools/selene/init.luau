local editor = require('@lib/editor')
local file = require('@lib/file')
local toolchain = require('@lib/toolchain')

local github_release = require('@utils/github/release')
local vsc = require('@tools/vsc')

-- vars
local sup = false
local manifest = require('@self/manifest')

-- functions
local function save()
	if not sup then return end
	file.write_toml('selene.toml', manifest)
end
local function setup(input_version: string?)
	if sup then return end
	sup = true

	local version = input_version
		or github_release.get_latest_version('kampfkarren', 'selene')
		or error("couldn't find latest version for selene")
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
