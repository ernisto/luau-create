local function merge(output, source,...)
    if not source then return output end

    if output[1] or source[1] then
        for index, value in source do
            if table.find(output, value) then continue end
            table.insert(output, value)
        end
    end

    for index, value in source do
        if type(value) == 'table' then
            output[index] = merge(output[index] or {}, value)
        else
            output[index] = value
        end
    end
    return merge(output,...)
end

return merge :: (
    & (<A>(A) -> A)
    & (<A, B>(A, B) -> A & B)
    & (<A, B, C>(A, B, C) -> A & B & C)
    & (<A, B, C, D>(A, B, C, D) -> A & B & C & D)
    & (<A, B, C, D, E>(A, B, C, D, E) -> A & B & C & D & E)
)
