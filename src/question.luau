local io = require('@lune/stdio')

-- functions
local function parse_number(value: string): number
    return assert(tonumber(value), `you must to enter a number`)
end
local function parse_integer(value: string): number
    assert(string.match(value, '^%d+$'), `you must to enter a integer number`)
    return tonumber(value) or error(`cavalo`)
end

-- constructors
local function struct<value>(props: {
    name: string,
    desc: string?,
    presets: { { [string]: value } }?,
    [number]: question<value>
}): struct<{ [string]: value }>
    return {
        kind = 'struct',
        name = props.name,
        desc = props.desc,
        presets = props.presets,
        questions = { unpack(props) }
    } :: any
end
local function enum<Value>(props: {
    name: string,
    desc: string?,
    default_index: number?,
    [number]: option<Value>
}): enum<Value>
    return {
        kind = 'enum',
        name = props.name,
        desc = props.desc,
        options = {unpack(props)}
    } :: any
end
local function bool<Value>(props: { name: string, desc: string?, default: default<boolean>?, parser: nil|(string) -> Value }): bool<Value>
    return { kind = 'bool', name = props.name, desc = props.desc, default = props.default, parser = props.parser }
end
local function str<Value>(props: { name: string, desc: string?, default: default<string>?, parser: nil|(string) -> Value }): str<Value>
    return { kind = 'str', name = props.name, desc = props.desc, default = props.default, parser = props.parser }
end

local function int(props: { name: string, desc: string?, default: default<string>? }): str<number>
    return { kind = 'str', name = props.name, desc = props.desc, default = props.default, parse = parse_integer }
end
local function num(props: { name: string, desc: string?, default: default<string>? }): str<number>
    return { kind = 'str', name = props.name, desc = props.desc, default = props.default, parse = parse_number }
end

-- methods
local prompt
local function prompt_text<value>(question: str<value> | bool<value>): value
    repeat
        local out = io.prompt('text', question.name, tostring(question.default))

        if question.parse then
            local success, result = pcall(question.parse)
            if success then return result end

            io.ewrite(tostring(result))
        end
        return out
    until false
end
local function prompt_enum<value>(question: enum<value>): value
    local options = question.options
    local names = {}
    local desc_visible = false
    for i, option in options do
        names[i] = option.name
    end
    table.insert(names, 'help')
    repeat
        local index = io.prompt('select', question.name, names)
        if index == #names then
            print(question.desc)
            if desc_visible then continue end

            for i, option in options do
                names[i] = `{option.name} {io.color('white')}{option.desc or ''}`
            end
            desc_visible = true
            continue
        end
        return options[index].value or options[index].name :: any
    until false
end
local function prompt_struct<value>(question: struct<value>): value
    local output: any = {}
    if question.presets and next(question.presets) then
        local options = {}
        for name, preset in question.presets do
            table.insert(options, { name = name, value = preset })
        end
        output = prompt_enum(
            enum { name = 'preset', desc = question.desc, unpack(options :: any) }
        )
    end
    for _,question: any in question.questions do
        if output[question.name] then continue end
        output[question.name] = prompt(question)
    end
    return output
end
function prompt<Value>(question: question<Value>): Value
    return if question.kind == 'bool' then io.prompt('confirm', question.name, question.default)
        elseif question.kind == 'enum' then prompt_enum(question)
        elseif question.kind == 'str' then prompt_text(question)
        else prompt_struct(question)
end

-- types
export type struct<Value = unknown> = { kind: 'struct', name: string, desc: string?, presets: { [string]: Value }, questions: { unknown } }

export type enum<Value = string> = { kind: 'enum', name: string, default_index: number?, desc: string?, options: { option<Value> } }
export type option<Value = string> = { name: string, value: Value?, desc: string? }

export type bool<Value = boolean> = { kind: 'bool', name: string, default: default<boolean>?, desc: string?, parse: nil|(boolean) -> Value? }
export type str<Value = string, Input = string> = { kind: 'str', name: string, default: default<Input>?, desc: string?, parse: nil|(Input) -> Value? }
export type question<Value = unknown> = struct<Value> | enum<Value> | bool<Value> | str<Value>

type default<T> = T|() -> T

-- module
return table.freeze {
    prompt = prompt,
    struct = struct,
    enum = enum,
    bool = bool,
    str = str,
    num = num,
    int = int,
}