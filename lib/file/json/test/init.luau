local args = require('@cli/args')
local ascii = require('@utils/display/ascii')
local cases = require('@self/cases')
local display = require('@utils/display')
local save = require('@lib/file/json/save')
local serde = require('@lune/serde')
local stdio = require('@lune/stdio')

local names = { 'all', 'none' }
for _, case in cases do
	table.insert(names, case[1] :: string)
end

local function test_case(case: { string | { any } })
	local name, input, data = unpack(case)
	local output = save(input :: any, data)
	local printer = ascii.new(name :: any)
	local input_field = printer.add_field('input')
	local output_field = printer.add_field('output')
	input_field.set_value(display.json(input :: any) .. '\ndata: ' .. display.json(serde.encode('json', data)))
	output_field.set_value(display.json(output))
	printer.print_ascii()
end
if not next(args.current) then
	repeat
		local selected = stdio.prompt('select', 'Case:', names)

		if selected == 1 then
			for _, case in cases do
				test_case(case)
			end
			break
		elseif selected == 2 then
			break
		else
			test_case(cases[selected - 2])
		end
	until false
else
	if args.get_bool(args.current, 'yes') then
		for _, case in cases do
			test_case(case)
		end
	else
		for key in args.current do
			if not tonumber(key) then continue end
			test_case(cases[tonumber(key) or 1])
		end
	end
end
