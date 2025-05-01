local project = require('@lib/project')
local file = require('@lib/file')
local git = require('@lib/git')

local serde = require('@lune/serde')

-- functions
local function setup()
    git.ignore_globs('package manager (wally)', {
        'ServerPackages',
        'DevPackages',
        'Packages',
    })
    file.add('wally.toml', serde.encode('toml', {
        
    }))
end
local function build()
end

-- module
return table.freeze {
    setup = setup,
    build = build,
}