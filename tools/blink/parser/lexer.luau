-- global state
local input: buffer
local cursor: number

-- token cache
local cached_word: string | false | nil -- not confirmed
--				   ^^^^^^   ^^^^^
--				   ^^^^^^^  confirmed no word
--				   confirmed word
-- defs
type char = string
type char_byte = number

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
	-- look_ahead = cursor + 1 < buffer.len(input) and buffer.readu8(input, cursor + 1) or nil
end
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

local function skip_blank()
	while current_byte and is_space(current_byte) do
		advance()
	end
end
local function skip_comments()
	local byte = string.byte('-')

	while buffer.readu16(input, cursor) == byte + byte * 2 ^ 8 do
		repeat
			advance()
			print(current_byte == string.byte('\n'))
		until current_byte == string.byte('\n')
		skip_blank()
	end
end

local function scan_word(exact_word: string?): string?
	if not current_byte then return end

	if cached_word == nil then
		if not is_letter(current_byte) then
			cached_word = false
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
	elseif cached_word == false then
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
	local init = cursor

	local symbol_code = current_byte
	if symbol_code ~= string.byte('"') and symbol_code ~= string.byte("'") then return end

	repeat
		advance()
	until current_byte == symbol_code

	local str = buffer.readstring(input, init + 1, cursor - init - 1)
	advance()

	skip_blank()
	skip_comments()
	return str
end

local function expect_char(char: char): char?
	return scan_char(char) or warn(`{debug.info(2, 'n')}: Expected '{char}', got {string.char(current_byte :: any)}`)
end
local function scan_num(): string?
	if not current_byte then return end

	local init = cursor
	local sign = scan_char('-')

	local has_num = is_digit(current_byte)
	if has_num then
		repeat
			advance()
		until not is_digit(current_byte)
	end

	local dot = scan_char('.')
	if dot then
		if is_digit(current_byte) then
			has_num = true
			repeat
				advance()
			until not is_digit(current_byte)
		else
			advance(-1)
		end
		--elseif not has_num and not sign then
		-- return
	end

	if not has_num then return end
	local str = buffer.readstring(input, init, cursor - init)

	skip_blank()
	skip_comments()
	return str
end
local function scan_raw(raw: string): string?
	local len = string.len(raw)
	local b1, b2, b3, b4 = string.byte(raw, 1, 4)

	local sum = (b1 or 0) + (b2 or 0) * 2 ^ 8 + (b3 or 0) * 2 ^ 16 + (b4 or 0) * 2 ^ 32
	if bit32.extract(buffer.readu32(input, cursor), 0, len * 8) ~= sum then return end
	advance(len)
	skip_blank()
	skip_comments()
	return raw
end

-- loggers
local function get_cursor_position()
	local line_cursor = 0
	local line_count = 1

	for offset = 0, cursor do
		line_cursor += 1
		if buffer.readu8(input, offset) == string.byte('\n') then
			line_count += 1
			line_cursor = 0
		end
	end

	return line_count, line_cursor
end
function report(str: string?)
	local line, char = get_cursor_position()
	return warn(`[Line {line}, Column {char}]: {str}`)
end
function trace()
	local line, char = get_cursor_position()
	local current_char, next_char = string.char(current_byte or 0), string.char(buffer.readu8(input, cursor + 1))
	return warn(
		`[Line: {line}, Column: {char}, CurrentChar: {current_char}, NextChar: {next_char}, CachedWord: {cached_word}, func: {debug.info(
			2,
			'n'
		)}]`
	)
end

local function lex(str: string)
	cursor = 0
	input = buffer.fromstring(str .. '\0\0\0\0')
	current_byte = buffer.readu8(input, cursor)
	skip_blank()
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
	expect_char = expect_char,
	report = report,
	trace = trace,
}
