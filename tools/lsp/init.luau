local github_release = require('@utils/github/release')
local merge = require('@utils/merge')
local project = require('@lib/project')
local vsc = require('@tools/vsc')

-- vars
local sup = false
local ignore_diagnostics = {}
local ignore_imports = {}

-- functions
local function save()
	if not sup then return end
end

type glob = string
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

local function setup(input_version: string?)
	if sup then return end
	sup = true

	local version = input_version or github_release.get_latest_version('johnnymorganz', 'luau-lsp')
	-- toolchain.install_github('johnnymorganz', 'luau-lsp', version)
	-- toolchain.install_pesde('pesde', 'luau-lsp', version)

	vsc.recommend_extensions('johnnymorganz.luau-lsp')
	merge(vsc.settings, {
		['luau-lsp.completion.imports.ignoreGlobs'] = ignore_imports,
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
	ignore_diagnostics = vsc.settings['luau-lsp.ignoreGlobs']
end

-- module
return table.freeze {
	setup = setup,
	save = save,
	ignore_import_globs = ignore_import_globs,
	ignore_diagnostic_globs = ignore_diagnostic_globs,
}
