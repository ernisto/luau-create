local file = require('@lib/file')

local ignores = {}

local function setup()
end
local function build()
    file.add('.gitignore', table.concat(ignores, '\n'))
end

local function ignore_globs(section: string, globs: { string })
    table.insert(ignores, `# {section}`)
    table.move(globs, 1, #globs, #ignores + 1, ignores)
    table.insert(ignores, '')
end

return table.freeze {
    setup = setup,
    build = build,
    ignore_globs = ignore_globs,
}