local file = require('@lib/file')
local language = require('@lib/language')
local toolchain = require('@lib/toolchain')
local tracker = require('@lib/tracker')

local rojo = require('@tools/rojo')
local vsc = require('@tools/vsc')

local github_release = require('@utils/github/release')

-- vars
local sup = false
local manifest = {}
-- merge(manifest, file.read_str('dev.blink'))

-- functions
local function save()
	if not sup then return end
end
local function setup(input_version: string?)
	if sup then return end
	sup = true

	local version = input_version
		or github_release.get_latest_version('1Axen', 'blink')
		or error("couldn't find latest version for blink")
	toolchain.install_github('1Axen', 'blink', version)
	toolchain.install_pesde('pesde', 'blink', version)

	vsc.settings['files.associations']['*.blink'] = 'blink'
	vsc.recommend_extensions('checkraisefold.blink-vscode')
	language.ignore_diagnostic_globs('**/dist/**')
	tracker.ignore_globs('**/dist/**')
	vsc.hide_globs('**/dist/**')
	vsc.lock_globs('**/dist/**')

	local path = debug.info(1, 's'):match('%[string "(.-)/?init%.luau"%]$')
	file.write_default_str('dev.blink', file.read_str(`{path}/default.blink`))

	manifest.ServerOutput = 'dist/blink/server/init.luau'
	manifest.ClientOutput = 'dist/blink/client/init.luau'
	manifest.TypesOutput = 'dist/blink/types.luau'

	rojo.add_system_path('dist/blink/server', { 'ServerScriptService', 'server', 'remotes' })
	rojo.add_system_path('dist/blink/client', { 'ReplicatedStorage', 'client', 'remotes' })
	rojo.add_system_path('dist/blink/types.luau', { 'ReplicatedStorage', 'types' })

	file.write_default_str('remotes/init.blink')
end

-- module
return table.freeze {
	save = save,
	setup = setup,
}
