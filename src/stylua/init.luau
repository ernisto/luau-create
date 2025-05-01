local serde = require('@lune/serde')

local questionary = require('questionary')
local question = require('@lib/question')
local file = require('@lib/file')

-- functions
local function setup()
    file.add('stylua.toml', serde.encode('toml', question.prompt(questionary)))
end

-- module
return table.freeze {
    setup = setup
}