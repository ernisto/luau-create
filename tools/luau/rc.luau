local file = require('@lib/file')
local merge = require('@utils/merge')

-- defs
type path = string
type luaurc = {
	languageMode: 'strict' | 'nostrict' | 'nocheck'?,
	lint: {
		['*']: boolean?,
		UnknownGlobal: boolean?,
		DeprecatedGlobal: boolean?,
		GlobalUsedAsLocal: boolean?,
		LocalShadow: boolean?,
		SameLineStatement: boolean?,
		MultiLineStatement: boolean?,
		LocalUnused: boolean?,
		FunctionUnused: boolean?,
		ImportUnused: boolean?,
		BuiltinGlobalWrite: boolean?,
		PlaceholderRead: boolean?,
		UnreachableCode: boolean?,
		UnknownType: boolean?,
		ForRange: boolean?,
		UnbalancedAssignment: boolean?,
		ImplicitReturn: boolean?,
		DuplicateLocal: boolean?,
		FormatString: boolean?,
		TableLiteral: boolean?,
		UninitializedLocal: boolean?,
		DuplicateFunction: boolean?,
		DeprecatedApi: boolean?,
		TableOperations: boolean?,
		DuplicateCondition: boolean?,
		MisleadingAndOr: boolean?,
		CommentDirective: boolean?,
		IntegerParsing: boolean?,
		ComparisonPrecedence: boolean?,
	},
	lintErrors: boolean?,
	typeErrors: boolean?,
	globals: { string },
	aliases: { [string]: path },
}
local rc: luaurc = {
	languageMode = 'strict',
	lint = {},
	globals = {},
	aliases = {},
}
merge(rc, file.read_json('.luaurc') or {})

return rc
