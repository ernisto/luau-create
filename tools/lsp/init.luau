local merge = require('@utils/merge')
local project = require('@lib/project')
local vsc = require('@tools/vsc')

-- vars
local ignore_diagnostics = {}
local ignore_imports = {}
local sup = false

-- functions
local function save ()
	if not sup then return end
end

type glob = string
local function ignore_import_globs (...: glob)
	for _, glob in { ... } do
		if table.find(ignore_diagnostics, glob) then continue end
		table.insert(ignore_diagnostics, glob)
	end
end
local function ignore_diagnostic_globs (...: glob)
	for _, glob in { ... } do
		if table.find(ignore_imports, glob) then continue end
		table.insert(ignore_imports, glob)
	end
end

local function setup ()
	if sup then return end
	sup = true

	vsc.recommend_extensions('JohnnyMorganz.luau-lsp')
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
