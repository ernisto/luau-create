local lexer = require('@self/lexer')
local scan_word = lexer.scan_word
local scan_char = lexer.scan_char
local expect_char = lexer.expect_char

local type_expr = require('@self/type_expr')
type type_expr = type_expr.type_expr
type field = type_expr.field
local parse_type_expr = type_expr.parse_type_expr

local misc = require('@self/misc')
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
        options[string.lower(name)] = value
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
    return expr.kind == 'array' or expr.kind == 'map' or expr.kind == 'optional' or expr.kind == 'attribute' or expr.kind == 'read_type' or expr.kind == 'struct' or expr.kind == 'tuple' and expr or warn(`expected type`)
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

-- module
return table.freeze {
    parse_event_def = parse_event_def,
    parse_func_def = parse_func_def,
}
