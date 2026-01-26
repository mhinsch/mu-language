require 'irb'


require './parser.rb'
require './config.rb'
require './cleanup.rb'
require './decl.rb'


ter = Tokeniser.new
config_tokeniser(ter)

par = Parser.new
config_parser(par)

ts = ter.tokenise("

{

bla

}")

#ts.each do |t|
	#print(t.name, "(#{t.string}) ")
#	print(t.name, " ")
#end
#puts

#terms, _ = par.parse(ts)

#terms[0].dump

#puts
#puts


prog = "{

x : [test, test2]

a : I
b : 42
c : 1

a = a + b + c - (3 + 5) ;; bla

;; comment 

fst : 1 * 
	a (b, c)
; ( x, y,z, (1, 2)) ;
}"

ts = ter.tokenise(prog)

ts.each do |t|
	print(t.name, " ")
end

terms, _ = par.parse(ts)

ast = terms[0]
ast.flatten_naries(Set[:tuple1, :tuple0])
ast.remove_pars

ast.check_scope(nil)

ast.register_defs

ast.dump(0, false)

binding.irb
