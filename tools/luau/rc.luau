local file = require('@lib/file')
local merge = require('@utils/merge')

-- defs
type path = string
type lint =
	'*' -- all
	| 'UnknownGlobal'
	| 'DeprecatedGlobal'
	| 'GlobalUsedAsLocal'
	| 'LocalShadow'
	| 'SameLineStatement'
	| 'MultiLineStatement'
	| 'LocalUnused'
	| 'FunctionUnused'
	| 'ImportUnused'
	| 'BuiltinGlobalWrite'
	| 'PlaceholderRead'
	| 'UnreachableCode'
	| 'UnknownType'
	| 'ForRange'
	| 'UnbalancedAssignment'
	| 'ImplicitReturn'
	| 'DuplicateLocal'
	| 'FormatString'
	| 'TableLiteral'
	| 'UninitializedLocal'
	| 'DuplicateFunction'
	| 'DeprecatedApi'
	| 'TableOperations'
	| 'DuplicateCondition'
	| 'MisleadingAndOr'
	| 'CommentDirective'
	| 'IntegerParsing'
	| 'ComparisonPrecedence'
type luaurc = {
	languageMode: 'strict' | 'nostrict' | 'nocheck'?,
	lint: { [lint]: boolean },
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
