local editor = require('@lib/editor')
local file = require('@lib/file')
local merge = require('@utils/merge')
local toolchain = require('@lib/toolchain')
local vsc = require('@tools/vsc')

local version = '2.1.0'

-- vars
local sup = false
local manifest = require('@self/manifest')

-- functions
local function save()
	if not sup then return end
	file.write_toml('stylua.toml', manifest)
end
local function setup()
	if sup then return end
	sup = true

	toolchain.install_github('johnnymorganz', 'stylua', version)
	toolchain.install_pesde('pesde', 'stylua', version)

	vsc.recommend_extensions('johnnymorganz.stylua')
	editor.hide_globs('stylua.toml')

	merge(vsc.settings, {
		['stylua.targetReleaseVersion'] = 'latest',
		['editor.formatOnSave'] = true,
		['files.eol'] = if manifest.line_endings == 'Unix' then '\\n' else '\\r\\n',
	})
end

-- module
return table.freeze {
	save = save,
	setup = setup,
	manifest = manifest,
}
