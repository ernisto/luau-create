local cst = require('./cst')
local lexer = require('./lexer')
local scan_char = lexer.scan_char
local scan_str = lexer.scan_str
local scan_num = lexer.scan_num
local scan_word = lexer.scan_word
local expect_char = lexer.expect_char
local report = lexer.report

-- functions
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
			finish = lexer.get_cursor_position(),
		}
	end

	if word == 'true' then
		return {
			kind = 'value',
			value = true,
			raw = 'true',
			start = start,
			finish = lexer.get_cursor_position(),
		}
	end

	if word == 'false' then
		return {
			kind = 'value',
			value = false,
			raw = 'false',
			start = start,
			finish = lexer.get_cursor_position(),
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
		finish = lexer.get_cursor_position(),
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
		finish = lexer.get_cursor_position(),
	}
end

local function parse_array(): cst.array_node?
	local start = lexer.get_cursor_position()
	if not scan_char('[') then return end

	local elements = {}

	while true do
		local element = parse_value()
		if not element then break end

		table.insert(elements, element)
		if not scan_char(',') then break end
	end

	expect_char(']')
	return {
		kind = 'array',
		elements = elements,
		start = start,
		finish = lexer.get_cursor_position(),
	}
end

local function parse_object(): cst.object_node?
	local start = lexer.get_cursor_position()
	if not scan_char('{') then return nil end

	local properties = {}

	while true do
		local key = scan_str()
		if not key then break end

		if not expect_char(':') then return end

		local value = parse_value()
		if not value then
			report('Valor esperado')
			return nil
		end

		table.insert(properties, {
			kind = 'property' :: any,
			key = key,
			value = value,
			start = start,
			finish = lexer.get_cursor_position(),
		})

		if not scan_char(',') then break end
	end

	expect_char('}')
	return {
		kind = 'object',
		properties = properties,
		start = start,
		finish = lexer.get_cursor_position(),
	}
end

function parse_value(): cst.node?
	return parse_literal() or parse_string() or parse_number() or parse_array() or parse_object()
end

local function parse(str: string): cst.node
	lexer.lex(str)
	local value = parse_value()
	if not value then return report('Valor JSON esperado') end
	return value
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
