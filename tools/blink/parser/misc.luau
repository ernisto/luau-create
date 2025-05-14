local lexer = require('@self/lexer')
local scan_word = lexer.scan_word
local scan_char = lexer.scan_char
local scan_num = lexer.scan_num
local scan_str = lexer.scan_str
local scan_raw = lexer.scan_raw

export type expr = builtin | str | num
type str = { kind: 'str', value: string }
type num = { kind: 'num', value: number }
type builtin = { kind: 'builtin', value: string }

local function parse_expr (): expr?
	local num = scan_num()
	if num then return table.freeze { kind = 'num', value = tonumber(num) } :: any end

	local str = scan_str()
	if str then return table.freeze { kind = 'str', value = str } :: any end

	local word = scan_word()
	if word then return table.freeze { kind = 'builtin', value = word } :: any end

	return
end

local function parse_list <T>(parse: () -> T?): { T }
	local nodes = {}
	repeat
		local expr = parse()
		if expr then
			table.insert(nodes, expr)
			scan_char(',')
		end
	until expr == nil

	return nodes
end

export type range = { min: number?, max: number? }
local function parse_range (): range?
	local min = scan_num()
	local mid = scan_raw('..')

	if not min and not mid then return end
	local max = mid and scan_num()

	return { min = if min then tonumber(min) or error('impossible') else nil, max = tonumber(max) }
end

-- module
return table.freeze {
	parse_range = parse_range,
	parse_list = parse_list,
	parse_expr = parse_expr,
}
