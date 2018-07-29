require 'rubygems'
require 'parslet'
require 'pp'
require 'awesome_print'

class MiniP < Parslet::Parser

	def MiniP.buildNaryOp(name, lower)
		op_name = "op_" + name.to_s

		# e.g. (prod >> (op_sum >> prod).rep(1)).as(:sum) | prod
		rule(name) {
			( eval(lower.to_s) >> (eval(op_name) >> eval(lower.to_s).as(:opd)).repeat(1) ).as(name) |
   			eval(lower.to_s)
			}
	end

	def MiniP.buildNary(name, lower)
		name_s = name.to_sym
		op_name = "op_" + name

		rule(name_s) {
			( eval(lower) >> (eval(op_name) >> eval(lower)).repeat(1) ).as(name_s) |
   			eval(lower)	
			}
	end

	def MiniP.buildNaryOpt(name, lower)
		name_s = name.to_sym
		op_name = "op_" + name

		rule(name_s) {
			( eval(lower).maybe >> (eval(op_name) >> eval(lower).maybe).repeat(1) ).as(name_s) |
   			eval(lower)
			}
	end

	# Space
	rule(:space)      	{ match('[\t ]').repeat(1) }
	rule(:sp?)     		{ space.maybe }

	rule(:space_nl)  	{ sp? >> match('\n') >> sp? }
	rule(:sp_nl?) 		{ sp? >> (match('\n') >> sp?).maybe }

	# Operators
	rule(:lparen)     	{ str('(') >> sp_nl? }
	rule(:rparen)     	{ str(')') >> sp? }
	rule(:lbrace)     	{ str('{') >> sp_nl? }
	rule(:rbrace)     	{ str('}') >> sp? }
	rule(:lsquare)     	{ str('[') >> sp_nl? }
	rule(:rsquare)     	{ str(']') >> sp? }

	rule(:op_prod)		{ match('[*/%]').as(:op) >> sp_nl? }
	rule(:op_sum)		{ match('[-+]').as(:op) >> sp_nl? }

	rule(:nl)			{ match('[;\n]') }
	rule(:top_sep)		{ nl >> sp? }
	rule(:op_tuple)     { str(',') >> sp_nl? }

	rule(:op_assign)	{ str('=').as(:op) >> sp_nl? }
	rule(:op_ini)		{ str(':').as(:op) >> sp_nl? }

	# Literals
	rule(:integer)    	{ match['0-9'].repeat(1).as(:num) >> sp? }
	rule(:identifier) 	{ match['a-z'].repeat(1).as(:var) >> sp?}

	# Grammar parts
	rule(:p_exp)		{ lparen >> expression.as(:exp) >> rparen }
	rule(:b_exp)		{ lbrace >> expression.as(:b_exp) >> rbrace }
	rule(:s_exp)		{ lsquare >> expression.as(:s_exp) >> rsquare }

	rule(:atom)			{ integer | identifier | p_exp | b_exp }

	rule(:fun_call)		{ ( atom >> atom.repeat(1) ).as(:fun) | atom }

	hierarchy = [:fun_call, :prod, :sum, :ini, :tuple, :assign]

	for i in 0..(hierarchy.length-2) do
		buildNaryOp(hierarchy[i+1], hierarchy[i])
	end

	rule(:expression) 	{ ( assign.maybe >> (top_sep >> assign.maybe).repeat ).as(:tuple) }


	root :expression
end

$LOAD_PATH.unshift File.dirname(__FILE__)
require 'parsetree'


class MiniT < Parslet::Transform
	def MiniT.buildOp(name)
		rule(name.to_sym => sequence(:elems))		{Oper.new(name, elems)}
	end

	rule(:num => simple(:str))                        	{ Lit.new(:num, str) }
	rule(:var => simple(:str))                       	{ Lit.new(:var, str) }
	rule(:op => subtree(:oper), :opd => subtree(:operd)){Oper.new(oper, [operd]) }
	buildOp(:prod)
	buildOp(:sum)
	rule(:tuple => sequence(:e))						{ e }
	#rule(:tuple => subtree(:e))							{ e }
	buildOp(:assign)
	#buildOp(:fun)
	#rule(:exp => subtree(:e))							{ e }
	#rule(:b_exp => sequence(:e))						{ Oper.new(";", e) }
	#rule(:b_exp => subtree(:e))							{ Oper.new(";", [e]) }
#	rule(:etuple => subtree(:e))						{ e }
#	rule(:sum => sequence(:elems))						{ Oper.new(:sum, elems) }
end


def parse_and_show(code, parser, transf)
	puts 'tree:'
	puts
	pp tree = parser.parse(code)

	puts	
	puts 'transform:'
	puts

	t2 =  transf.apply(tree)
	pp t2
	puts
	t2.each {|t| t.pprint($stdout, 0)}

	puts
	puts "reshuffle"
	puts
	
	t3 = t2.collect{|t| t.reshuffle}

	t3.each {|t| t.pprint($stdout, 0)}
	puts
	puts 'scope'
	puts

	#pp t2.scope(nil)
end

parser = MiniP.new
transf = MiniT.new

require 'syntax'

if ARGV[0] == "-i"
	while true do
		code = gets
		if code == ""
			break
		end

		puts code

		parse_and_show(code, parser, transf)
	end
else
	code = $stdin.readlines.join
	puts code
	parse_and_show(code, parser, transf)
end

