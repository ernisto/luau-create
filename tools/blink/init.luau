local file = require('@lib/file')
local merge = require('@utils/merge')
local toolchain = require('@lib/toolchain')
local tracker = require('@lib/tracker')

local rojo = require('@tools/rojo')
local vsc = require('@tools/vsc')

local github = require('@utils/github')

-- vars
local sup = false
local manifest = {}
-- merge(manifest, file.read_str('remotes/init.blink'))

-- functions
local function save()
	if not sup then return end
end
local function setup(input_version: string?)
	if sup then return end
	sup = true

	local version = input_version or github.get_latest_version('1Axen', 'blink')
	toolchain.install_github('1Axen', 'blink', version)
	toolchain.install_pesde('pesde', 'blink', version)

	vsc.settings['files.associations']['*.blink'] = 'blink'
	vsc.recommend_extensions('checkraisefold.blink-vscode')
	vsc.hide_globs('dist/**')
	vsc.lock_globs('dist/**')
	tracker.ignore_globs('dist/**')

	file.write_default_str('remotes/init.blink')
	rojo.add_system_path('dist/blink/server', { 'ServerScriptService', 'server', 'remotes' })
	rojo.add_system_path('dist/blink/client', { 'ReplicatedStorage', 'client', 'remotes' })
	rojo.add_system_path('dist/blink/types', { 'ReplicatedStorage', 'types' })
end

-- module
return table.freeze {
	save = save,
	setup = setup,
}
