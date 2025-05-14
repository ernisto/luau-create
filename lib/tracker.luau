local git = require('@tools/git')

-- functions
type glob = string
local function ignore_globs (...: glob)
	git.ignore_globs(...)
end
type attribute = string
local function set_attribute (glob: glob, ...: attribute)
	git.set_attribute(glob, ...)
end

-- module
return table.freeze {
	set_attribute = set_attribute,
	ignore_globs = ignore_globs,
}
