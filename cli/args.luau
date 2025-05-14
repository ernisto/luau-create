local process = require('@lune/process')

local args = {}
export type args = { [any]: string | boolean }

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
			args[key] = key_value
			index += 1
		end
	else
		table.insert(args, value)
	end
until value == nil

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
	current = args :: args,
	split = split,
}
