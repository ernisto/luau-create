local color = require('@utils/display/color')
type field = {
	name: string,
	value: string,
	align: 'center' | 'left' | 'right',
	content_width: number,
	content_height: number,
	name_width: number,
	name_height: number,
	absolute_width: number,
	absolute_height: number,
	set_value: (value: string) -> (),
	get_name_line: (line: number) -> string,
	get_content_line: (line: number) -> string,
}
local function clean_string(str: string)
	local clean = string.gsub(str, '\027%[[0-9;]*m', '')
	return clean
end
local function new_field(name: string): field
	local self = {} :: field

	self.name = color.bold(name)
	self.value = ''
	self.align = 'left'
	self.content_width = 0
	self.content_height = 0
	self.name_width = 0
	self.name_height = 0
	self.absolute_width = 0
	self.absolute_height = 0

	local function update_size()
		local content_lines = string.split(self.value, '\n')
		local content_width = 0
		local name_lines = string.split(self.name, '\n')
		local name_width = 0

		for _, content in content_lines do
			content_width = math.max(content_width, string.len(clean_string(content)))
		end
		for _, content in name_lines do
			name_width = math.max(name_width, string.len(clean_string(content)))
		end
		self.content_width = content_width + #content_lines
		self.content_height = #content_lines
		self.name_width = name_width
		self.name_height = #name_lines
		self.absolute_width = math.max(content_width, name_width)
		self.absolute_height = self.content_height + self.name_height
	end

	function self.set_value(value: string)
		self.value = value:gsub('\t', ' ')
		update_size()
	end

	function self.get_name_line(line: number)
		local lines = string.split(self.name, '\n')
		return lines[line]
	end
	function self.get_content_line(line: number)
		local lines = string.split(self.value, '\n')
		return lines[line]
	end
	update_size()
	return self
end

local function new_ascii(title: string?)
	local fields = {}

	local title_field = new_field(title or '')
	local offset = 2

	local function get_spaces(abs_width: number, width: number)
		local calc = ((abs_width + offset) - width) / 2
		local left = string.rep(' ', math.ceil(calc))
		local right = string.rep(' ', math.floor(calc))
		return left, right
	end

	local function add_field(name: string)
		local field = new_field(name)
		table.insert(fields, field)
		return field
	end

	local function print_ascii()
		local width, height = 3, 2
		local name_width, name_height = 2, 0
		local content_width, content_height = 2, 0

		for _, field in fields do
			width += field.absolute_width + offset
			height = math.max(height, field.absolute_height)
			name_width += field.name_width
			name_height = math.max(name_height, field.name_height)
			content_width += field.content_width
			content_height = math.max(content_height, field.content_height)
		end

		if title then
			for y = 1, title_field.name_height do
				width = math.max(width, #clean_string(title_field.get_name_line(y)))
			end
		end
		local vertical_bar = string.rep('-', width)
		print(vertical_bar)

		if title then
			for y = 1, title_field.name_height do
				local value = title_field.get_name_line(y)
				local left, right = get_spaces(width - 4, #clean_string(value))
				print(`|{left .. value .. right}|`)
			end
			print(vertical_bar)
		end

		-- print names
		local lines = {}
		for y = 1, name_height do
			local line = {}
			for _, field in fields do
				local value = field.get_name_line(y) or string.rep(' ', field.name_width)
				local left, right = get_spaces(field.absolute_width, #clean_string(value))
				table.insert(line, left .. value .. right)
			end
			lines[y] = `|{table.concat(line, '|')}|`
		end

		print(table.concat(lines, '\n'))
		print(vertical_bar)

		-- print content
		lines = {}
		for y = 1, height - name_height do
			local line = {}
			for _, field in fields do
				local value = field.get_content_line(y) or string.rep(' ', field.absolute_width)
				local left, right = get_spaces(field.absolute_width, #clean_string(value))

				if field.align == 'right' then
					left ..= right:sub(1, -2)
					right = ' '
				elseif field.align == 'left' then
					right ..= left:sub(1, -2)
					left = ' '
				end

				table.insert(line, left .. value .. right)
			end
			lines[y] = `|{table.concat(line, '|')}|`
		end

		print(table.concat(lines, '\n'))
		print(vertical_bar)
	end

	return table.freeze {
		add_field = add_field,
		print_ascii = print_ascii,
	}
end

return table.freeze {
	new = new_ascii,
}
