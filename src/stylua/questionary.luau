local question = require('@lib/question')

return question.struct {
    name = 'stylua',
    question.enum {
        name = 'syntax',
        desc = `Specify a disambiguation for the style of Lua syntax being formatted.`,
        { name = 'All', desc = `with a union of all syntax styles` },
        { name = 'Luau', desc = `Luau syntax`},
        { name = 'LuaJIT', desc = `LuaJIT syntax`},
        { name = 'Lua51', desc = `Lua version 5.1 syntax`},
        { name = 'Lua52', desc = `Lua version 5.2 syntax`},
        { name = 'Lua53', desc = `Lua version 5.3 syntax`},
        { name = 'Lua54', desc = `Lua version 5.4 syntax`},
    },
    question.int {
        name = 'column_width',
        desc = `Approximate line length for printing. Used as a guide for line wrapping - this is not a hard requirement: lines may fall under or over the limit.`,
        default = '120'
    },
    question.enum {
        name = 'line_endings',
        desc = `Line endings type`,
        { name = 'Unix', desc = `LF (\\n)` },
        { name = 'Windows', desc = `CRLF (\\r\\n)` },
    },
    question.enum {
        name = 'indent_type',
        { name = 'Spaces' },
        { name = 'Tabs' },
    },
    question.int {
        name = 'indent_width',
        desc = `Character size of single indentation. If indent_type is set to Tabs, this option is used as a heuristic to determine column width only.`,
        default = '4'
    },
    question.enum {
        name = 'quote_style',
        desc = `Quote style for string literals`,
        { name = 'AutoPreferDouble', desc = `AutoPrefer styles will prefer \`"\`, but fall back to the alternative if it has fewer string escapes.` },
        { name = 'AutoPreferSingle', desc = `AutoPrefer styles will prefer \`'\`, but fall back to the alternative if it has fewer string escapes.` },
        { name = 'ForceDouble', desc = `Force styles always use \`"\` regardless of escapes.` },
        { name = 'ForceSingle', desc = `Force styles always use \`'\` regardless of escapes.` },
    },
    question.enum {
        name = 'call_parentheses',
        desc = `Whether parentheses should be applied on function calls with a single string/table argument.`,
        { name = 'Always', desc = `Applies parentheses in all cases` },
        { name = 'NoSingleString', desc = `Omits parentheses on calls with a single string argument.` },
        { name = 'NoSingleTable', desc = `Omits parentheses on calls with a single table argument.` },
        { name = 'None', desc = `Omits parentheses in both cases. Note: parentheses are still kept in situations where removal can lead to obscurity (e.g. foo "bar".setup -> foo("bar").setup, since the index is on the call result, not the string)` },
        { name = 'Input', desc = `Removes all automation and preserves parentheses only if they were present in input code: consistency is not enforced.` }
    },
    question.enum {
        name = 'space_after_function_names',
        desc = `Specify whether to add a space between the function name and parentheses.`,
        { name = 'Never' },
        { name = 'Definitions' },
        { name = 'Calls' },
        { name = 'Always' }
    },
    question.enum {
        name = 'collapse_simple_statement',
        desc = `Specify whether to collapse simple statements.`,
        { name = 'Never' },
        { name = 'FunctionOnly' },
        { name = 'ConditionalOnly' },
        { name = 'Always' }
    },
    question.struct {
        name = 'sort_requires',
        question.bool { name = 'enabled', default = false }
    }
}