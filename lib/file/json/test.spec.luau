local save = require('@lib/file/json/save')
local cases: { { string | { any } } } = {
	{
		'switch value',
		[[{"foo": 5}]],
		{ foo = 10 },
	},
	{
		'insert value',
		[[{
            "foo": [ 1, 2, 3 ]
        }]],
		{ foo = { 1, 2, 3, 4 } },
	},
	{
		'remove value',
		[[{
            "foo": [ 1, 2, 3 ]
        }]],
		{ foo = { 1, 2 } },
	},
	{
		'change table property value',
		[[{
            "foo": {
                "bar": true
            }
        }]],
		{ foo = { bar = false } },
	},
	{
		'change value to another type',
		[[{
            "foo": { "bar": true }
        }]],
		{ foo = 5 },
	},
}

for _, case in cases do
	local name, content, data = unpack(case)
	warn(name)
	print(save(content :: any, data), '\n')
	break
end
