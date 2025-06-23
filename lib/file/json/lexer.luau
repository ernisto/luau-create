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

local escape_byte_result = table.freeze {
	[string.byte 'n'] = string.byte('\n'),
	[string.byte 'r'] = string.byte('\r'),
	[string.byte 't'] = string.byte('\t'),
	[string.byte 'b'] = string.byte('\b'),
	[string.byte 'f'] = string.byte('\f'),
	[string.byte 'v'] = string.byte('\v'),
}

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
	return (last_char_cursor or cursor) + 1
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
local function scan_seq(is_allowed: (char_byte) -> boolean?)
	repeat
		advance()
	until not current_byte or not is_allowed(current_byte)
end

-- lexemes
local function is_letter(code: char_byte): boolean
	return string.byte('a') <= code and code <= string.byte('z')
		or string.byte('A') <= code and code <= string.byte('Z')
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
local function is_wordic(code: char_byte): boolean
	return is_letter(code) or is_digit(code) or code == string.byte('_')
end
local function is_comment(code: char_byte): boolean
	return code ~= string.byte('\n')
end

local function skip_blank()
	last_char_cursor = cursor - 1
	while current_byte and is_space(current_byte) do
		advance()
	end
end
local function skip_intervals()
	local byte = string.byte('/')

	skip_blank()
	while buffer.readu16(input, cursor) == byte + byte * 2 ^ 8 do
		scan_seq(is_comment)
		skip_blank()
	end
end

-- scanners
local function scan_char(char: char): char?
	if current_byte ~= string.byte(char) then return end
	advance()

	skip_intervals()
	return char
end
local function expect_char(char: char): char?
	return scan_char(char) or report(`Expected '{char}', found '{string.char(current_byte :: any)}'`)
end

local function scan_word(exact_word: string?): string?
	if not current_byte then return end
	if cached_word == uncached then
		if not is_letter(current_byte) then
			cached_word = cached_none
			return
		end

		local init_byte = current_byte
		local init = cursor
		scan_seq(is_wordic)

		cached_word = buffer.readstring(input, init, cursor - init)
		cursor = init
		current_byte = init_byte
	end
	if cached_word == cached_none then return end

	if exact_word then
		if exact_word ~= cached_word then return end
	end

	local word = cached_word
	advance(string.len(word :: any))

	skip_intervals()
	return word
end

local function scan_num(): string?
	if not current_byte then return end

	local init = cursor
	scan_char('-')

	local has_num = is_digit(current_byte)
	if has_num then scan_seq(is_digit) end

	-- fractional
	if scan_char('.') then
		if not is_digit(current_byte) then return report('Invalid fractional number') end
		scan_seq(is_digit)
	end

	-- scientific notation
	if current_byte == string.byte('e') or current_byte == string.byte('E') then
		advance()
		if current_byte == string.byte('+') or current_byte == string.byte('-') then advance() end

		if not is_digit(current_byte) then return report('Invalid scientific notation') end
		scan_seq(is_digit)
	end

	if not has_num then return end
	local str = buffer.readstring(input, init, cursor - init)

	skip_intervals()
	return str
end

local str = buffer.create(1)
local function scan_str(): string?
	local quote_byte = current_byte
	if quote_byte ~= string.byte '"' and quote_byte ~= string.byte "'" then return end

	local saved_len = 0
	local init = cursor + 1
	repeat
		advance()
		if current_byte == quote_byte then break end
		if current_byte ~= string.byte('\\') then continue end
		if not current_byte then break end

		local saving_len = cursor - init
		buffer.copy(str, saved_len, input, init, saving_len)

		saved_len += saving_len
		init = cursor

		advance()
		local escape_byte = current_byte

		buffer.writeu8(str, saved_len, escape_byte_result[escape_byte] or escape_byte)
		saved_len += 1
	until false

	advance() -- skip closing quote
	skip_intervals()

	return buffer.readstring(str, 0, saved_len) .. buffer.readstring(input, init, cursor - init - 1)
end

-- main
local function lex(input_str: string)
	cursor = 0
	input = buffer.fromstring(input_str .. '\0\0\0\0')
	str = buffer.create(#input_str)
	current_byte = buffer.readu8(input, cursor)
	last_char_cursor = nil
	cached_word = nil
	skip_intervals()
end

-- module
return table.freeze {
	lex = lex,
	scan_word = scan_word,
	scan_str = scan_str,
	scan_num = scan_num,
	scan_char = scan_char,
	expect_char = expect_char,
	report = report,
	get_cursor_position = get_cursor_position,
	get_final = get_final,
}
