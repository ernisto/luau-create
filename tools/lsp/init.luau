local github_release = require('@utils/github/release')
local merge = require('@utils/merge')
local project = require('@lib/project')
local vsc = require('@tools/vsc')

-- vars
local sup = false
local ignore_diagnostics = {}
local ignore_imports = {}
local def_files = {}

-- functions
local function save()
	if not sup then return end
end

type glob = string
type path = string
local function ignore_import_globs(...: glob)
	for _, glob in { ... } do
		if table.find(ignore_imports, glob) then continue end
		table.insert(ignore_imports, glob)
	end
end
local function ignore_diagnostic_globs(...: glob)
	for _, glob in { ... } do
		if table.find(ignore_diagnostics, glob) then continue end
		table.insert(ignore_diagnostics, glob)
	end
end
local function add_def_files(...: path)
	for _, glob in { ... } do
		if table.find(def_files, glob) then continue end
		table.insert(def_files, glob)
	end
end

local function setup(input_version: string?)
	if sup then return end
	sup = true

	local version = input_version
		or github_release.get_latest_version('johnnymorganz', 'luau-lsp')
		or error("couldn't find latest version for luau-lsp")
	-- toolchain.install_github('johnnymorganz', 'luau-lsp', version)
	-- toolchain.install_pesde('pesde', 'luau-lsp', version)

	vsc.recommend_extensions('johnnymorganz.luau-lsp')
	merge(vsc.settings, {
		['luau-lsp.completion.imports.ignoreGlobs'] = ignore_imports,
		['luau-lsp.types.definitionFiles'] = def_files,
		['luau-lsp.ignoreGlobs'] = ignore_diagnostics,
		['luau-lsp.completion.imports.requireStyle'] = if project.project.kind == 'package'
			then 'alwaysRelative'
			else 'alwaysAbsolute',
		['luau-lsp.completion.imports.stringRequires.enabled'] = true,
		['luau-lsp.fflags.enableNewSolver'] = false,
		['luau-lsp.bytecode.vectorCtor'] = 'create',
		['luau-lsp.bytecode.vectorType'] = 'vector',
		['luau-lsp.bytecode.vectorLib'] = 'vector',
		['luau-lsp.platform.type'] = 'standard',
	})
	ignore_imports = vsc.settings['luau-lsp.completion.imports.ignoreGlobs']
	def_files = vsc.settings['luau-lsp.types.definitionFiles']
	ignore_diagnostics = vsc.settings['luau-lsp.ignoreGlobs']
end

-- module
return table.freeze {
	setup = setup,
	save = save,
	add_def_files = add_def_files,
	ignore_import_globs = ignore_import_globs,
	ignore_diagnostic_globs = ignore_diagnostic_globs,
}
