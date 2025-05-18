local luau = require('@tools/luau')
local lune = require('@tools/lune')
local project = require('@lib/project')
local roblox = require('@tools/roblox')

-- functions
local function setup()
	luau.setup()
	if project.project.environment == 'lune' then
		lune.setup()
	elseif project.project.environment == 'roblox' then
		roblox.setup()
	end
end

-- module
return table.freeze {
	setup = setup,
}
