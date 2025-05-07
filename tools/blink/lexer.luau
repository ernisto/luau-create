-- global state
local input: string
local cursor: number

local function skip_comments()
    repeat
        local content = select(3, string.find("^#[^\n]+", input, cursor))
        if content then cursor += string.len(content) end
    until content == nil
end

-- cached word scanner
local have_cached_word = false
local content, word: string?
local function scan_word(exact_word: string?): string?
    if not have_cached_word then
        content, word = select(3, string.find(input, "^((%w+)%s*)", cursor))
        have_cached_word = true
    end
    if not content then return end
    if exact_word and word ~= exact_word then return end

    cursor += string.len(content)
    have_cached_word = false

    skip_comments()
    return word
end
local function scan_char(exact_char: string): string?

    local content, char = select(3, string.find(input, `^((.)%s*)`, cursor))
    if not content then return end
    if char ~= exact_char then return end
    
    cursor += string.len(content)
    skip_comments()
    return char
end
local function expect_char(exact_char: string): string?
    return scan_char(exact_char) or warn(`expected '{exact_char}'`)
end

local function scan_str(): string?
    local content, str = select(3, string.find(input, "^(\'(.-)\'%s*)", cursor))
    if not content then return end

    cursor += string.len(content)    
    skip_comments()

    return str
end
local function scan_num(): string?
    local content, num = select(3, string.find(input, "^((%d+)%s*)", cursor))
    
    if not content then return end
    cursor += string.len(content)

    skip_comments()
    return num
end

local function lex(str)
    input = str
    cursor = 1

    skip_comments()
end

-- module
return table.freeze {
    lex = lex,
    scan_word = scan_word,
    scan_str = scan_str,
    scan_num = scan_num,
    scan_char = scan_char,
    expect_char = expect_char
}