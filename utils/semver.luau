local semver = require('@pkg/semver')

-- module
local function version(label: string): semver.SemverImpl
	return semver.parse(label):unwrap()
end

export type Version = semver.SemverImpl
return version
