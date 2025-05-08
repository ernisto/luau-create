-- global state
local input: string
local cursor: number

-- token cache
local have_cached_word = false
local content, word: string?

-- helpers
local function scan_pattern(pattern: string)
    return select(3, string.find(input, pattern, cursor))
end
local function advance(len: number)
    cursor += len
    have_cached_word = false
end

local function skip_comments()
    repeat
        local content = scan_pattern('^(#.-\n%s*)')
        if content then cursor += string.len(content) end
    until content == nil
end
local function skip_spaces()
    local content = scan_pattern('^(%s*)')
    if content then cursor += string.len(content) end
end

local function scan_word(exact_word: string?): string?
    if not have_cached_word then
        content, word = scan_pattern('^((%w+)%s*)')
        if not content then return end
        have_cached_word = true
    end
    if not content then return end
    if exact_word and word ~= exact_word then return end

    advance(string.len(content))
    have_cached_word = false

    skip_comments()
    return word
end
local function scan_char(exact_char: string): string?
    local content, char = scan_pattern(`^((.)%s*)`)
    if not content then return end
    
    if char ~= exact_char then return end
    advance(string.len(content))

    skip_comments()
    return char
end
local function expect_char(exact_char: string): string?
    return scan_char(exact_char) or warn(`expected '{exact_char}'`)
end

local function scan_str(): string?
    local content, str = scan_pattern("^(\'(.-)\'%s*)")
    if not content then content, str = scan_pattern("^(\"(.-)\"%s*)") end
    if not content then return end

    advance(string.len(content))    
    skip_comments()

    return str
end
local function scan_num(): string?
    local content, num = scan_pattern("^((%d+)%s*)")
    if not content then return end

    advance(string.len(content))
    skip_comments()

    return num
end
local function scan_raw(str: string): string?
    local raw = string.sub(input, cursor, cursor + string.len(str)-1)
    if not raw or raw ~= str then return end

    advance(string.len(raw))
    skip_spaces()

    skip_comments()
    return raw
end

local function lex(str)
    input = str
    cursor = 1

    skip_spaces()
    skip_comments()
end

-- module
return table.freeze {
    lex = lex,
    scan_word = scan_word,
    scan_str = scan_str,
    scan_num = scan_num,
    scan_char = scan_char,
    scan_raw = scan_raw,
    expect_char = expect_char
}