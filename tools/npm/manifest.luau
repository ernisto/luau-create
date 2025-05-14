local file = require('@lib/file')
local license = require('@lib/project/licenses')
local merge = require('@utils/merge')

-- defs
type overrides = { [string]: string | overrides }
type funding = {
	type: 'patreon' | 'individual',
	url: url,
}

export type cpu =
	'arm'
	| 'arm64'
	| 'ia32'
	| 'loong64'
	| 'mips'
	| 'mipsel'
	| 'ppc'
	| 'ppc64'
	| 'riscv64'
	| 's390'
	| 's390x'
	| 'x64'
export type os = 'aix' | 'darwin' | 'freebsd' | 'linux' | 'openbsd' | 'sunos' | 'win32'
export type people = string | {
	name: string,
	email: string,
	url: url,
}

type url = string
type path = string
type glob = string
type version = string
type scope_name = string
type dependency = string
export type manifest = {
	name: scope_name?,
	version: version?,
	description: string?,
	license: license.license_name?,
	keywords: { string },

	exports: { [string]: glob },
	files: { glob },

	browser: path?,
	main: path?,

	contribuitors: { people },
	author: people?,

	bin: { [string]: path }?,
	man: { path }?,
	directories: { lib: path?, doc: path?, man: path? },

	publishConfig: { [string]: any },
	scripts: { [string]: path },
	config: { [string]: any },

	dependencies: { [scope_name]: dependency },
	devDependencies: { [scope_name]: dependency },
	peerDependencies: { [scope_name]: dependency },
	peerDependenciesMeta: { [scope_name]: { optional: boolean } },
	optionalDependencies: { [scope_name]: dependency },
	bundleDependencies: { dependency },
	overrides: overrides,

	engines: { [string]: version },
	devEngines: { [string]: { name: string, version: version?, onFail: 'warn' | 'error' | 'ignore'? } },
	workspaces: { path },
	cpu: { cpu },
	os: { os },
	libc: path?,

	private: boolean?,
	homepage: url?,
	funding: url | { url | funding }?,
	bugs: {
		email: string?,
		url: url?,
	}?,
	repository: url | {
		type: 'git',
		url: url?,
		directory: path?,
	}?,
}

-- module
local manifest: manifest = {
	keywords = {},
	contribuitors = {},
	directories = {},
	files = {},
	workspaces = {},
	publishConfig = {},
	scripts = {},
	config = {},
	dependencies = {},
	devDependencies = {},
	peerDependencies = {},
	peerDependenciesMeta = {},
	bundleDependencies = {},
	optionalDependencies = {},
	overrides = {},
	engines = {},
	devEngines = {},
	exports = {},
	os = {},
	cpu = {},
	-- coloca td q for table aq, pq fica mais facil de manipular sem if
	-- tem coisa q pode ser string ou table
}
merge(manifest, file.read_json('package.json') or {})

-- end
return manifest
