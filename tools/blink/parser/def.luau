local lexer = require('@self/lexer')
local expect_char = lexer.expect_char
local scan_char = lexer.scan_char
local scan_word = lexer.scan_word
local scan_str = lexer.scan_str
local report = lexer.report

local type_expr = require('@self/type_expr')
type type_expr = type_expr.type_expr
type field = type_expr.field
local parse_field_block = type_expr.parse_field_block
local parse_type_expr = type_expr.parse_type_expr

local remote_def = require('./remote_def')
type event_def = remote_def.event_def
local parse_event_def = remote_def.parse_event_def

local parse_func_def = remote_def.parse_func_def
type func_def = remote_def.func_def

local misc = require('@self/misc')
local parse_list = misc.parse_list
type expr = misc.expr

-- helpers
export type type_params_def = { string }
function parse_type_params_def (): type_params_def?
	if not scan_char('<') then return end
	local args = parse_list(scan_word)

	expect_char('>')
	return args
end

-- defs
export type alias_def = { kind: 'alias', name: string, value: type_expr }
local function parse_alias_def (): alias_def?
	if not scan_word('type') then return end

	local name = scan_word() or report(`expected identifier`)
	expect_char('=')

	local expr = parse_type_expr() or report(`expected type`)
	return { kind = 'alias', name = name, value = expr }
end

export type enum_option = { name: string, fields: { field }? }
local function parse_enum_option (): enum_option?
	local name = scan_word()
	if not name then return end

	local fields = parse_field_block()
	return { name = name, fields = fields }
end

export type enum_def = {
	kind: 'enum',
	name: string,
	kind_field_name: string?,
	params: type_params_def?,
	expr: type_expr.enum_expr | type_expr.suffix,
}
local function parse_enum_def (): enum_def?
	if not scan_word('enum') then return end

	local name = scan_word() or report(`expected identifier`)
	local params = parse_type_params_def()

	expect_char('=')
	local kind_field_name = scan_str()

	expect_char('{')
	local options = parse_list(parse_enum_option)

	expect_char('}')
	local expr = parse_type_expr { kind = 'enum', options = options }

	return { kind = 'enum', name = name, kind_field_name = kind_field_name, params = params, expr = expr :: any }
end

export type struct_def = {
	kind: 'struct',
	name: string,
	params: type_params_def?,
	expr: type_expr.struct_expr | type_expr.suffix,
}
local function parse_struct_def (): struct_def?
	if not scan_word('struct') then return end
	local name = scan_word() or report(`expected identifier`)
	local params = parse_type_params_def()

	local fields = parse_field_block() or report(`expected '\{'`)
	local expr = parse_type_expr { kind = 'struct', fields = fields }

	return { kind = 'struct', name = name, params = params, expr = expr :: any }
end

export type set_def = { kind: 'set', name: string, expr: type_expr.set_expr | type_expr.suffix }
local function parse_set_def (): set_def?
	if not scan_word('set') then return end
	local name = scan_word() or report(`expected identifier`)

	expect_char('=')
	expect_char('{')
	local flags: { string } = parse_list(scan_word)

	expect_char('}')
	local expr = parse_type_expr { kind = 'set', flags = flags }

	return { kind = 'set', name = name, expr = expr :: any }
end

export type map_def = { kind: 'map', name: string, params: type_params_def?, expr: type_expr.map_expr | type_expr.suffix }
local function parse_map_def (): map_def?
	if not scan_word('map') then return end
	local name = scan_word() or report(`expected identifier`)
	local params = parse_type_params_def()

	expect_char('=')
	expect_char('{')

	expect_char('[')
	local key = parse_type_expr() or report(`expected type`)
	expect_char(']')

	expect_char(':')
	local value = parse_type_expr() or report(`expected type`)

	expect_char('}')
	local expr = parse_type_expr { kind = 'map', key = key, value = value }

	return { kind = 'map', name = name, params = params, expr = expr :: any }
end

export type export_def = { kind: 'export', def: def }
local function parse_export_def (): export_def?
	if not scan_word('export') then return end
	local def = parse_struct_def()
		or parse_alias_def()
		or parse_enum_def()
		or parse_set_def()
		or parse_map_def()
		or report(`expected definition`)

	return { kind = 'export', def = def }
end

export type def = struct_def | alias_def | export_def | event_def | func_def | enum_def | set_def | map_def
function parse_def (): def?
	return parse_struct_def()
		or parse_alias_def()
		or parse_export_def()
		or parse_event_def()
		or parse_func_def()
		or parse_enum_def()
		or parse_set_def()
		or parse_map_def()
end

-- module
return table.freeze {
	parse_def = parse_def,
}
