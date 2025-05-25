local editor = require('@lib/editor')
local file = require('@lib/file')
local project = require('@lib/project').project
local tracker = require('@lib/tracker')

-- defs
type luaurc = {
	languageMode: 'strict' | 'nonstrict' | 'nocheck'?,
	lintErrors: boolean?,
	typeErrors: boolean?,
	aliases: { [string]: string },
	globals: { string },
	lint: { [string]: boolean },
}

-- vars
local sup = false
local rc = require('@self/rc')

-- functions
local function save()
	if not sup then return end
	file.write_json('.luaurc', rc)
end

local function add_alias(alias: string, path: string)
	if rc.aliases[alias] and rc.aliases[alias] ~= path then warn(`alias '{alias}' already defined`) end
	rc.aliases[alias] = path
end

local function setup()
	if sup then return end
	sup = true

	editor.hide_globs('.luaurc')
	tracker.set_attribute('*.luau', 'text')

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
	rc = rc,
	save = save,
	setup = setup,
	add_alias = add_alias,
}
