local process = require('@lune/process')

local args = {}

local index = 0
repeat
	index += 1
	local value = process.args[index]
	if not value then break end

	local key = value:match('^%-%-(.*)')
	if key then
		local key_value = process.args[index + 1]
		if key_value:match('^%-%-') then
			args[key] = true
		else
			args[key] = key_value
			index += 1
		end
	else
		table.insert(args, value)
	end
until value == nil

return table.freeze(args :: { [any]: string | boolean })
