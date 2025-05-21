local color = require('@self/color')

local stack_colors = {
	color.yellow,
	color.green,
	color.dark_blue,
}

-- defs
type stack = { [any]: any }

-- vars
local string_color = color.light_yellow
local num_color = color.blue
local boolean_color = color.yellow

-- functions
local function is_array<V>(tab: V): boolean
	return typeof(tab) == 'table' and typeof(next(tab) :: any) == 'number'
end
local function is_node<V>(tab: V): boolean
	return typeof(tab) == 'table' and rawget(tab, 'kind') ~= nil
end

local function display(value: any, _stack: stack?): string
	local stack = (_stack and table.clone(_stack) or {}) :: stack
	table.insert(stack, value)

	if typeof(value) == 'table' and stack[value] then return color.bold(`depth({stack[value]}) {value}`) end

	local start = string.rep('    ', #stack)
	local stack_color = stack_colors[1 + #stack % #stack_colors]
	local out = color.blue(tostring(value))

	if is_array(value) then
		stack[value] = #stack
		out = stack_color('[')

		local outputs = {}
		for _, value in value do
			table.insert(outputs, display(value, stack))
		end

		if string.len(table.concat(outputs)) > 100 then
			out ..= `\n{start .. table.concat(outputs, `\n{start}`)}` .. `\n{start:sub(5) .. stack_color(']')}`
		else
			out ..= ` {table.concat(outputs, ', ')} ` .. stack_color(`]`)
		end
	elseif is_node(value) then
		stack[value] = #stack

		local nodes = {}
		out = color.pink(if typeof(value.kind) == 'string' then value.kind else 'token') .. stack_color('(')

		for index, value in value do
			if index == 'kind' then continue end

			if typeof(value) == 'table' then
				nodes[index] = value
				continue
			end

			out ..= color.white(index) .. color.dark_red('=') .. color.blue(
				if typeof(value) == 'string' then `'{value}'` else tostring(value)
			) .. color.dark_red(', ')
		end

		if next(nodes) then
			out ..= '\n'
		end
		for index, node in nodes do
			out ..= start .. color.bold(index) .. color.dark_red(' ') .. display(node, stack) .. '\n'
		end
		if next(nodes) then
			out ..= start:sub(5)
		else
			out = out:sub(1, -10)
		end
		out ..= stack_color(')')
	elseif typeof(value) == 'table' then
		stack[value] = #stack
		out = stack_color('{')

		local outputs = {}
		for index, value in value do
			table.insert(outputs, color.white(tostring(index)) .. color.dark_red(' = ') .. display(value, stack))
		end

		if string.len(table.concat(outputs)) > 100 then
			out ..= `\n{start .. table.concat(outputs, `,\n{start}`)}` .. `\n{start:sub(5) .. stack_color('}')}`
		else
			out ..= ` {table.concat(outputs, ', ')} ` .. stack_color('}')
		end
	elseif typeof(value) == 'string' then
		out = string_color(`'{value}'`)
	elseif typeof(value) == 'number' then
		out = num_color(tostring(value))
	elseif typeof(value) == 'boolean' then
		out = boolean_color(tostring(value))
	end

	table.remove(stack)
	return out
end
local function json(str: string)
	local out = str

	local key_colors = {
		color.blue,
		color.yellow,
		color.purple,
	}
	local key_count = 0
	-- color number, pontuations, brackets
	out = string.gsub(out, '.', function(char)
		if char == '{' or char == '}' or char == '[' or char == ']' then
			if char == '{' or char == '[' then
				key_count += 1
			end
			local stack_color = key_colors[1 + key_count % #key_colors]
			if char == '}' or char == ']' then
				key_count -= 1
			end
			return stack_color(char)
		elseif char == '.' or char == ',' or char == ':' then
			return color.white(char)
		elseif tonumber(char) then
			return color.light_green(char)
		end

		return char
	end)
	-- color builtin
	out = string.gsub(out, 'true', color.blue('true'))
	out = string.gsub(out, 'false', color.blue('false'))
	out = string.gsub(out, 'null', color.blue('null'))
	-- color properties
	out = string.gsub(out, '".-"%s*:', function(char)
		return string.gsub(char, '".-"', function(str)
			return color.cyan(str)
		end)
	end)
	-- color string values
	out = string.gsub(out, ':%s*".-"', function(char)
		return string.gsub(out, '".-"', function(str)
			return color.dark_yellow(char)
		end)
	end)
	return out
end

return {
	display = display,
	json = json,
}
