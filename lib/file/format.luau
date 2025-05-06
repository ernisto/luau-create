-- functions
local function is_array(t: {[any]: any}): boolean
    local k = next(t)
    return not k or typeof(k) == "number"
end

local function is_empty(t: {[any]: any}): boolean
    return next(t) == nil
end

local function get_keys<K>(t: {[K]: any}): {K}
    local keys = {}

    for k in t do
        table.insert(keys, k)
    end

    return keys
end

local function custom_type(a: any): string

    return if typeof(a) == "table" and is_array(a) then "array" else typeof(a)
end

local function sort_iter<K,V>(t: {[K]: V}): () -> (K, V)

    local keys = get_keys(t)
    table.sort(keys, function(a: any, b: any)
        
        local typeA, typeB = custom_type(t[a]), custom_type(t[b])
        
        if (typeof(t[a]) ~= "table") and (typeof(t[b]) == "table") then
            return true
        end
        if typeA == "array" and typeB == "table" then
            return true
        end
        if (typeA == typeB) and (a < b) then
            return true
        end

        return false
    end)

    return coroutine.wrap(function()
        for _, v in keys do
            coroutine.yield(v, t[v])
        end
    end)
end

local function format_type<V>(v: V): V | string
    return if typeof(v) == "string" then `"{v}"` else v
end

local function format_table(t: {[any]: any}): string

    local texts = {}

    local array = is_array(t)

    for k, v in sort_iter(t) do

        if array then
            table.insert(texts, format_type(v))
        else
            local value = if typeof(v) == "table" then format_table(v) else format_type(v)
            table.insert(texts, `{k} = {value}`)
        end
    end

    local text = table.concat(texts, ", ")
    return if array then `[{text}]` else `\{{text}}`
end

local function create_table(name: string, t: {[string]: any}): string

    local texts = {}

    for k, v in sort_iter(t) do
        local value = if (typeof(v) == "table") then
            format_table(v) else format_type(v)

        table.insert(texts, `{k} = {value}`)
    end

    local text = `[{name}]\n{table.concat(texts, "\n")}`
    return text
end

local function format(data: {[string]: any}): string

    local text = ""
    for k, v in sort_iter(data) do

        if (typeof(v) == "table" and is_empty(v)) then continue end

        if custom_type(v) == "table" then

            text ..= `\n{create_table(k, v)}\n`
        else
            local value = if custom_type(v) == "array" then 
                format_table(v) else format_type(v)

            text ..= `{k} = {value}\n`
        end
    end

    text = text:gsub('^\n+', '')
    text = text:gsub('\n+$', '')
    return text
end
return format