local function merge(output, source,...)
    if not source then return output end
    for index, value in source do
        output[index] = value
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
