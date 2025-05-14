local lexer = require('@self/lexer')
local expect_char = lexer.expect_char
local scan_char = lexer.scan_char
local scan_word = lexer.scan_word
local report = lexer.report

local type_expr = require('@self/type_expr')
type type_expr = type_expr.type_expr
type field = type_expr.field
local parse_type_expr = type_expr.parse_type_expr

local misc = require('@self/misc')
local parse_expr = misc.parse_expr
type expr = misc.expr

-- utils
local function parse_options (): { [string]: expr | type_expr }
	expect_char('{')
	local options = {}
	repeat
		local name = scan_word()
		if not name then break end

		name = string.lower(name)

		expect_char(':')
		local value = if name == 'data' or name == 'return'
			then parse_type_expr() or report(`type expected for '{name}'`)
			else parse_expr() or report(`option expected for '{name}'`)

		scan_char(',')
		options[name] = value
	until name == nil

	expect_char('}')
	return options
end
local function expect_enum (expr: expr | type_expr?, ...: string): string?
	if not expr then return end
	local value = expr.kind == 'builtin' and string.lower(expr.value) or nil

	return value and table.find({ ... }, value) and value
		or report(`expected string \'{table.concat({ ... }, "' | '")}\', got {value}`)
end
local function expect_type_expr (expr: expr | type_expr?): type_expr?
	if not expr then return end
	return (
		expr.kind == 'array'
		or expr.kind == 'map'
		or expr.kind == 'optional'
		or expr.kind == 'attribute'
		or expr.kind == 'read_type'
		or expr.kind == 'struct'
		or expr.kind == 'tuple'
	)
			and expr
		or report(`expected type`)
end

-- defs
export type func_def = {
	kind: 'func',
	name: string,
	yield: 'coroutine' | 'promise' | 'future',
	data: type_expr?,
	output: type_expr?,
}
local function parse_func_def (): func_def?
	if not scan_word('function') then return end
	local name = scan_word() or report(`expected identifier`)

	local options = parse_options()
	return {
		kind = 'func',
		name = name,
		yield = expect_enum(options.yield, 'coroutine', 'promise', 'future') :: any,
		data = expect_type_expr(options.data),
		output = expect_type_expr(options['return']),
	}
end

export type event_def = {
	kind: 'event',
	name: string,
	from: 'client' | 'server',
	type: 'reliable' | 'unreliable',
	poll: boolean?,
	call: 'singlesync' | 'singleasync' | 'manysync' | 'manyasync',
	data: type_expr?,
}
local function parse_event_def (): event_def?
	if not scan_word('event') then return end
	local name = scan_word() or report(`expected identifier`)

	local options = parse_options()
	return {
		kind = 'event',
		name = name,
		from = expect_enum(options.from, 'server', 'client') :: any,
		type = expect_enum(options.type, 'reliable', 'unreliable') :: any,
		call = expect_enum(options.call, 'singlesync', 'singleasync', 'manysync', 'manyasync') :: any,
		poll = options.poll and expect_enum(options.poll, 'true', 'false') == 'true',
		data = expect_type_expr(options.data),
	}
end

-- module
return table.freeze {
	parse_event_def = parse_event_def,
	parse_func_def = parse_func_def,
}
