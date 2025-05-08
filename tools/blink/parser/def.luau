--!nolint LocalUnused

local lexer = require('@self/lexer')
local scan_word = lexer.scan_word
local scan_num = lexer.scan_num
local scan_str = lexer.scan_str
local scan_char = lexer.scan_char
local scan_raw = lexer.scan_raw
local expect_char = lexer.expect_char

local type_expr = require('@self/type_expr')
type type_expr = type_expr.type_expr
type field = type_expr.field
local parse_field_block = type_expr.parse_field_block
local parse_type_expr = type_expr.parse_type_expr
local parse_generic_expr = type_expr.parse_generic_expr

local misc = require('@self/misc')
local parse_list = misc.parse_list
local parse_expr = misc.parse_expr
type expr = misc.expr

-- utils
local function parse_options(): { [string]: expr | type_expr }
    expect_char('{')
    local options = {}
    repeat
        local name = scan_word()
        if not name then break end

        expect_char(':')
        local value = parse_expr() or parse_type_expr() or warn(`type expected`)

        scan_char(',')
        options[name] = value
    until name == nil

    expect_char('}')
    return options
end
local function expect_str_enum(expr: expr | type_expr,...: string): string
    return expr.kind == 'str' and table.find({...}, expr.value)
        and expr.value or warn(`expected string \'{table.concat({...}, '\' | \'')}\'`)
end
local function expect_bool(expr: expr | type_expr): boolean
    if expr.kind ~= 'builtin' then return warn(`expected boolean`) end
    return expr.value == 'true' or expr.value == 'false' or warn(`expected boolean`) or false
end
local function expect_type_expr(expr: expr | type_expr): type_expr
    return expr.kind == 'array' or expr.kind == 'map' or expr.kind == 'optional' or expr.kind == 'ranged' or expr.kind == 'read_type' or expr.kind == 'struct' or expr.kind == 'tuple' and expr or warn(`expected type`)
end

-- defs
export type func_def = {
    kind: 'func',
    name: string,
    yield: 'Coroutine'|'Promise'|'Future',
    data: type_expr?,
    output: type_expr?
}
local function parse_func_def(): func_def?
    if not scan_word('function') then return end
    local name = scan_word() or warn(`expected identifier`)

    local options = parse_options()
    return {
        kind = 'func',
        name = name,
        yield = expect_str_enum(options.yield, 'Coroutine', 'Promise', 'Future') :: any,
        data = expect_type_expr(options.data),
        output = expect_type_expr(options.output)
    }
end

export type event_def = {
    kind: 'event',
    name: string,
    from: 'Client'|'Server',
    type: 'Reliable'|'Unreliable',
    poll: boolean?,
    call: 'SingleSync'|'SingleAsync'|'ManySync'|'ManyAsync',
    data: type_expr?
}
local function parse_event_def(): event_def?
    if not scan_word('event') then return end
    local name = scan_word() or warn(`expected identifier`)

    local options = parse_options()
    return {
        kind = 'event',
        name = name,
        from = expect_str_enum(options.from, 'Server', 'Client') :: any,
        type = expect_str_enum(options.yield, 'Reliable', 'Unreliable') :: any,
        call = expect_str_enum(options.yield, 'SingleSync', 'SingleAsync', 'ManySync', 'ManyAsync') :: any,
        poll = options.poll and expect_bool(options.poll),
        data = expect_type_expr(options.data),
    }
end

export type alias_def = { kind: 'alias', name: string, value: type_expr }
local function parse_alias_def(): alias_def?
    if not scan_word('type') then return end

    local name = scan_word() or warn(`expected identifier`)
    expect_char('=')

    local expr = parse_type_expr() or warn(`expected type`)
    return { kind = 'alias', name = name, value = expr}
end

export type enum_option = { name: string, fields: {field}? }
local function parse_enum_option(): enum_option?
    local name = scan_word()
    if not name then return end

    local fields = parse_field_block()
    return { name = name, fields = fields }
end

export type enum_def = { kind: 'enum', name: string, options: {enum_option} }
local function parse_enum_def(): enum_def?
    if not scan_word('enum') then return end

    local name = scan_word() or warn(`expected identifier`)
    expect_char('=')

    expect_char('{')
    local options = parse_list(parse_enum_option)

    expect_char('}')
    return { kind = 'enum', name = name, options = options }
end

export type struct_def = { kind: 'struct', name: string, fields: type_expr.field_block, generics: type_expr.generic_expr? }
local function parse_struct_def(): struct_def?
    if not scan_word('struct') then return end
    local name = scan_word() or warn(`expected identifier`)
    local generics = parse_generic_expr()

    local fields = parse_field_block() or warn(`expected '\{'`)
    return { kind = 'struct', name = name, fields = fields, generics = generics }
end

export type set_def = { kind: 'set', name: string, flags: {string} }
local function parse_set_def(): set_def?
    if not scan_word('set') then return end
    local name = scan_word() or warn(`expected identifier`)

    expect_char('{')
    local flags: {string} = parse_list(scan_word)

    expect_char('}')
    return { kind = 'set', name = name, flags = flags }
end

export type map_def = { kind: 'map', key: type_expr, value: type_expr }
local function parse_map_def(): map_def?
    if not scan_word('map') then return end
    local name = scan_word()

    expect_char('=')
    expect_char('{')

    expect_char('[')
    local key = parse_type_expr() or warn(`expected type`)
    expect_char(']')

    expect_char(':')
    local value = parse_type_expr() or warn(`expected type`)

    expect_char('}')
    return { kind = 'map', key = key, value = value }
end

export type def = struct_def | alias_def | event_def | func_def | enum_def | set_def | map_def
local function parse_def(): def?
    return parse_struct_def()
        or parse_alias_def()
        or parse_event_def()
        or parse_func_def()
        or parse_enum_def()
        or parse_set_def()
        or parse_map_def()
end

-- module
return table.freeze {
    parse_def = parse_def
}
