local ascii = require('../ascii')

local myTable = ascii.new('eagora doido')

local arg1 = myTable.add_field('testando pra ver se funciona')
local arg2 = myTable.add_field('testando pra ver se funfa tb\n oloko')

arg1.set_value('aidneto\nbixo')
arg2.set_value('eagora sera q vai?')
arg1.align = 'left'
myTable.print_ascii()
