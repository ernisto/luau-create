local parser = require("./parser")
local ast = parser.parse([[option cavalo = 5

struct preto {
    ta: u8
}
]])

-- abstract syntax tree
print(ast)