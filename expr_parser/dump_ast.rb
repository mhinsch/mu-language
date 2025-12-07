require './parser.rb'
require './config.rb'
require './cleanup.rb'
require './decl.rb'


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
ast.remove_nops(:nop)
ast.fun_arg_tuples
ast.standardise_op_calls(Set[:plus, :minus, :times, :divide, :power])


ast.dump(0, true)
