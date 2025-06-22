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

local function encode(data: any, depth: number): string?
	if typeof(data) == 'table' then
		if not next(data) then return end
		depth += 1
		local tab = string.rep('\t', depth)

		local _k = next(data)
		local is_array = typeof(_k) == 'number'
		local fields = {}

		for k, v in sort_iter(data) do
			local content = encode(v, depth)
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

return encode
