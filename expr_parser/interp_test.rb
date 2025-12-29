require 'irb'


require './parser.rb'
require './config.rb'
require './cleanup.rb'
require './decl.rb'
require './interp.rb'


ter = Tokeniser.new
config_tokeniser(ter)

par = Parser.new
config_parser(par)


prog = File.open(ARGV[0], "r").readlines.join


puts "-----"
puts prog
puts "-----"

ts = ter.tokenise(prog)

terms, _ = par.parse(ts)

ast = terms[0]
ast.flatten_naries(Set[:tuple1, :tuple0])
ast.remove_pars
#ast.remove_nops(:nop)
#ast.dump(0, true)
ast.fun_arg_tuples
ast.standardise_op_calls(Set[:plus, :minus, :times, :divide, :power, :def, :tuple1, :index,
	:isequal, :isless, :defmacro, :assign, :arrow])
ast.assign_scope(nil)

#ast.register_defs

ast.dump(0, true)

int = Interpreter.new(ast)
config_interp(int)
puts int.run

#ast.dump(0, true)

binding.irb
