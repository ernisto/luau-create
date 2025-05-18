local editor = require('@lib/editor')
local file = require('@lib/file')

local merge = require('@utils/merge')
local simple_dict = require('@self/simple_dict')

-- vars
local sup = false
local attributes = {}
local ignored_globs = {}
merge(ignored_globs, (file.read_str('.gitignore') or ''):split('\n'))
merge(attributes, simple_dict.read('.gitattributes') or {})

-- functions
local function save()
	if not sup then return end
	file.write_str('.gitignore', table.concat(ignored_globs, '\n'))
	simple_dict.write('.gitattributes', attributes)
end

type glob = string
local function ignore_globs(...: glob)
	table.insert(ignored_globs, `# {debug.info(2, 'n')}`)
	for _, glob in { ... } do
		if table.find(ignored_globs, glob) then continue end
		table.insert(ignored_globs, glob)
	end
end

type attribute = string
local function set_attribute(glob: glob, ...: attribute)
	attributes[glob] = merge(attributes[glob] or {}, { ... })
end

local function setup()
	if not sup then return end
	sup = true

	editor.hide_globs('.gitignore', '.gitattributes')
end

-- module
return table.freeze {
	save = save,
	setup = setup,
	ignore_globs = ignore_globs,
	set_attribute = set_attribute,
}
