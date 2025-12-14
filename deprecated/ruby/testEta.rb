require 'rubygems'
require 'treetop'
require 'eta'
require 'nodes'
require 'semantics'
require 'declare'
require 'compile2C'


#ns_typeOps = Namespace.new
#ns_typeOps.add(T_Type.new(:type))
#ns_typeOps.add(T_Op_TypeTuple.new(','))
#ns_typeOps.add(T_Op_NewType.new('@'))
#ns_typeOps.add(T_Op_Symbol.new('__SYM__'))
#ns_typeOps.add(T_Op_NewTypeIni.new('='))

ns_declare = Namespace.new
ns_declare.add(D_T_Type.new('float'))
ns_declare.add(D_T_Type.new('int'))

ns_declare.add(D_T_Symbol.new('__SYM__'))
ns_declare.add(D_T_Expression.new('__NUM__'))
ns_declare.add(D_T_NewSymbol.new('@'))
ns_declare.add(D_T_NewSymbolIni.new(':'))
ns_declare.add(D_T_Tuple.new(','))
ns_declare.add(D_T_Block.new('{}'))

ns_c2c = Namespace.new
ns_c2c.add(C2C_Oper.new('*', 6, '*'))
ns_c2c.add(C2C_Oper.new('+', 5, '+'))
ns_c2c.add(C2C_Oper.new('=', 0, '='))
ns_c2c.add(C2C_Oper.new(',', 1, ','))
ns_c2c.add(C2C_Decl.new('@'))
ns_c2c.add(C2C_DeclIni.new(':'))
ns_c2c.add(C2C_FCall.new('`'))
ns_c2c.add(C2C_Block.new('{}'))
ns_c2c.add(C2C_Terminal.new('__SYM__'))
ns_c2c.add(C2C_Terminal.new('__NUM__'))
ns_c2c.add(C2C_Terminal.new('__STR__'))

code = File.new("test.eta", "r").read

parser = EtaParser.new
ret = parser.parse(code)
if ret
	puts "success!"
#	puts ret.inspect
	tree = ret.tree
	tree.print ""
	puts "..."
	tree = tree.lift
	tree.print ""
	
	tree.setBlock(nil)
	#	tree.setNamespace('declare', ns_declare)
	#	tree.evaluate('declare')
	tree.setNamespace('c2c', ns_c2c)
	puts "c2c:\n"
	puts tree.evaluate('c2c')
	puts
	
	tree.print ""
	#	ret.prune
#	puts ret.inspect
	
else
	puts "error on line " + parser.failure_line.to_s
	puts "reason: " + parser.failure_reason
	end