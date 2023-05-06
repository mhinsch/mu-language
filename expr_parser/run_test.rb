require './parser.rb'
require './config.rb'
require './cleanup.rb'


ter = Tokeniser.new
config_tokeniser(ter)

par = Parser.new
config_parser(par)

ts = ter.tokenise("

{

bla

}")

ts.each do |t|
	#print(t.name, "(#{t.string}) ")
	print(t.name, " ")
end
puts

terms, _ = par.parse(ts)

terms[0].dump



puts
puts


prog = "{
a = a + b + c - (3 + 5) ;; bla
;; comment 
fst = 1 *
	a b
; ( , ) ;
}"

ts = ter.tokenise(prog)

ts.each do |t|
	print(t.name, " ")
end

terms, _ = par.parse(ts)

#terms[0].flatten

terms[0].dump(0, false)

