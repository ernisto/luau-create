local aftman = require('@tools/aftman')
local foreman = require('@tools/foreman')
local npm = require('@tools/npm')
local pesde = require('@tools/pesde')
local rokit = require('@tools/rokit')

-- functions
local function install_github(scope: string, name: string, version: string)
	foreman.install_github(scope, name, version)
	aftman.install_github(scope, name, version)
	rokit.install_github(scope, name, version)
end
local function install_pesde(scope: string, name: string, version: string, registry_url: string?)
	pesde.manifest.dev_dependencies[name] =
		{ index = 'default', name = `{scope}/{name}`, version = version, target = 'lune' }
end
local function install_npm(scope: string, name: string, version: string)
	npm.manifest.devDependencies[`{scope}/{name}`] = version
end

-- module
return table.freeze {
	install_github = install_github,
	install_pesde = install_pesde,
	install_npm = install_npm,
}
