local project = require('@lib/project').project
local editor = require('@lib/editor')
local file = require('@lib/file')
local language = require('@lib/language')
local tracker = require('@lib/tracker')

-- vars
local sup = false
local manifest = require('@self/manifest')

-- functions
local function save ()
	if not sup then return end
	file.write_json('package.json', manifest)
end

local function setup ()
	if sup then return end
	sup = true

	editor.hide_globs('node_modules/**', 'package.json')
	editor.lock_globs('node_modules/**')
	tracker.ignore_globs('node_modules/**')
	language.ignore_import_globs('**/node_modules/**')
	language.ignore_diagnostic_globs('node_modules/**')

	manifest.name = `{project.host}/{project.name:gsub('-', '_')}`
	manifest.version = tostring(project.version)
	manifest.description = project.description
	manifest.license = project.license
	manifest.keywords = { project.environment, project.kind, project.side :: any }

	manifest.contribuitors = { unpack(project.authors, 2) }
	manifest.author = project.authors[1]

	manifest.private = project.private
	manifest.repository = project.repository :: any
	manifest.homepage = project.homepage
	manifest.funding = project.funding
	manifest.bugs = project.bugs :: any

	manifest.main = `{project.entrypoint}/init.luau`
	manifest.files = {
		'package.json',
		'README.md',
		'LICENSE',
		project.entrypoint and `{project.entrypoint}/**` :: any,
	}

	-- manifest.publicConfigs = {}
	-- manifest.config = {}

	-- manifest.workspaces = {}
	-- manifest.exports = {}
	-- manifest.engines = {}
end

-- module
return table.freeze {
	save = save,
	setup = setup,
	manifest = manifest,
}
