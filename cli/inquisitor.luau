local semver = require("@pkg/semver")
local io = require('@lune/stdio')

-- defs
export type struct<Output = unknown> = { name: string, desc: string?, optional: true? }

export type enum<Output = string> = { name: string, default_index: number?, desc: string?, optional: true?, [number]: option<Output> }
export type option<Output = string> = { name: string, value: Output?, desc: string? }

export type num<Output = number> = { name: string, default: number?, desc: string?, optional: true?, parse: nil|(number) -> Output? }
export type bool<Output = boolean> = { name: string, default: boolean?, desc: string?, optional: true?, parse: nil|(boolean) -> Output? }
export type str<Output = string, Input = string> = { name: string, default: Input?, desc: string?, optional: true?, parse: nil|(Input) -> Output }
export type question<Output = unknown> = (struct<Output> | enum<Output> | bool<Output> | str<Output>) & { kind: string }

-- functions
local function parse_identifier(input: string)
    return string.match(input, "^%s*([-_%w]+)%s*$") or error(`invalid identifier (\\[-_A-z0-9]+\\)`)
end
local function parse_version(input: string)
    return semver.parse(input):unpack() or error(`you must to enter a version (n.n.n)`)
end
local function parse_number(value: string): number
    return tonumber(value) or error( `you must to enter a number`)
end
local function parse_integer(value: string): number
    assert(string.match(value, '^%d+$'), `you must to enter a integer number`)
    return tonumber(value) or error(`you must to enter a number`)
end
local function sparse_unpack(t)
    local higher_index = 0
    for i, v in t do
        if type(i) == 'number' and i // 1 == i and i > higher_index then higher_index = i end
    end
    local output = {}
    for index = 1, higher_index do
        table.insert(output, t[index])
    end
    return unpack(output)
end

-- constructors
local function prompt_text<value>(question: str<value>): value
    repeat
        local out = io.prompt('text', question.name, if question.default == nil then '' else tostring(question.default))

        if question.parse then
            local success, result = pcall(question.parse, out)
            if success then return result end

            io.ewrite(tostring(result))
            continue
        end
        return if question.optional and out == '' then nil else out
    until false
end
local function prompt_enum<value>(question: enum<value>): value?
    local options = {sparse_unpack(question)}
    local names = {}
    for i, option in options do
        names[i] = option.name
    end

    -- core options
    local none_id, undo_id, help_id: number?
    if question.optional then
        table.insert(names, 'none')
        none_id = #names
    end
    if question.desc then
        table.insert(names, 'help') -- TO IMPROVE
        help_id = #names
    end
    table.insert(names, 'undo')
    undo_id = #names

    -- loop
    repeat
        local index = io.prompt('select', question.name, names)
        if index == none_id then
            return nil
        elseif index == undo_id then
            print('NEED IMPLEMENTATION')
            continue
        elseif index == help_id then
            table.remove(names, help_id)
            undo_id -= 1
            help_id = nil

            print(question.desc)
            for i, option in options do
                names[i] = `{option.name} {io.color('white')}{option.desc or ''}`
            end
            continue
        end
        return options[index].value or options[index].name :: any
    until false
end

local function inquisitor(output: { [string]: any })
    
    local self = {}
    
    function self.bool(prop: bool)
        local value = io.prompt('confirm', prop.name, prop.default or output[prop.name])
        output[prop.name] = value
        return value
    end
    function self.int(prop: num)
        prop.parse = parse_integer :: any
        prop.default = prop.default or output[prop.name]
        local value = prompt_text(prop :: any)
        output[prop.name] = value
        return value
    end
    function self.num(prop: num)
        prop.parse = parse_number :: any
        prop.default = prop.default or output[prop.name]
        local value = prompt_text(prop :: any)
        output[prop.name] = value
        return value
    end
    function self.str(prop: str)
        prop.parse = prop.parse
        prop.default = prop.default or output[prop.name]
        local value = prompt_text(prop)
        output[prop.name] = value
        return value
    end
    function self.identifier(prop: str)
        prop.parse = parse_identifier
        prop.default = prop.default or output[prop.name]
        local value = prompt_text(prop)
        output[prop.name] = value
        return value
    end
    function self.version(prop: str<semver.ParseError>)
        prop.parse = parse_version :: any
        prop.default = prop.default or output[prop.name]
        local value = prompt_text(prop)
        output[prop.name] = value
        return value
    end
    function self.enum(prop: enum)
        local options = {sparse_unpack(prop)}
        prop.default_index = prop.default_index or table.find(options, output[prop.name])
        local value = prompt_enum(prop)
        output[prop.name] = value
        return value
    end
    function self.struct(prop: struct)
        if output[prop.name] == nil then output[prop.name] = {} end
        return inquisitor(output[prop.name])
    end

    return self
end

-- end
type inquisitor = typeof(inquisitor)
return inquisitor :: inquisitor