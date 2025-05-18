local file = require('@lib/file')
type content = { [string]: { string } }

-- functions
local function decode(raw: string): content
	local lines = string.split(raw, '\n')
	local dict = {}

	for _, line in lines do
		local key, raw_values = line:match('(%S+)%s*=%s*(.*)')
		if not raw_values then continue end
		if not key then continue end

		local values = {}
		for value in string.gmatch(raw_values, '%S+') do
			table.insert(values, value)
		end
		dict[key] = values
	end
	return dict
end
local function encode(content: content)
	local raw = ''
	for glob, attributes in content do
		raw ..= `{glob}`
		for attribute, value in attributes do
			raw ..= '\t' .. (if type(attribute) == 'string' then attribute .. '=' else '') .. tostring(value)
		end
		raw ..= '\n'
	end
	return raw
end

local function write(path: file.path, content: content)
	file.write_str(path, encode(content))
end
local function read(path: file.path)
	local str = file.read_str(path)
	return str and decode(str)
end

-- module
return table.freeze {
	decode = decode,
	encode = encode,
	write = write,
	read = read,
}
