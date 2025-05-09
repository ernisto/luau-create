local lexer = require('./lexer')
local expect_char = lexer.expect_char
local scan_char = lexer.scan_char
local scan_word = lexer.scan_word
local scan_raw = lexer.scan_raw

local misc = require('./misc')
local parse_range = misc.parse_range
local parse_list = misc.parse_list
local parse_expr = misc.parse_expr
type expr = misc.expr
type range = misc.range

local parse_type_expr

-- suffixes
export type array = { kind: 'array', expr: type_expr, range: range? }
local function parse_array(atom: type_expr): array?
    if not scan_char('[') then return end
    local range = parse_range()

    expect_char(']')
    return { kind = 'array', expr = atom, range = range }
end

export type attribute = { kind: 'attribute', expr: type_expr, value: range | expr }
local function parse_attribute(atom: type_expr): attribute?
    if not scan_char('(') then return end
    local value = parse_range() or parse_expr() or warn(`expression expected`)

    expect_char(')')
    return { kind = 'attribute', expr = atom, value = value }
end

export type optional = { kind: 'optional', expr: type_expr }
local function parse_optional(atom: type_expr): optional?
    return scan_char('?') and { kind = 'optional', expr = atom }
end

export type suffix = optional | attribute | array
local function parse_suffix(atom: type_expr): suffix?
    return parse_array(atom)
        or parse_attribute(atom)
        or parse_optional(atom)
end

-- atom
export type tuple_expr = { kind: 'tuple', exprs: {type_expr} }
local function parse_tuple_expr(): tuple_expr?
    if not scan_char('(') then return end
    local exprs = parse_list(parse_type_expr)

    expect_char(')')
    return { kind = 'tuple', exprs = exprs } :: any
end

export type map_expr = { kind: 'map', key: type_expr, value: type_expr }
local function parse_map_expr(): map_expr?
    if not scan_word('map') then return end
    expect_char('{')

    expect_char('[')
    local key = parse_type_expr() or warn(`expected expr`)
    expect_char(']')

    expect_char(':')
    local value = parse_type_expr() or warn(`expected expr`)

    expect_char('}')
    return { kind = 'map', key = key, value = value }
end

export type struct_expr = { kind: 'struct', fields: {field} }
local function parse_struct_expr(): struct_expr?
    return scan_word('struct') and { kind = 'struct', fields = parse_field_block() or {} }
end

export type read_type = { kind: 'read_type', names: {string}, args: {type_expr}? }
local function parse_read_type(): read_type?
    local name = scan_word()
    if not name then return end

    local names = {name}
    while scan_char('.') do
        name = scan_word() or warn(`identifier expected`)
        table.insert(names, name)
    end

    local args
    if scan_char('<') then
        args = parse_list(parse_type_expr)
        expect_char('>')
    end

    return name and { kind = 'read_type', names = names, args = args }
end

export type type_expr = struct_expr | tuple_expr | read_type | map_expr | suffix
function parse_type_expr(): type_expr?
    local atom: type_expr? = parse_struct_expr()
        or parse_tuple_expr()
        or parse_read_type()
        or parse_map_expr()

    while atom do
        local suffix = parse_suffix(atom)
        if not suffix then return atom end
        atom = suffix
    end
    return
end

-- helpers
export type named_field = { kind: 'field', name: string, type: type_expr }
local function parse_named_field(): named_field?
    local name = scan_word()
    if not name then return end

    expect_char(':')
    local type_expr = parse_type_expr() or warn(`expected type expr`)

    return { kind = 'field', name = name, type = type_expr } :: any
end

export type merge_field = { kind: 'merge', type: type_expr }
local function parse_merge_field(): merge_field?
    if not scan_raw('..') then return end
    local expr = parse_type_expr() or warn(`expected type`)
    return { kind = 'merge', type = expr }
end

export type field = named_field | merge_field
local function parse_field(): field?
    return parse_named_field() or parse_merge_field()
end

export type field_block = {field}
function parse_field_block(): field_block?
    if not scan_char('{') then return end
    local fields = parse_list(parse_field)

    expect_char('}')
    return fields
end

-- module
return table.freeze {
    parse_field_block = parse_field_block,
    parse_type_expr = parse_type_expr,
    parse_field = parse_field,
}
