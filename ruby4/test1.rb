require 'rubygems'
require 'parslet'
require 'pp'
require 'awesome_print'

class MiniP < Parslet::Parser

	def MiniP.buildOp(name, lower)
		e_name = 'exp_' + name
		o_name = 'op_' + name
		e_name_lower = 'exp_' + lower

		# this produces something like:
		# [:opd=>{:num=>"1"}, {:op=>"+", :opd=>{:var=>"a"}, ...}
		# a bit complicated but makes matching much easier later since
		# we can't match the second part generically (this way we use {:op, :opd})
		rule(e_name.to_sym)		{(eval(e_name_lower).as(:opd) >> 
								  (eval(o_name) >> eval(e_name_lower).as(:opd)).
								  	repeat(1)).as(name.to_sym) |
								 eval(e_name_lower)}
	end

	rule(:ml_comment)	{ str(";-") >> (str('-;').absent? >> any).repeat >> str("-;") }
	rule(:sl_comment)	{ str(";;") >> match('[^\n]').repeat }

	# Space
	rule(:space)		{ match('[\t ]') | ml_comment | sl_comment }
	rule(:sp)  	    	{ space.repeat(1) }
	rule(:sp?)     		{ space.repeat }

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

	rule(:nl)			{ match('\n') >> sp? }
	rule(:top_sep)		{ str(';') >> sp? }
	rule(:op_tuple)     { str(',').as(:op) >> sp_nl? }

	rule(:op_fun)		{ str('`').as(:op) >> sp_nl? }

	rule(:op_assign)	{ str('=').as(:op) >> sp_nl? }
	rule(:op_ini)		{ str(':').as(:op) >> sp_nl? }

	# Literals
	rule(:integer)    	{ match('[0-9]').repeat(1).as(:num) >> sp?}
	rule(:id_var) 		{ (match('[a-z]') >> match('[a-zA-Z_0-9]').repeat).as(:var) >> sp? }
	rule(:id_typ) 		{ (match('[A-Z]') >> match('[a-zA-Z_0-9]').repeat).as(:typ) >> sp? }

	# Grammar parts
	rule(:p_exp)		{ lparen >> tl_exp_lines.as(:exp) >> rparen }
	rule(:b_exp)		{ lbrace >> tl_exp_lines.as(:b_exp) >> rbrace }
	rule(:s_exp)		{ lsquare >> tl_exp_lines.as(:s_exp) >> rsquare }

	rule(:atom)			{ integer | id_var | id_typ | p_exp | b_exp | s_exp}

	rule(:exp_fun2)		{ ( atom >> atom.repeat(1) ).as(:fun2) | atom }

	hierarchy = ['fun2', 'prod', 'sum', 'ini', 'tuple', 'fun', 'assign']

	for i in 1...hierarchy.length do
		buildOp(hierarchy[i], hierarchy[i-1])
	end

	rule(:tl_expression){ (exp_assign >> (top_sep >> exp_assign).repeat(1)) | exp_assign }
	rule(:tl_exp_lines) { 
		tl_expression >> (nl.repeat(1) >> tl_expression).repeat >> nl.repeat }

	rule(:file)			{ match('[^{]').repeat >> b_exp >> sp_nl? }

	root :file
end

$LOAD_PATH.unshift File.dirname(__FILE__)
require 'parsetree'


class MiniT < Parslet::Transform
	def MiniT.buildOp(name)
		rule(name => subtree(:elems))					{Oper.new(name, elems)}
	end

	# sort out single element hashes
	[:num, :var, :typ].each do |el|
		rule(el => simple(:str))                        	{ Lit.new(el, str) }
	end
	
	# makes i=0 element conform to rest
	rule(:opd => simple(:e))							{ [nil, e] }
	# all i=1...n elems of an expression have this form
	# make them 2-element arrays for convenience
	rule(:op => simple(:optor), :opd => simple(:e))		{[optor, e]}

	# rename to regular function call
	rule(:fun2 => subtree(:e))					{Oper.new(:fun, e.collect{|el| ["`",el]})}

	rule(:b_exp => subtree(:e))					{Exp.new(:b_exp, e)}
	rule(:s_exp => subtree(:e))					{Exp.new(:s_exp, e)}
	rule(:exp => subtree(:e))					{e}
	# build operator rules

	buildOp(:prod)
	buildOp(:sum)
	buildOp(:ini)
	buildOp(:tuple)
	buildOp(:fun)
	buildOp(:assign)
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

	puts
	puts "reshuffle"
	puts
	
	t3 = t2.to_tree
	pp t3
	puts
	t3.pprint($stdout, 0)
	puts

	t3.sprint($stdout)

	puts
	puts "scope"

	global_sc = Scope.new(nil, nil, nil)
	t3.assign_scope(global_sc)

	puts
	puts "decl"

	t3.declare!

	puts
	puts "check decl"
	t3.check_declared
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

