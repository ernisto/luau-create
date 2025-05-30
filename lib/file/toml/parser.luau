local cst = require('./cst')
local lexer = require('./lexer')
local scan_word = lexer.scan_word
local scan_str = lexer.scan_str
local scan_num = lexer.scan_num
local scan_char = lexer.scan_char
local expect_char = lexer.expect_char
local report = lexer.report

-- functions
local parse_value

local function parse_list<V>(parser: () -> V?, separator: string?): { V }
	local fields = {} :: { V }
	repeat
		local value = parser()
		if not value then break end

		table.insert(fields, value)
		if separator and not scan_char(separator) then break end
	until false

	return fields
end

local function parse_property(): cst.property_node?
	local start = lexer.get_cursor_position()
	local key = scan_word()
	if not key then return end

	if not expect_char('=') then return end
	local value = parse_value()
	if not value then return end
	return {
		kind = 'property',
		key = key,
		value = value,
		start = start,
		finish = lexer.get_final(),
	}
end

local function parse_literal(): cst.value_node?
	local start = lexer.get_cursor_position()
	local word = scan_word()
	if not word then return end

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

	local elements = parse_list(parse_value, ',')
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
	if not scan_char('{') then return end

	local properties = parse_list(parse_property, ',')
	expect_char('}')
	return {
		kind = 'object',
		properties = properties,
		start = start,
		finish = lexer.get_final(),
	}
end

function parse_value(): cst.node?
	return parse_string() or parse_number() or parse_array() or parse_object() or parse_literal()
end

local function parse_block(): cst.block_node?
	local start = lexer.get_cursor_position()

	local path = {}
	if scan_char('[') then
		path = parse_list(scan_word, '.')
		if not next(path) then return report('expected identifier') end
		expect_char(']')
	end

	local properties = parse_list(parse_property)
	if not next(properties) then return end
	return {
		kind = 'block',
		path = path,
		properties = properties,
		start = start,
		finish = lexer.get_final(),
	}
end

local function parse(str: string): { cst.block_node }?
	lexer.lex(str)
	local value = parse_list(parse_block)
	if not next(value) then return report('Valor TOML esperado') end
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
