local io = require('@lune/stdio')
local semver = require('@pkg/semver')

local args = require('@cli/args')
local current_args = args.current

-- defs
export type struct<Output = unknown> = { name: string, desc: string?, optional: true? }

export type enum<Output = string> = {
	name: string,
	default_index: number?,
	desc: string?,
	optional: true?,
	[number]: option<Output>,
}
export type selections<Output = string> = {
	name: string,
	default_indexes: { number }?,
	desc: string?,
	[number]: option<Output>,
}
export type option<Output = string> = { name: string, value: Output?, desc: string? }

export type num<Output = number> = {
	name: string,
	default: number?,
	desc: string?,
	optional: true?,
	parse: nil | (number) -> Output?,
}
export type bool<Output = boolean> = {
	name: string,
	default: boolean?,
	desc: string?,
	optional: true?,
	parse: nil | (boolean) -> Output?,
}
export type str<Output = string, Input = string> = {
	name: string,
	default: Input?,
	desc: string?,
	optional: true?,
	parse: nil | (Input) -> Output,
}
export type question<Output = unknown> = (struct<Output> | enum<Output> | bool<Output> | str<Output>) & { kind: string }

-- functions
local function parse_identifier(input: string)
	return string.match(input, '^%s*([-_%w]+)%s*$') or error(`invalid identifier (\\[-_A-z0-9]+\\)`)
end
local function parse_version(input: string)
	return semver.parse(input):unpack() or error(`you must to enter a version (n.n.n)`)
end
local function parse_number(value: string): number
	return tonumber(value) or error(`you must to enter a number`)
end
local function parse_integer(value: string): number
	assert(string.match(value, '^%d+$'), `you must to enter a integer number`)
	return tonumber(value) or error(`you must to enter a number`)
end
local function sparse_unpack(t)
	local higher_index = 0
	for i, v in t do
		if type(i) == 'number' and i // 1 == i and i > higher_index then higher_index = i end
	end
	local output = {}
	for index = 1, higher_index do
		table.insert(output, t[index])
	end
	return unpack(output)
end

local function get_indexes(options: { option }, values: { any }): { number }
	local indexes = {}
	local option_values = {}

	for i, option in options do
		option_values[i] = option.value or option.name
	end

	for _, value in values do
		local index = table.find(option_values, value)
		if not index then
			warn(`invalid option '{value}', availables: {table.concat(option_values, ' | ')}`)
			continue
		end
		table.insert(indexes, index)
	end
	return indexes
end
local function get_index(options: { option }, value: any): number
	local option_values = {}
	for i, option in options do
		option_values[i] = option.value or option.name
	end
	return table.find(option_values, value) :: any
end

-- constructors
local function prompt_text<value>(question: str<value>): value
	local value = current_args[question.name] or (current_args.yes and question.default)
	repeat
		local out = value
			or io.prompt('text', question.name, if question.default == nil then '' else tostring(question.default))

		value = nil :: any
		if question.parse then
			local success, result = pcall(question.parse, out)
			if success then return result end

			io.ewrite(tostring(result))
			continue
		end
		return if question.optional and out == '' then nil else out
	until false
end
local function prompt_enum<value>(question: enum<value>): value?
	local options = { sparse_unpack(question) }
	local names = {}
	for i, option in options do
		names[i] = option.name
	end

	-- core options
	local none_id, undo_id, help_id: number?
	if question.optional then
		table.insert(names, 'none')
		none_id = #names
	end
	if question.desc then
		table.insert(names, 'help') -- TO IMPROVE
		help_id = #names
	end
	table.insert(names, 'undo')
	undo_id = #names

	-- default
	local default_value = if current_args[question.name]
		then get_index(options :: any, args.get_str(current_args, question.name))
		elseif current_args.yes then question.default_index or 1
		else nil

	if current_args[question.name] and default_value == nil then
		warn(`invalid option {question.name} value '{current_args[question.name]}'`)
		default_value = nil
	end

	-- loop
	repeat
		local index = default_value or io.prompt('select', question.name, names)

		if none_id and index == none_id then
			return nil
		elseif index == undo_id then
			print('NEED IMPLEMENTATION')
			continue
		elseif help_id and index == help_id then
			table.remove(names, help_id)
			undo_id -= 1
			help_id = nil

			print(question.desc)
			for i, option in options do
				names[i] = `{option.name} {io.color('white')}{option.desc or ''}`
			end
			continue
		end
		return options[index].value or options[index].name :: any
	until false
end
local function prompt_selections<value>(question: selections<value>): value?
	local options = { sparse_unpack(question) }
	local names = {}
	for i, option in options do
		names[i] = option.name
	end

	-- core options
	local undo_id, help_id: number?
	if question.desc then
		table.insert(names, 'help') -- TO IMPROVE
		help_id = #names
	end
	table.insert(names, 'undo')
	undo_id = #names

	-- default
	local default_value = if current_args[question.name]
		then get_indexes(options :: any, args.get_strs(current_args, question.name))
		elseif current_args.yes then question.default_indexes or {}
		else nil

	if current_args[question.name] and default_value == nil then
		warn(`invalid option {question.name} value '{current_args[question.name]}'`)
		default_value = nil
	end

	-- loop
	repeat
		local indexes = default_value or io.prompt('multiselect', question.name, names)

		if table.find(indexes, undo_id) then
			print('NEED IMPLEMENTATION')
			continue
		elseif help_id and table.find(indexes, help_id) then
			table.remove(names, help_id)
			undo_id -= 1
			help_id = nil

			print(question.desc)
			for i, option in options do
				names[i] = `{option.name} {io.color('white')}{option.desc or ''}`
			end
			continue
		end

		local values = {}
		for _, index in indexes do
			table.insert(values, options[index].value or options[index].name)
		end

		return values :: any
	until false
end

local function inquisitor(output: { [string]: any })
	local self = {}

	function self.bool(prop: bool)
		local value = if current_args[prop.name] ~= nil
			then args.get_bool(current_args, prop.name)
			elseif current_args.yes then prop.default
			else io.prompt('confirm', prop.name, prop.default or output[prop.name])

		output[prop.name] = value
		return value
	end
	function self.int(prop: num)
		prop.parse = parse_integer :: any
		prop.default = prop.default or output[prop.name]

		local value = prompt_text(prop :: any)
		output[prop.name] = value

		return value
	end
	function self.num(prop: num)
		prop.parse = parse_number :: any
		prop.default = prop.default or output[prop.name]

		local value = prompt_text(prop :: any)
		output[prop.name] = value

		return value
	end
	function self.str(prop: str)
		prop.parse = prop.parse
		prop.default = prop.default or output[prop.name]

		local value = prompt_text(prop)
		output[prop.name] = value

		return value
	end
	function self.identifier(prop: str)
		prop.parse = parse_identifier
		prop.default = prop.default or output[prop.name]

		local value = prompt_text(prop)
		output[prop.name] = value

		return value
	end
	function self.version(prop: str<semver.ParseError>)
		prop.parse = parse_version :: any
		prop.default = prop.default or output[prop.name]

		local value = prompt_text(prop)
		output[prop.name] = value

		return value
	end
	function self.enum(prop: enum)
		local options = { sparse_unpack(prop) }
		prop.default_index = prop.default_index or get_index(options, output[prop.name])

		local value = prompt_enum(prop)
		output[prop.name] = value

		return value
	end
	function self.multiselect(prop: selections)
		local options = { sparse_unpack(prop) }
		prop.default_indexes = prop.default_indexes or output[prop.name] and get_indexes(options, output[prop.name])

		local value = prompt_selections(prop)
		output[prop.name] = value

		return value
	end
	function self.struct(prop: struct)
		if output[prop.name] == nil then output[prop.name] = {} end
		return inquisitor(output[prop.name])
	end

	return self
end

-- end
type inquisitor = typeof(inquisitor)
return inquisitor :: inquisitor
