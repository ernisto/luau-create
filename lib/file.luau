local serde = require('@lune/serde')
local fs = require('@lune/fs')

-- functions
export type path = string
local function ensure_existing_chain(path: string, file_name: string?)
	local ancestors = string.split(path, '/')

	local safe_dir = ''
	local missing_dir

	for index, name in ancestors do
        if name == '' then break end
		safe_dir ..= name .. '/'

		if missing_dir == nil and fs.isDir(safe_dir) then continue end
		missing_dir = path:sub(#safe_dir - #name)

		fs.writeDir(safe_dir)
	end
    if not file_name then return end
    safe_dir ..= file_name

	if missing_dir or not fs.isFile(safe_dir) then
        fs.writeFile(safe_dir, "")
    end
end

export type data = { [string]: any }
local function read_str(path: path): string?
    local dir, file = string.match(path, "(.*)/([^/]+)$")

    ensure_existing_chain(dir or '', file or path)
    return fs.readFile(path)
end
local function read_toml(path: path): data?
    local str = read_str(path)
    return str and str ~= '' and serde.decode('toml', str)
end
local function read_json(path: path): data?
    local str = read_str(path)
    return str and str ~= '' and serde.decode('json', str)
end
local function read_yaml(path: path): data?
    local str = read_str(path)
    return str and str ~= '' and serde.decode('yaml', str)
end

local function write_str(path: path, str: string)
    local dir, file = string.match(path, "(.*)/([^/]+)$")

    ensure_existing_chain(dir or '', file or path)
    return fs.writeFile(path, str)
end
local function write_toml(path: path, data: data)
    write_str(path, serde.encode('toml', data, true))
end
local function write_json(path: path, data: data)
    write_str(path, serde.encode('json', data, true))
end
local function write_yaml(path: path, data: data)
    write_str(path, serde.encode('yaml', data, true))
end

-- module
return table.freeze {
    read_str = read_str,
    read_toml = read_toml,
    read_json = read_json,
    read_yaml = read_yaml,

    write_str = write_str,
    write_toml = write_toml,
    write_json = write_json,
    write_yaml = write_yaml,
}
