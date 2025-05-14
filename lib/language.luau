local project = require('@lib/project').project
local file = require('@lib/file')

local lsp = require('@tools/lsp')
local luau = require('@tools/luau')

-- functions
type glob = string
local function ignore_import_globs (...: glob)
	lsp.ignore_import_globs(...)
end
local function ignore_diagnostic_globs (...: glob)
	lsp.ignore_diagnostic_globs(...)
end
local function add_globals (...: string)
	for _, global in { ... } do
		if table.find({ ... }, global) then continue end
		table.insert(luau.rc.globals, global)
	end
end
local function add_alias (alias: string, path: string)
	luau.add_alias(alias, path)
end

local function setup ()
	if project.entrypoint then
		file.write_default_str(project.entrypoint .. '/init.luau')
		add_alias(project.entrypoint, project.entrypoint)
	end
	for alias, dir in project.directories do
		file.write_default_str(dir .. '/init.luau')
		add_alias(alias, dir)
	end
end

-- module
return table.freeze {
	setup = setup,
	ignore_diagnostic_globs = ignore_diagnostic_globs,
	ignore_import_globs = ignore_import_globs,
	add_globals = add_globals,
	add_alias = add_alias,
}
