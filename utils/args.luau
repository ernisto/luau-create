local process = require('@lune/process')

local args = {}

local index = 1
while process.args[index] ~= nil do
	local value = process.args[index]

	if value:match('^%-%-') then
		index += 1
		value = value:gsub('^%-%-', '')
		local next_value = process.args[index]
		args[value] = next_value
	else
		table.insert(args, value)
	end
	index += 1
end

return table.freeze(args :: { [any]: any })
