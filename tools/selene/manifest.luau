local file = require('@lib/file')
local merge = require('@utils/merge')

-- defs
type severity = 'allow' | 'warn' | 'deny'
type pattern = string
type std = 'lua51' | 'lua52' | string
type glob = string
type lint =
	'almost_swaped'
	| 'constant_table_comparison'
	| 'deprecated'
	| 'divide_by_zero'
	| 'duplicate_keys'
	| 'empty_if'
	| 'empty_loop'
	| 'global_usage'
	| 'high_cyclomatic_complexity'
	| 'if_same_then_else'
	| 'ifs_same_cond'
	| 'incorrect_standard_library_use'
	| 'manual_table_clone'
	| 'mismatched_arg_count'
	| 'mixed_table'
	| 'multiple_statements'
	| 'must_use'
	| 'parenthese_conditions'
	| 'roblox_incorrect_color3_new_bounds'
	| 'roblox_incorrect_roact_usage'
	| 'roblox_manual_fromscale_or_fromoffset'
	| 'roblox_suspicious_udim2_new'
	| 'shadowing'
	| 'suspicious_reverse_loop'
	| 'type_check_inside_call'
	| 'unbalanced_assignmnents'
	| 'undefined_variable'
	| 'unscoped_variables'
	| 'unused_variable'
type manifest = {
	std: std?,
	lints: { [lint]: severity }?,
	config: {
		almost_swaped: boolean?,
		constant_table_comparison: boolean?,
		deprecated: { allow: { pattern }? }?,
		divide_by_zero: boolean?,
		duplicate_keys: boolean?,
		empty_if: { comments_count: boolean? }?,
		empty_loop: { comments_count: boolean? }?,
		global_usage: { ignore_pattern: pattern? }?,
		high_cyclomatic_complexity: { maximum_complexity: number? }?,
		if_same_then_else: boolean?,
		ifs_same_cond: boolean?,
		incorrect_standard_library_use: boolean?,
		manual_table_clone: boolean?,
		mismatched_arg_count: boolean?,
		mixed_table: boolean?,
		multiple_statements: {
			one_line_if: 'break-return-only' | 'allow' | 'deny'?,
		}?,
		must_use: boolean?,
		parenthese_conditions: boolean?,
		roblox_incorrect_color3_new_bounds: boolean?,
		roblox_incorrect_roact_usage: boolean?,
		roblox_manual_fromscale_or_fromoffset: boolean?,
		roblox_suspicious_udim2_new: boolean?,
		shadowing: { ignore_pattern: pattern? }?,
		suspicious_reverse_loop: boolean?,
		type_check_inside_call: boolean?,
		unbalanced_assignmnents: boolean?,
		undefined_variable: boolean?,
		unscoped_variables: { ignore_pattern: pattern? }?,
		unused_variable: {
			allow_unused_self: boolean?,
			ignore_pattern: pattern?,
		}?,
	}?,
	excludes: { glob }?,
}

-- module
local manifest: manifest = {
	lints = {},
	config = {},
	excludes = {},
}
merge(manifest, file.read_toml('selene.toml') or {})

-- end
return manifest
