local editor = require('@lib/editor')
local language = require('@self/language')
local package_manager = require('@lib/packages')
local project = require('@lib/project')
local tools = table.freeze {

	-- docs
	-- moonwave = require('@tools/moonwave')
	-- mkdocs = require('@tools/mkdocs')

	-- environment
	lune = require('@tools/lune'),
	roblox = require('@tools/roblox'),
	blink = require('@tools/blink'),
	-- darklua = require('@tools/darklua'),
	-- argon = require('@tools/argon'),
	rojo = require('@tools/rojo'),
	-- zap = require('@tools/zap'),

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
local function save ()
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
	tools = tools,
}
