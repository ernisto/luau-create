local cst = require('./cst')
local lexer = require('./lexer')
local scan_char = lexer.scan_char
local scan_str = lexer.scan_str
local scan_num = lexer.scan_num
local scan_word = lexer.scan_word
local expect_char = lexer.expect_char
local report = lexer.report

-- functions
local parse_value

local function parse_literal(): cst.value_node?
	local start = lexer.get_cursor_position()
	local word = scan_word()
	if not word then return end

	if word == 'null' then
		return {
			kind = 'value',
			value = nil,
			raw = 'null',
			start = start,
			finish = lexer.get_final(),
		}
	end

	if word == 'true' then
		return {
			kind = 'value',
			value = true,
			raw = 'true',
			start = start,
			finish = lexer.get_final(),
		}
	end

	if word == 'false' then
		return {
			kind = 'value',
			value = false,
			raw = 'false',
			start = start,
			finish = lexer.get_final(),
		}
	end

	report(`unexpected literal '{word}'`)
	return nil
end

local function parse_string(): cst.value_node?
	local start = lexer.get_cursor_position()
	local str = scan_str()
	if not str then return end

	return {
		kind = 'value',
		value = str,
		raw = '"' .. str .. '"',
		start = start,
		finish = lexer.get_final(),
	}
end

local function parse_number(): cst.value_node?
	local start = lexer.get_cursor_position()
	local num = scan_num()
	if not num then return end

	return {
		kind = 'value',
		value = tonumber(num),
		raw = num,
		start = start,
		finish = lexer.get_final(),
	}
end

local function parse_array(): cst.array_node?
	local start = lexer.get_cursor_position()
	if not scan_char('[') then return end

	local elements = {}
	repeat
		local value = parse_value()
		if not value then break end

		local comma = scan_char(',')
		local comma_position = lexer.get_final()

		table.insert(elements, {
			kind = 'element',
			start = value.start,
			finish = if comma then comma_position else value.finish,
			value = value,
			comma = comma and { kind = 'token' :: any, start = comma_position, finish = comma_position },
		})
	until comma == nil

	expect_char(']')
	return {
		kind = 'array',
		elements = elements,
		start = start,
		finish = lexer.get_final(),
	}
end

local function parse_object(): cst.object_node?
	local start = lexer.get_cursor_position()
	if not scan_char('{') then return nil end

	local properties = {}

	while true do
		local init = lexer.get_cursor_position()
		local key = scan_str()
		if not key then break end

		if not expect_char(':') then return end

		local value = parse_value()
		if not value then
			report('Valor esperado')
			return nil
		end

		local f = lexer.get_final()
		local comma_position = lexer.get_cursor_position()
		local comma = scan_char(',')

		table.insert(properties, {
			kind = 'property' :: any,
			key = key,
			value = value,
			start = init,
			finish = f,
			comma = comma and { kind = 'token', start = comma_position, finish = comma_position },
		})
		if not comma then break end
	end

	expect_char('}')
	return {
		kind = 'object',
		properties = properties,
		start = start,
		finish = lexer.get_final(),
	}
end

function parse_value(): cst.value_node?
	return parse_literal() or parse_string() or parse_number() or parse_array() or parse_object()
end

local function parse(str: string): cst.value_node?
	lexer.lex(str)
	return parse_value()
end

return table.freeze({
	parse = parse,
	parse_literal = parse_literal,
	parse_string = parse_string,
	parse_number = parse_number,
	parse_array = parse_array,
	parse_object = parse_object,
	parse_value = parse_value,
})
