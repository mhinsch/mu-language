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
	ter.op "!", :ref, false
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

	par.postfix :ref, 800
	
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


def config_interp(int)
	int.add_s_type :I, 0
	int.add_s_type :F, 0.0
	int.add_s_type :S, ""
	
	int.add_op :$defvar, lambda{ |node, args| int.define(node, args) }
	int.add_op :$defsfun, lambda{ |node, args| int.define_simple_function(node, args) }
	int.add_op :$replace, lambda{ |node, args| int.define_macro(node, args) }
	int.add_op :$assign, lambda{ |node, args| int.assign(node, args) }
	int.add_op :$mut, lambda{ |node, args| int.check_mutability(node, args) }
	
	int.add_op :nop, lambda{|node, args| nil}

	int.add_op :integer, lambda{|node, args| node.token.string.to_i}
	int.add_op :string, lambda{|node, args| node.token.string}

	int.add_op :splat, lambda{|node, args|
		res = args[0].is_a?(Array) ? args[0] : [ args[0] ]
		res + (args[1].is_a?(Array) ? args[1] : [ args[1] ])
		}
	int.add_op :tuple1, lambda{|node, args| [*args]}
	
	int.add_op :$index, lambda{|node, args| int.static_index(node, args)}
	int.add_op :s_index, lambda{|node, args| args[0][args[1]]}

	int.add_op :arrow, lambda{|node, args| int.join_blocks(node, args) }
	
	int.add_op :plus, binary(:+)
	int.add_op :minus, binary(:-)
	int.add_op :times, binary(:*)
	int.add_op :divide, binary(:/)
	int.add_op :power, binary(:^)
	int.add_op :isequal, binary(:==)
	int.add_op :isunequal, binary(:!=)
	int.add_op :isless, binary(:<)
	int.add_op :isgreater, binary(:>)

	int.add_op :println, lambda {|node, args|
		args || error(0, "println needs non-nil arg")
		puts args }

	int.add_op :if, lambda{|node, args|
		if args[0] == true
			int.evaluate_quote(args[1])
		elsif args.length > 2
			int.evaluate_quote(args[2])
		else
			nil
		end}

	int.add_op :while, lambda{|node, args|
		while int.evaluate_quote(args[0])
			int.evaluate_quote(args[1])
		end} 
end
