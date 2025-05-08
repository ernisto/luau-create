local lexer = require('@self/lexer')
local expect_char = lexer.expect_char
local scan_word = lexer.scan_word
local scan_str = lexer.scan_str

local misc = require('@self/misc')
local parse_list = misc.parse_list
local parse_expr = misc.parse_expr

local def = require('@self/def')
local parse_def = def.parse_def
type def = def.def

-- statements
local parse_statement

export type option = { kind: 'option', name: string, value: misc.expr }
local function parse_option()
    if not scan_word('option') then return end

    local name = scan_word() or warn(`expected identifier`)
    expect_char('=')

    local expr = parse_expr() or warn(`expected expr`)
    return { kind = 'option', name = name, value = expr }
end

export type import = { kind: 'import', path: string, name: string }
local function parse_import()
    if not scan_word('import') then return end
    local path = scan_str() or warn(`expected string`)
    local name
    if scan_word('as') then
        name = scan_word() or warn(`expected identifier`)
    end
    return { kind = 'import', path = path, name = name }
end

export type scope = { kind: 'scope', name: string, statements: {statement} }
local function parse_scope()
    if not scan_word('scope') then return end
    local name = scan_word() or warn(`expected identifier`)

    expect_char('{')
    local statements = parse_list(parse_statement)

    expect_char('}')
    return { kind = 'scope', name = name, statements = statements }
end

type statement = option | import | scope | def
function parse_statement()
    return parse_option()
        or parse_import()
        or parse_scope()
        or parse_def()
end

-- main
local function parse(str: string)
    lexer.lex(str)
    return parse_list(parse_statement)
end

-- module
return table.freeze {
    parse = parse
}