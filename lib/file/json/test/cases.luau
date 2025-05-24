local cases: { { string | { any } } } = {
	{
		'switch property',
		[[{"foo": 5}]],
		{ foo = 10 },
	},
	{
		'insert property',
		[[{
			"foo": { "bar": 5 }
		}]],
		{ foo = { bar = 5 }, baz = true },
	},
	{
		'remove property',
		[[{
			"foo": 5
		}]],
		{},
	},
	{
		'switch child',
		[=[[1, 2, 3]]=],
		{ 1, 2, 2 },
	},
	{
		'insert child',
		[[{
			"foo": [ 1, 2, 3 ]
		}]],
		{ foo = { 1, 2, 3, 4 } },
	},
	{
		'remove child',
		[[{
			"foo": [ 1, 2, 3 ]
		}]],
		{ foo = { 1, 2 } },
	},
	{
		'switch child type',
		[=[[1]]=],
		{ { foo = 1 } },
	},
	{
		'switch property type',
		[[{
			"foo": { "bar": true }
		}]],
		{ foo = 5 },
	},
}

return cases
