local lexer = require('./lexer')
local scan_word = lexer.scan_word
local scan_num = lexer.scan_num
local scan_str = lexer.scan_str
local scan_char = lexer.scan_char
local expect_char = lexer.expect_char

export type expr = bool | str | num
type str = { kind: 'str', value: string }
type num = { kind: 'num', value: number }
type bool = { kind: 'bool', value: boolean }

local parse_field_block

local function parse_expr(): expr?
    local num = scan_num()
    if num then return table.freeze { kind = 'num', value = tonumber(num) } :: any end

    local str = scan_str()
    if str then return table.freeze { kind = 'str', value = str } :: any end

    return if scan_word('true') then table.freeze { kind = 'bool', value = true } :: any
        elseif scan_word('false') then table.freeze { kind = 'bool', value = false } :: any
        else nil
end

export type struct_expr = { fields: {field} }
local function parse_struct_expr()
    if not scan_word('struct') then return end
    return { fields = parse_field_block() }
end

export type read_type = { kind: 'read_type', name: string }
local function parse_read_type()
    local name = scan_word()
    if not name then return end
    return { kind = 'read_type', name = name }
end

export type type_expr = struct_expr | read_type
local function parse_type_expr()
    return parse_struct_expr() or parse_read_type()
end

export type field = { kind: 'field', name: string, type: type_expr }
local function parse_field(): field?

    local name = scan_word()
    if not name then return end

    expect_char(':')
    local type_expr = parse_type_expr() or warn(`expected type expr`)

    return { kind = 'field', name = name, type = type_expr } :: any
end

function parse_field_block(): {field}?

    if not scan_char('{') then return end

    local fields = {}
    repeat
        local field = parse_field()
        if field then table.insert(fields, field) end
    until field == nil

    expect_char('}')
    return fields
end

export type option = { kind: 'option', name: string, value: expr }
local function parse_option()
    if not scan_word('option') then return end
    local name = scan_word() or warn(`expected identifier`)
    expect_char('=')
    local expr = parse_expr() or warn(`expected expr`)
    return table.freeze { kind = 'option', name = name, value = expr }
end
local function parse_type_def()
    if not scan_word('type') then return end
    local name = scan_word()
    expect_char('=')
    local expr = parse_expr()
    return table.freeze { kind = 'option', name = name, value = expr}
end
local function parse_func_def()
    if not scan_word('function') then return end
    local name = scan_word()

    local fields = parse_field_block() or warn("expected '{'")
    return table.freeze { kind = 'option', name = name, fields = fields }
end
local function parse_event_def()
    if not scan_word('event') then return end
    local name = scan_word() or warn(`expected identifier`)
    local fields = parse_field_block() or warn("expected '{'")
    return table.freeze { kind = 'option', name = name, fields = fields }
end
local function parse_enum_def()
    if not scan_word('enum') then return end
    local name = scan_word() or warn(`expected identifier`)
    local expr = parse_expr() or warn(`expected expr`)
    return table.freeze { kind = 'option', name = name, value = expr}
end
local function parse_struct_def()
    if not scan_word('struct') then return end
    local name = scan_word() or warn(`expected identifier`)
    local fields = parse_field_block() or warn(`expected '\{'`)
    return table.freeze { kind = 'option', name = name, fields = fields }
end

export type def = option
local function parse_def()
    return parse_type_def()
        or parse_func_def()
        or parse_event_def()
        or parse_enum_def()
        or parse_struct_def()
end

export type block = { defs: {def} }
local function parse_block(): block
    local defs = {}
    repeat
        local def = parse_option() or parse_def()
        if def then table.insert(defs, def) end
    until def == nil

    return table.freeze {
        defs = defs,
    }
end

local function parse(str: string)
    lexer.lex(str)
    return parse_block()
end

return table.freeze {
    parse = parse
}