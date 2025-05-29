local editor = require('@lib/editor')
local file = require('@lib/file')
local toolchain = require('@lib/toolchain')
local tracker = require('@lib/tracker')

local github_release = require('@utils/github/release')
local merge = require('@utils/merge')
local vsc = require('@tools/vsc')

-- vars
local sup = false
local manifest = require('@self/manifest')

-- functions
local function save()
	if not sup then return end
	file.write_toml('stylua.toml', manifest)
end
local function setup(input_version: string?)
	if sup then return end
	sup = true

	local version = input_version or github_release.get_latest_version('johnnymorganz', 'stylua')
	toolchain.install_github('johnnymorganz', 'stylua', version)
	toolchain.install_pesde('pesde', 'stylua', version)

	tracker.set_attribute('*.luau', if manifest.line_endings == 'Windows' then 'eol=crlf' else 'eol=lf')
	vsc.recommend_extensions('johnnymorganz.stylua')
	editor.hide_globs('stylua.toml')

	merge(vsc.settings, {
		['stylua.targetReleaseVersion'] = 'latest',
		['editor.formatOnSave'] = true,
		['files.eol'] = if manifest.line_endings == 'Windows' then '\n\r' else '\n',
	})
end

-- module
return table.freeze {
	save = save,
	setup = setup,
	manifest = manifest,
}
