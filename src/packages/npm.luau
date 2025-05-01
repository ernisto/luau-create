local project = require('@lib/project')
local file = require('@lib/file')
local git = require('@lib/git')

local serde = require('@lune/serde')

-- functions
local function setup()
    local manifest = project.manifest
    git.ignore_globs('package manager (node)', {
        'node_modules',
    })
    file.add('package.json', serde.encode('json', {
        name = manifest.name,
        version = manifest.version,
        description = manifest.description,
        main = "src/index.luau",
        author = manifest.host,
        license = manifest.license,
        homepage = "https://github.com/ernisto/binvo#readme",
        repository = { type = "git", url = "git+https://github.com/ernisto/binvo.git" },
        bugs = { url = "https://github.com/ernisto/binvo/issues" },
        directories = { test = "tests" },
    }))
end
local function build()
end

-- module
return table.freeze {
    setup = setup,
    build = build,
}