local git = require('@tools/git')

-- functions
type glob = string
local function ignore_globs(...: glob)
    git.ignore_globs(...)
end

-- module
return table.freeze {
    ignore_globs = ignore_globs
}
