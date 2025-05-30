local cst = require('@self/cst')
local parser = require('@self/parser')

local delta_cursor = 0
local insert_pos = 0
local output = ''
local depth = 0

local REMOVE = newproxy(false)

-- helper
local function push_str(element: string, index: number, replace_len: number?)
	local offset = string.len(element) - (replace_len or 0)
	output = string.sub(output, 1, index + delta_cursor)
		.. element
		.. string.sub(output, index + 1 + (replace_len or 0) + delta_cursor)

	delta_cursor += offset
end

local function clean_str(str: string): string
	local out = string.gsub(str, '.', {
		['"'] = '\\"',
		['\\'] = '\\\\',
		['\n'] = '\\n',
		['\t'] = '\\t',
		['\b'] = '\\b',
		['\f'] = '\\f',
		['\r'] = '\\r',
	})
	return out
end

local function sort_iter(tab: { [any]: any })
	local keys = {} :: { any }
	for key in tab do
		keys[#keys + 1] = key
	end
	table.sort(keys)
	return coroutine.wrap(function()
		for _, k in keys do
			coroutine.yield(k, tab[k])
		end
	end)
end

local function stringfy(data: any): string?
	if typeof(data) == 'table' then
		if not next(data) then return end
		depth += 1
		local tab = string.rep('\t', depth)

		local _k = next(data)
		local is_array = typeof(_k) == 'number'
		local fields = {}

		for k, v in sort_iter(data) do
			local content = stringfy(v)
			if content == nil then continue end
			table.insert(fields, tab .. if not is_array then `"{clean_str(k)}": {content}` else content)
		end

		depth -= 1
		local open = is_array and '[' or '{'
		local close = is_array and ']' or '}'
		local close_tab = string.rep('\t', depth)
		local text = table.concat(fields, ',\n')

		return open
			.. (if next(fields) then '\n' else '')
			.. text
			.. (if next(fields) then `\n{close_tab}` else '')
			.. close
	elseif typeof(data) == 'string' then
		return `"{clean_str(data)}"`
	else
		return tostring(data)
	end
end

-- function
local function apply(replacing_node: cst.value_node | cst.token | cst.property_node | cst.element_node?, data: any)
	if replacing_node then
		insert_pos = replacing_node.start - 1 -- push_str replaces first character of this node
	end

	if typeof(data) == 'table' and replacing_node then
		local k = next(data)
		local is_arr = if k then typeof(k) == 'number' else replacing_node.kind == 'array'

		if is_arr and replacing_node.kind == 'array' then
			insert_pos += 1 -- '['	-- push_str replaces after this character
			depth += 1
			local tabs = string.rep('\t', depth)

			local last_element
			for index, value in data do
				local element = replacing_node.elements[index]
				if index > 1 and not element then
					push_str(',', insert_pos)
					if replacing_node.multi_line then
						push_str('\n' .. tabs, insert_pos)
					else
						push_str(' ', insert_pos)
					end
				end
				apply(element and element.value, value)
				last_element = element
			end
			local comma = last_element and last_element.comma
			if comma then apply(comma, REMOVE) end

			-- remove
			for index, element in replacing_node.elements do
				if data[index] then continue end
				if comma then push_str('', comma.start + 1, element.start - comma.start - 1) end
				apply(element, REMOVE)
			end

			depth -= 1
			insert_pos = replacing_node.finish -- push_str replaces after the last character of this node
			return
		elseif not is_arr and replacing_node.kind == 'object' then
			insert_pos += 1 -- '{'
			depth += 1
			local tabs = string.rep('\t', depth)

			-- existing fields must to keep at same position
			local existing_properties = {}
			for index, property in replacing_node.properties do
				existing_properties[property.key] = true
				local value = data[property.key]

				-- remove
				if value == nil then
					local prop = replacing_node.properties[index - 1] or property
					local replace_len = property.finish - prop.start + 1
					push_str('', prop.start - 1, replace_len)
					continue
				end
				apply(property.value, value)
			end
			-- new fields must to append at the end
			local needs_separator = next(replacing_node.properties) ~= nil
			local added = false

			for index, value in sort_iter(data) do
				if existing_properties[index] then continue end

				if needs_separator then push_str(',', insert_pos) end
				needs_separator = true
				added = true

				push_str(`\n{tabs}\"{index}\": `, insert_pos)
				apply(nil, value)
			end

			depth -= 1
			if added and not needs_separator then push_str(`\n{string.rep('\t', depth)}`, insert_pos) end
			insert_pos = replacing_node.finish
			return
		end
	end

	local new_content = if data == REMOVE then '' else (stringfy(data) or '')
	local replace_len = if replacing_node then replacing_node.finish - replacing_node.start + 1 else 0
	local start = if replacing_node then replacing_node.start - 1 else insert_pos

	push_str(new_content, start, replace_len)
	if replacing_node then insert_pos = replacing_node.finish end
end

local function save(content: string, data: any): string
	output = content
	delta_cursor = 0

	local cst = parser.parse(content)
	apply(cst, data)

	return output
end

return save
