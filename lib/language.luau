local lsp = require('@tools/lsp')
local luau = require('@tools/luau')

-- functions
type glob = string
type path = string
local function ignore_import_globs(...: glob)
	lsp.ignore_import_globs(...)
end
local function ignore_diagnostic_globs(...: glob)
	lsp.ignore_diagnostic_globs(...)
end
local function add_global_def(path: string, def_file_path: path)
	lsp.add_def_files(def_file_path)
end
local function add_globals(...: string)
	for _, global in { ... } do
		if table.find({ ... }, global) then continue end
		table.insert(luau.rc.globals, global)
	end
end
local function add_alias(alias: string, path: string)
	luau.add_alias(alias, path)
end

-- module
return table.freeze {
	ignore_diagnostic_globs = ignore_diagnostic_globs,
	ignore_import_globs = ignore_import_globs,
	add_global_def = add_global_def,
	add_globals = add_globals,
	add_alias = add_alias,
}
