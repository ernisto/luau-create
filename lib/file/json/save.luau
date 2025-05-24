local cst = require('@lib/file/json/cst')
local parser = require('@lib/file/json/parser')
local serde = require('@lune/serde')

local delta_cursor = 0
local insert_pos = 0
local output = ''
local depth = 0

-- helper
local function push_str(str: string, element: string, index: number, replace_len: number?)
	local offset = string.len(element) - (replace_len or 0)
	output = string.sub(str, 1, index + delta_cursor)
		.. element
		.. string.sub(str, index + 1 + (replace_len or 0) + delta_cursor)

	delta_cursor += offset
end

-- function
local function apply(replacing_node: cst.node?, data: any)
	if replacing_node then
		insert_pos = replacing_node.start - 1 -- push_str replaces first character of this node
	end

	if typeof(data) == 'table' and replacing_node then
		local k = next(data)
		local is_arr = if k then typeof(k) == 'number' else replacing_node.kind == 'array'

		if is_arr and replacing_node.kind == 'array' then
			insert_pos += 1 -- '['	-- push_str replaces after this character
			depth += 1
			for index, value in data do
				local element = replacing_node.elements[index]
				if index > 1 and not element then push_str(output, ', ', insert_pos) end
				apply(element, value)
			end

			-- remove
			local replace_len = replacing_node.finish - insert_pos - 1
			push_str(output, ' ', insert_pos, replace_len)

			depth -= 1
			insert_pos = replacing_node.finish -- push_str replaces after the last character of this node
			return
		elseif not is_arr and replacing_node.kind == 'object' then
			insert_pos += 1 -- '{'
			depth += 1
			-- existing fields must to keep at same position
			local existing_properties = {}
			for _, property in replacing_node.properties do
				existing_properties[property.key] = true
				local value = data[property.key]
				if value == nil then
					local replace_len = property.finish - property.start + 1
					push_str(output, '', property.start - 1, replace_len)
					continue
				end
				apply(property.value, value)
			end
			-- new fields must to append at the end
			local needs_separator = next(replacing_node.properties) ~= nil
			for index: string, value in data :: any do
				if existing_properties[index] then continue end

				if needs_separator then push_str(output, ', ', insert_pos) end
				needs_separator = true

				push_str(output, `\"{index}\": `, insert_pos)
				apply(nil, value)
			end
			depth -= 1
			insert_pos = replacing_node.finish
			return
		end
	end

	local new_content = serde.encode('json', data, true)
	local replace_len = if replacing_node then replacing_node.finish - replacing_node.start + 1 else 0
	local start = if replacing_node then replacing_node.start - 1 else insert_pos

	push_str(output, new_content, start, replace_len)
	if replacing_node then insert_pos = replacing_node.finish end
end

local function save(content: string, data: any)
	output = content
	delta_cursor = 0

	local cst = parser.parse(content)
	apply(cst, data)

	return output
end

return save
