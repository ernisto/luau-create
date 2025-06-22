local cst = require('@self/cst')
local encode = require('@self/encode')
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
local function remove_node(node: { start: number, finish: number })
	local replace_len = node.finish - node.start + 1
	push_str('', node.start - 1, replace_len)
end

-- function
local apply

local function apply_array(replacing_node: cst.array_node, data: { any })
	local identation = if replacing_node.multi_line then '\n' .. string.rep('\t', depth) else ' '

	insert_pos += 1 -- '['	-- push_str replaces after this character
	depth += 1

	local last_element
	for index, value in data do
		local element = replacing_node.elements[index]
		if index > 1 and not element then
			push_str(',', insert_pos)
			push_str(identation, insert_pos)
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
end
local function apply_object(replacing_node: cst.object_node, data: { [string]: any })
	local identation = '\n' .. string.rep('\t', depth)
	insert_pos += 1 -- '{'
	depth += 1

	-- existing fields must to keep at same position
	local existing_properties = {}
	for index, property in replacing_node.properties do
		existing_properties[property.key] = true

		local value = data[property.key]
		if value == nil then
			remove_node(replacing_node.properties[index - 1] or property)
		else
			apply(property.value, value)
		end
	end

	-- new fields must to append at the end
	local needs_separator = next(replacing_node.properties) ~= nil
	local added = false

	for index, value in data do
		if existing_properties[index] then continue end

		if needs_separator then push_str(',', insert_pos) end
		needs_separator = true
		added = true

		push_str(`{identation}\"{index}\": `, insert_pos)
		apply(nil, value)
	end

	depth -= 1
	if added and not needs_separator then push_str(`\n{string.rep('\t', depth)}`, insert_pos) end
	insert_pos = replacing_node.finish
end
function apply(replacing_node: cst.value_node | cst.token | cst.property_node | cst.element_node?, data: any)
	if replacing_node then
		insert_pos = replacing_node.start - 1 -- push_str replaces first character of this node
	end

	if typeof(data) == 'table' and replacing_node then
		local k = next(data)
		local is_arr = if k then typeof(k) == 'number' else replacing_node.kind == 'array'

		if is_arr and replacing_node.kind == 'array' then
			return apply_array(replacing_node, data)
		elseif not is_arr and replacing_node.kind == 'object' then
			return apply_object(replacing_node, data)
		end
	end

	local new_content = if data == REMOVE then '' else (encode(data, depth) or '')
	local replace_len = if replacing_node then replacing_node.finish - replacing_node.start + 1 else 0
	local start = if replacing_node then replacing_node.start - 1 else insert_pos

	push_str(new_content, start, replace_len)
	if replacing_node then insert_pos = replacing_node.finish end
end

-- module
local function save(content: string, data: any): string
	output = content
	delta_cursor = 0

	local cst = parser.parse(content)
	apply(cst, data)

	return output
end

return save
