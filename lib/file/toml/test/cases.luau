local cases: { { string | { any } } } = {
	{
		'switch block property',
		[[foo = 5]],
		{ foo = 10 },
	},
	{
		'insert block property',
		[[foo = { bar = 5 }]],
		{ foo = { bar = 5 }, baz = true },
	},
	{
		'remove block property',
		[[foo = 5]],
		{},
	},
	{
		'switch array child',
		[=[foo = [ 1, 2, 3 ]]=],
		{ foo = { 1, 2, 2 } },
	},
	{
		'insert array child',
		[=[foo = [ 1, 2, 3 ]]=],
		{ foo = { 1, 2, 3, 4 } },
	},
	{
		'remove array child',
		[=[foo = [ 1, 2, 3 ]]=],
		{ foo = { 1, 2 } },
	},
	{
		'switch array child type',
		[=[foo = [ 1 ]]=],
		{ foo = { bar = 1 } },
	},
	{
		'switch block property type',
		[[foo = { bar = true }]],
		{ foo = 5 },
	},
}

return cases
