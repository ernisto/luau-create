-- 0.0.1	-- luneTypes.d.luau
-- 0.5.0	-- docs/luneTypes.d.luau
-- 0.6.2	-- docs/typedefs/*
-- 0.7.5	-- types/*  -- PascalCase
-- 0.7.8    -- types/*  -- lowercase
-- 0.9.0	-- crates/**/types.d.luau

local semver = require('@utils/semver')
local task = require('@lune/task')
local v1 = require('@tools/lune/type_defs/v1')
local v2 = require('@tools/lune/type_defs/v2')
local v3 = require('@tools/lune/type_defs/v3')

-- functions
local function write_type_defs_async(str: string)
	local version = semver(str)
	return v3.write_type_defs_async(version)
		or v2.write_type_defs_async(version)
		or task.spawn(v1.await_write_type_defs, version)
end

-- module
return table.freeze {
	write_type_defs_async = write_type_defs_async,
}
