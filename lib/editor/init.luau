local vsc = require("./vsc")

-- defs
type glob = string

-- functions
local function save()
    vsc.save()
end

local function hide_globs(...: glob)
    vsc.hide_globs(...)
end
local function locks_glob(...: glob)
    vsc.lock_globs(...)
end

-- module
return table.freeze {
    save = save,
    vsc = vsc,
    hide_globs = hide_globs,
    lock_globs = locks_glob,
}
