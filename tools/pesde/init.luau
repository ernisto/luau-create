local project = require('@lib/project').project
local editor = require('@lib/editor')
local file = require('@lib/file')
local language = require('@lib/language')
local tracker = require('@lib/tracker')

-- vars
local sup = false
local github_release = require('@utils/github/release')
local manifest = require('@self/manifest')

-- functions
local function save()
	if not sup then return end
	file.write_toml('pesde.toml', manifest)
end

local function identifier(str)
	return str:gsub('-', '_'):gsub('%u+', string.lower)
end

local function setup(input_version: string?)
	if sup then return end
	sup = true

	local version = input_version
		or github_release.get_latest_version('pesde-pkg', 'pesde')
		or error("couldn't find latest version for pesde")

	editor.hide_globs('**/.pesde/**', '**/*_packages/**', '**/pesde.toml')
	editor.lock_globs('**/.pesde/**', '**/*_packages/**')
	tracker.ignore_globs('**/.pesde/**', '**/*_packages/**')
	language.ignore_import_globs('**/.pesde/**')
	language.ignore_diagnostic_globs('**/.pesde/**', '**/*_packages/**')

	-- manifest
	manifest.engines = { pesde = `^{version}` }

	manifest.name = `{identifier(project.host)}/{identifier(project.name)}`
	manifest.version = tostring(project.version)
	manifest.description = project.description
	manifest.license = project.license

	manifest.authors = project.authors

	manifest.private = project.private
	manifest.repository = project.repository and project.repository.url

	manifest.includes = {
		'pesde.toml',
		'README.md',
		'LICENSE',
		'docs/**/*.md',
		project.entrypoint and `{project.entrypoint}/**` :: any,
	}

	manifest.target.environment = if project.environment == 'roblox' and project.side == 'server'
		then 'roblox_server'
		else project.environment
	manifest.target.lib = if project.kind == 'package' then project.entrypoint else nil
	manifest.target.bin = project.directories.cli
	manifest.target.environment = project.environment

	manifest.wally_indices = if project.environment == 'roblox'
		then { default = 'https://github.com/UpliftGames/wally-index' } :: any
		else nil
	manifest.indices = { default = 'https://github.com/pesde-pkg/index' } :: any
end

-- module
return table.freeze {
	save = save,
	setup = setup,
	manifest = manifest,
}
