local file = require('@lib/file')
local merge = require('@utils/merge')

-- defs
type glob = string
type path = string
type WebAsset = { id: number }

-- module
type manifest = {
	creator: {
		type: 'user' | 'group',
		id: number,
	},
	codegen: {
		typescript: boolean?,
		style: 'flat' | 'nested'?,
		strip_extensions: boolean?,
	},
	inputs: {
		assets: {
			path: glob,
			output_path: path,
			web: { [string]: WebAsset },
			bleed: boolean?,
		},
	},
}
local manifest: manifest = {
	creator = {
		type = 'user',
		id = 0,
	},
	codegen = {
		strip_extensions = true,
		typescript = false,
		style = 'nested',
	},
	inputs = {
		assets = {
			path = 'assets/**/*.(!rbxm|!rbxmx)',
			output_path = 'assets',
			web = {},
		},
	},
}
merge(manifest, file.read_toml('asphalt.toml') or {})

-- end
return manifest
