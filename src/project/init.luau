local questionary = require('questionary')
local question = require('@lib/question')

local manifest = {}

-- functions
local function setup()

	local output = question.prompt(questionary)
	for i, v in output do manifest[i] = v end

	print(manifest)
end

-- module
return table.freeze {
	manifest = manifest,
    setup = setup,
}