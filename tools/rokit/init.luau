local editor = require('@lib/editor')
local file = require('@lib/file')
local merge = require('@utils/merge')
local vsc = require('@tools/vsc')

-- vars
local sup = false
local tools = {}
merge({ tools = tools }, file.read_toml('rokit.toml') or {})

-- functions
local function save()
	if not sup then return end
	file.write_toml('rokit.toml', { tools = tools })
end

local function install_github(scope: string, name: string, version: string)
	tools[name] = `{scope}/{name}@{version}`
end

local function setup()
	if sup then return end
	sup = true

	vsc.recommend_extensions('filiptibell.deputy')
	editor.hide_globs('rokit.toml')
end

-- module
return table.freeze {
	save = save,
	setup = setup,
	tools = tools,
	install_github = install_github,
}
