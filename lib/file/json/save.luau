local cst = require('@lib/file/json/cst')
local parser = require('@lib/file/json/parser')
local serde = require('@lune/serde')

local delta_cursor = 0
local insert_pos = 0
local output = ''
local depth = 0

-- helper
local function push_str(str: string, element: string, index: number, replace_len: number)
	local offset = string.len(element) - (replace_len or 0)
	output = string.sub(str, 1, index + delta_cursor - 1)
		.. element
		.. string.sub(str, index + (replace_len or 0) + delta_cursor)

	insert_pos += offset
	delta_cursor += offset
end

-- function
local function apply(node: cst.node?, data: any)
	if node then insert_pos = node.start end

	if typeof(data) == 'table' and node then
		local k = next(data)
		local is_arr = if k then typeof(k) == 'number' else node.kind == 'array'

		if is_arr and node.kind == 'array' then
			insert_pos += 1
			depth += 1
			for index, value in data do
				if index > 1 and not node.elements[index] then push_str(output, ',\n', insert_pos, 0) end
				apply(node.elements[index], value)
			end
			depth -= 1
			return
		elseif not is_arr and node.kind == 'object' then
			insert_pos += 1
			depth += 1
			-- existing fields must to keep at same position
			local existing_properties = {}
			for _, property in node.properties do
				existing_properties[property.key] = true
				apply(property.value, data[property.key :: any])
			end
			-- new fields must to append at the end
			local needs_separator = next(node.properties) ~= nil
			for index: string, value in data :: any do
				if existing_properties[index] then continue end

				if needs_separator then push_str(output, ',\n', insert_pos, 0) end
				push_str(output, `\"{index}\": `, insert_pos, 0)

				needs_separator = true
				apply(nil, value)
			end
			depth -= 1
			return
		end
	end

	local new_content = serde.encode('json', data)
	local replace_len = if node then node.finish - node.start else 0
	local start = if node then node.start else insert_pos

	push_str(output, new_content, start, replace_len)
end

local function save(content: string, data: any)
	output = content
	delta_cursor = 0

	local cst = parser.parse(content)
	apply(cst, data)

	return output
end

return save
