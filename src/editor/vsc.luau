local fs = require('@lune/fs')
local serde = require('@lune/serde')
local types = require('@lib/types')

local hidden_files = {}
local recommended_extensions = {}

-- functions
local function build(root_path: types.path)

    fs.writeDir(`{root_path}/.vscode`)
    fs.writeFile(`{root_path}/.vscode/settings.json`, serde.encode('json', {
        ['files.exclude'] = hidden_files
    }))
    fs.writeFile(`{root_path}/.vscode/settings.json`, serde.encode('json', {
        ['recommendations'] = recommended_extensions
    }))
end

-- module
return table.freeze {
    build = build,
    hidden_files = hidden_files,
    recommended_extensions = recommended_extensions,
}