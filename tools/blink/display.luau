local color = require('./color')
local stackColors = {
    color.yellow,
    color.green,
    color.dark_blue,
}

local function isPos(tab) return type(tab) == 'table' and tab.absolute and tab.column and tab.line end
local function isArray(tab) return type(tab) == 'table' and type(next(tab) :: any) == 'number' end
local function isNode(tab) return type(tab) == 'table' and rawget(tab, 'kind') end
local function isSyntaxNode(tab) return type(tab) == 'table' and rawget(tab, 'nextClauses') end
-- local function isParserSymbol(tab)
--     if type(tab) ~= 'table' then return false end
--     local kind = rawget(tab, 'kind')
--     return kind == 'leaf_parser_symbol'
--         or kind == 'parent_parser_symbol'
-- end

local function display(value: any, stack)

    stack = stack or {}
    table.insert(stack, value)

    if stack[value] then

        return color.bold(`depth({stack[value]}) {value}`)
    end

    local start = string.rep('   ', #stack)
    local stackColor = stackColors[1+ #stack % #stackColors]
    local out = color.blue(tostring(value))

    if isPos(value) then

        out = stackColor('(')
            .. color.blue(value.absolute)
            .. color.red('|')
            .. color.blue(value.column)
            .. color.red(':')
            .. color.blue(value.line)
            .. stackColor(')')

    elseif isArray(value) then

        stack[value] = #stack
        out = stackColor('[')

        for index, value in value do
            
            out ..= '\n'..start
                ..display(value, stack)
        end
        out ..= '\n'
            ..start:sub(1+3)
            ..stackColor(']')

    -- elseif isParserSymbol(value) then
        
    --     local symbolPath = if value.def then value.def.path else value.path or { kind = 'read_var', name = 'node' }
    --     return color.pink(value.kind)
    --         .. stackColor(`(`)
    --         .. color.blue(table.concat(path.arrayfy(symbolPath), '.'))
    --         .. stackColor(`)`)

    elseif isNode(value) then

        stack[value] = #stack

        local nodes = {}
        out = color.pink(if typeof(value.kind) == 'string' then value.kind else 'token')
            ..stackColor('(')

        if value.start and value.final then
            out ..= color.white('position')
                ..color.dark_red('=')
                ..color.blue(tostring(value.start.absolute))
                ..color.blue('..')
                ..color.blue(tostring(value.final.absolute))
                ..color.dark_red(', ')
        end

        for index, value in value do

            if index == 'kind' or index == 'start' or index == 'final' then continue
            elseif type(value) == 'table' then
                
                nodes[index] = value
                continue
            end
            out ..= color.white(index)
                ..color.dark_red('=')
                ..color.blue(if type(value) == 'string' then `'{value}'` else tostring(value))
                ..color.dark_red(', ')
        end

        if next(nodes) then out ..= '\n' end
        for index, node in nodes do
            
            out ..= start
                ..color.bold(index)
                ..color.dark_red(' ')
                ..display(node, stack)
                ..'\n'
        end
        if next(nodes)
            then out ..= start:sub(1+3)
            else out = out:sub(1, -10)
        end
        out ..= stackColor(')')

    elseif isSyntaxNode(value) then
        
        stack[value] = #stack

        local clauses = value.nextClauses
        out = stackColor('(')

        --// data
        for index, value in value do

            if index == 'kind' then continue end
            if index == 'nextClauses' then continue end

            out ..= color.white(index)
                ..color.dark_red('=')
                ..color.blue(display(value, stack))
                ..color.dark_red(', ')
        end

        --// clauses
        if next(clauses) then out ..= '\n' end
        for clause, node in clauses do
            
            out ..= start
                ..color.dark_red(`{if clause.checkKind then 'kind' else 'raw'} `)
                ..display(clause.checkRaw or clause.checkKind)
                ..' '
                ..display(node, stack)
                ..'\n'
        end
        if next(clauses)
            then out ..= start:sub(1+3)
            else out = out:sub(1, -10)
        end
        out ..= stackColor(')')

        -- stack[value] = nil

    elseif type(value) == 'table' then

        out = stackColor('[]')

    elseif type(value) == 'string' then

        out = color.blue(`'{value}'`)
    end
    table.remove(stack)
    return out
end
return display