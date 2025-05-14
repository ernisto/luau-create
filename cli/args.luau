local process = require('@lune/process')

local args: args = {}
export type args = { [any]: { string } | string | boolean }

local index = 0
repeat
	index += 1
	local value = process.args[index]
	if not value then break end

	local key = value:match('^%-%-(.*)')
	if key then
		local key_value = process.args[index + 1]
		if not key_value or key_value:match('^%-%-') then
			args[key] = true
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
		table.insert(args, value)
	end
until value == nil

-- methods
local function get_arg(args: args, key: string | number): string | boolean
	local value = args[key]
	return if type(value) == 'table' then value[1] else value
end
local function get_args(args: args, key: string): { string }
	local values = args[key]
	return if type(values) == 'table' then values else { values :: any }
end
local function split(args: args): { string }
	local tokens = {}
	for key, value in args do
		if type(key) == 'string' then
			table.insert(tokens, `--{key}`)
			if value == true then continue end
		end
		table.insert(tokens, tostring(value))
	end
	return tokens
end

-- module
return table.freeze {
	current = args,

	get_args = get_args,
	get_arg = get_arg,
	split = split,
}
