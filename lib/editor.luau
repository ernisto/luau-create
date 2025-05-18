local vsc = require('@tools/vsc')

-- functions
type glob = string
local function hide_globs(...: glob)
	vsc.hide_globs(...)
end
local function lock_globs(...: glob)
	vsc.lock_globs(...)
end

local function setup()
	lock_globs('*.lock', '*-lock.*', '*.lock.*')
	hide_globs('*.lock', '*-lock.*', '*.lock.*')
end

-- module
return table.freeze {
	setup = setup,

	hide_globs = hide_globs,
	lock_globs = lock_globs,
}
