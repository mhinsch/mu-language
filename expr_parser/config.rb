def config_tokeniser(ter)
	ter.whitespace /\G[ \t]+/
	ter.whitespace /\G;;[^\n]*/

	ter.term /\G[a-zA-Z][a-zA-Z0-9]*/, :identifier
	ter.term /\G-?[0-9]+/, :integer

	# operators
	ter.op ":", :def, true
	ter.op ";", :tuple0, true
	ter.op "\n", :tuple0, true
	ter.op "=", :equal, true
	ter.op ",", :tuple1, true
	ter.op "+", :plus, true
	ter.op "-", :minus, true
	ter.op "*", :times, true
	ter.op "/", :divide, true
	ter.op "^", :power, true
	ter.op "(", :lpar, true
	ter.op ")", :rpar, false
	ter.op "[", :locode, true
	ter.op "]", :rocode, false
	ter.op "{", :lccode, true
	ter.op "}", :rccode, false
end


def config_parser(par)
	par.infix :tuple0, 10, true 
	par.infix :equal, 20
	par.infix :tuple1, 50, true 
	par.infix :def, 60
	par.infix :plus, 100
	par.infix :minus, 100
	par.infix :times, 200
	par.infix :divide, 200
	par.infix :power, 300
	par.infix :juxt, 500

	par.parens :lpar, :rpar
	par.parens :locode, :rocode
	par.parens :lccode, :rccode

	par.term :identifier
	par.term :integer
	par.term :nop
end
