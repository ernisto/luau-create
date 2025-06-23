-- global state
local input: buffer
local cursor: number
local last_char_cursor: number?

-- token cache
type uncached = nil
local uncached: uncached = nil

type cached_none = false
local cached_none: cached_none = false

local cached_word: string | cached_none | uncached

-- definitions
type char = string
type char_byte = number

-- loggers
local function get_cursor_position(index: number?): (number, number, number)
	local line_cursor = 0
	local line_count = 1

	for offset = 0, index or cursor do
		line_cursor += 1
		if buffer.readu8(input, offset) == string.byte('\n') then
			line_count += 1
			line_cursor = 0
		end
	end

	return cursor + 1, line_count, line_cursor
end
local function get_final()
	return last_char_cursor or (cursor + 1)
end
local function report(str: string?)
	local _, line, char = get_cursor_position()
	return warn(`[Line {line}, Column {char}]: {str}`)
end

-- helpers
local current_byte: char_byte?

local function advance(len: number?)
	cursor += len or 1
	if cursor > buffer.len(input) - 1 then
		cursor = buffer.len(input) - 1
		current_byte = nil
		return
	end
	cached_word = nil
	current_byte = buffer.readu8(input, cursor)
end

local function is_letter(code: char_byte): boolean
	return string.byte('a') <= code and code <= string.byte('z')
		or string.byte('A') <= code and code <= string.byte('Z')
		or string.byte('_') == code
end
local function is_digit(code: char_byte): boolean
	return string.byte('0') <= code and code <= string.byte('9')
end
local function is_space(code: char_byte): boolean
	return code == string.byte ' '
		or code == string.byte '\t'
		or code == string.byte '\n'
		or code == string.byte '\r'
		or code == string.byte '\b'
		or code == string.byte '\f'
		or code == string.byte '\v'
end

local function skip_blank()
	last_char_cursor = cursor - 1 + 1
	while current_byte and is_space(current_byte) do
		advance()
	end
end

local function skip_comments()
	local byte = string.byte('/')

	while buffer.readu16(input, cursor) == byte + byte * 2 ^ 8 do
		repeat
			advance()
		until current_byte == string.byte('\n')

		skip_blank()
	end
end

-- scanning functions
local function scan_word(exact_word: string?): string?
	if not current_byte then return end

	if cached_word == uncached then
		if not is_letter(current_byte) then
			cached_word = cached_none
			return
		end

		local init_byte = current_byte
		local init = cursor
		repeat
			advance()
		until not is_letter(current_byte) and not is_digit(current_byte)

		cached_word = buffer.readstring(input, init, cursor - init)
		cursor = init
		current_byte = init_byte
	end
	if exact_word then
		if exact_word ~= cached_word then return end
	elseif cached_word == cached_none then
		return
	end

	local word: string = cached_word :: any
	advance(string.len(word))

	skip_blank()
	skip_comments()
	return word
end

local function scan_char(char: char): char?
	if current_byte ~= string.byte(char) then return end
	advance()
	skip_blank()
	skip_comments()
	return char
end

local function scan_str(): string?
	if not scan_char('"') then return end

	local str = {}
	while current_byte and current_byte ~= string.byte('"') do
		if current_byte == string.byte('\\') then
			advance()
			local escaped = string.char(current_byte)
			table.insert(str, escaped)
		else
			table.insert(str, string.char(current_byte))
		end
		advance()
	end

	if not current_byte then
		report('Unterminated string')
		return
	end

	advance() -- skip closing quote
	skip_blank()
	skip_comments()
	return table.concat(str)
end

local function scan_num(): string?
	if not current_byte then return end

	local init = cursor
	scan_char('-')

	local has_num = is_digit(current_byte)
	if has_num then
		if current_byte == string.byte('0') then
			advance()
		else
			repeat
				advance()
			until not is_digit(current_byte)
		end
	end

	if scan_char('.') then
		if is_digit(current_byte) then
			has_num = true
			repeat
				advance()
			until not is_digit(current_byte)
		else
			advance(-1)
		end
	end

	-- scientific notation
	if current_byte == string.byte('e') or current_byte == string.byte('E') then
		advance()
		if current_byte == string.byte('+') or current_byte == string.byte('-') then advance() end
		if is_digit(current_byte) then
			repeat
				advance()
			until not is_digit(current_byte)
		else
			report('Invalid scientific notation')
			return
		end
	end

	if not has_num then return end
	local str = buffer.readstring(input, init, cursor - init)

	skip_blank()
	skip_comments()
	return str
end

local function expect_char(char: char): char?
	return scan_char(char) or report(`Expected '{char}', found '{string.char(current_byte :: any)}'`)
end

-- logging functions
local function lex(str: string)
	cursor = 0
	input = buffer.fromstring(str .. '\0\0\0\0')
	current_byte = buffer.readu8(input, cursor)
	cached_word = nil
	last_char_cursor = nil
	skip_blank()
	skip_comments()
end

return table.freeze({
	lex = lex,
	scan_word = scan_word,
	scan_str = scan_str,
	scan_num = scan_num,
	scan_char = scan_char,
	expect_char = expect_char,
	report = report,
	get_cursor_position = get_cursor_position,
	get_final = get_final,
})
