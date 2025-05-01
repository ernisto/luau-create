local io = require('@lune/stdio')
local file = require('file')

local project = require('project')
local stylua = require('stylua')
local git = require('git')

local pesde = require('@lib/packages/pesde')
local wally = require('@lib/packages/wally')

project.setup()

local package_manager = io.prompt('select', `package manager`, {'pesde', 'wally'})
if package_manager == 1 then pesde.setup() else wally.setup() end

local toolchain_manager = io.prompt('select', `toolchain manager`, {'pesde', 'rokit', 'aftman', 'foreman'})
if toolchain_manager == 1 and package_manager ~= 1 then pesde.setup()
else end

local github_actions = io.prompt('confirm', `setup github actions ?`, true)

if io.prompt('confirm', `setup stylua ?`, true) then
    stylua.setup()
end

-- stylua.build()
git.build()
file.build()
