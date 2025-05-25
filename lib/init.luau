local editor = require('@lib/editor')
local language = require('@lib/language')
local package_manager = require('@lib/packages')
local project = require('@lib/project')
local tasks = require('@lib/tasks')

local tools = table.freeze {

	-- libs
	uilabs = nil, -- require('@tools/uilabs'),
	testez = nil, -- require('@tools/testez'),

	-- docs
	moonwave = nil, -- require('@tools/moonwave')
	mkdocs = nil, --require('@tools/mkdocs')

	-- environment
	lune = require('@tools/lune'),
	roblox = require('@tools/roblox'),
	asphalt = require('@tools/asphalt'),
	mantle = nil, -- require('@tools/mantle'),
	darklua = nil, -- require('@tools/darklua'),
	argon = nil, -- require('@tools/argon'),
	rojo = require('@tools/rojo'),
	blink = require('@tools/blink'),
	zap = nil, -- require('@tools/zap'),

	-- package
	foreman = require('@tools/foreman'),
	aftman = require('@tools/aftman'),
	rokit = require('@tools/rokit'),
	pesde = require('@tools/pesde'),
	wally = require('@tools/wally'),
	npm = require('@tools/npm'),

	-- language
	luau = require('@tools/luau'),
	lsp = require('@tools/lsp'),
	selene = require('@tools/selene'),
	stylua = require('@tools/stylua'),

	-- editor
	github = require('@tools/github'),
	git = require('@tools/git'),
	vsc = require('@tools/vsc'),
}

-- functions
local function save()
	for _, tool: any in tools do
		tool.save()
	end
end

-- module
return table.freeze {
	save = save,
	project = project,
	language = language,
	package_manager = package_manager,
	editor = editor,
	tasks = tasks,
	tools = tools,
}
