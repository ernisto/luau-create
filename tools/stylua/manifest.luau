local file = require("@lib/file")
local merge = require('@utils/merge')

type syntax = 'All' | 'Lua51' | 'Lua52' | 'Lua53' | 'Lua54' | 'LuaJIT' | 'Luau' | 'CfxLua'
type quote_style = 'AutoPreferDouble' | 'AutoPreferSingle' | 'ForceDouble' | 'ForceSingle'
type call_parentheres = 'Always' | 'NoSingleString' | 'NoSingleTable' | 'None' | 'Input'
export type manifest = {
    syntax: syntax?,
    column_width: number?,
    line_endings: 'Unix' | 'Windows'?,
    ident_type: 'Tabs' | 'Space'?,
    ident_width: number?,
    quote_style: quote_style?,
    call_parentheses: call_parentheres?,
    space_after_function_names: 'Never' | 'Definitions' | 'Calls' | 'Always'?,
    collapse_simple_statement: 'Never' | 'FunctionOnly' | 'Conditionaly' | 'Always'?,
    sort_requires: { enabled: boolean }?,
}

-- module
local manifest: manifest = {}
merge(manifest, file.read_toml('stylua.toml') or {}, file.read_toml('.stylua.toml') or {})

-- end
return manifest