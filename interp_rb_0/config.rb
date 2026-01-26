def config_tokeniser(ter)
	ter.whitespace /\G[ \t]+/
	ter.whitespace /\G;;[^\n]*/

	ter.term /\G[a-z][a-zA-Z0-9_]*/, :identifier
	ter.term /\G[A-Z][a-zA-Z0-9_]*/, :tidentifier
	ter.term /\G\$[a-zA-Z0-9_]+/, :sidentifier
	# not elegant but quick solution
	ter.term /\G\$:[a-zA-Z0-9_]+/, :opidentifier
	ter.term /\G-?[0-9]+/, :integer
	ter.term /\G"[^"]*"/, :string

	# operators
	ter.op "::", :fundef, true
	ter.op ":=>", :defmacro, true
	ter.op ":", :def, true
	ter.op ";", :tuple0, true
	ter.op "\n", :tuple0, true
	ter.op "=>", :arrow, true
	ter.op "==", :isequal, true
	ter.op "<", :isless, true
	ter.op ">", :isgreater, true
	ter.op "<>", :isunequal, true
	ter.op "=", :assign, true
	ter.op "'", :call, true
	ter.op ",*", :splat, true
	ter.op ",", :tuple1, true
	ter.op "+", :plus, true
	ter.op "-", :minus, true
	ter.op "*", :times, true
	ter.op "/", :divide, true
	ter.op "^", :power, true
	ter.op "#", :index, true
	ter.op ".", :s_index, true
	ter.op "\\", :insert, false
	ter.op "(", :lpar, true
	ter.op ")", :rpar, false
	ter.op "[", :locode, true
	ter.op "]", :rocode, false
	ter.op "{", :lccode, true
	ter.op "}", :rccode, false
end


def config_parser(par)
	par.infix :tuple0, 10, true 
	par.infix :assign, 20
	par.infix :call, 30
	par.infix :splat, 49, true
	par.infix :tuple1, 50, true 

	par.infix :def, 60
	par.infix :defmacro, 60
	par.infix :fundef, 60

	par.infix :arrow, 70
	par.infix :isequal, 70
	par.infix :isless, 70
	par.infix :isgreater, 70
	par.infix :isunequal, 70

	par.infix :plus, 100
	par.infix :minus, 100
	
	par.infix :times, 200
	par.infix :divide, 200

	par.infix :power, 300

	par.infix :juxt, 500

	par.infix :index, 600
	par.infix :s_index, 600

	par.prefix :insert, 1000
	
	par.parens :lpar, :rpar
	par.parens :locode, :rocode
	par.parens :lccode, :rccode

	par.term :identifier
	par.term :tidentifier
	par.term :sidentifier
	par.term :opidentifier
	par.term :integer
	par.term :string
	par.term :nop
end
