local process = require('@lune/process')

local args: args = {}
export type args = { [string | number]: { string } | string }
-- { [string]: {string} }
-- { [number]: string }

local index = 0
repeat
	index += 1
	local value = process.args[index]
	if not value then break end

	local key = value:match('^%-%-(.*)')
	if key then
		local key_value = process.args[index + 1]
		if not key_value or key_value:match('^%-%-') then
			args[key] = {}
		else
			local current_value = args[key] :: string
			if type(current_value) == 'table' then
				table.insert(current_value, key_value)
			elseif type(current_value) == 'nil' then
				args[key] = key_value
			else
				args[key] = { current_value, key_value }
			end
			index += 1
		end
	else
		table.insert(args :: any, value)
	end
until value == nil

-- methods
local function get_str(args: args, key: string | number): string?
	local value = args[key]
	return if type(value) == 'table' then value[1] else value
end
local function get_num(args: args, key: string | number): number?
	return tonumber(get_str(args, key) or '')
end
local function get_bool(args: args, key: string): boolean
	return args[key] ~= nil
end

local function get_strs(args: args, key: string): { string }
	local values = args[key]
	return if type(values) == 'table' then values else { values :: any }
end

local function split(args: args): { string }
	local tokens = {}
	for key, value in args do
		if type(key) == 'string' then
			table.insert(tokens, `--{key}`)
			if #value == 0 then continue end
		end
		table.insert(tokens, tostring(value))
	end
	return tokens
end

-- module
return table.freeze {
	current = args,

	get_strs = get_strs,
	get_bool = get_bool,
	get_num = get_num,
	get_str = get_str,
	split = split,
}
