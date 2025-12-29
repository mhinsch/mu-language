require './interp_node'
require './repl_macro'
require './scope'


class InterpOp
	attr_reader :eval_fn

	def initialize(run)
		@eval_fn = run
	end

	def evaluate(node, args)
		@eval_fn.call(node, args)
	end
end


class IType
	attr_reader :name, :default, :components

	def initialize(name, default, components)
		@name = name
		@default = default
		@components = components
	end

	def get_default
		if @default == nil
			if @components.empty?
				puts "neither default nor components"
				exit
			end

			@components.collect do |c|
				c.get_default
			end
		else
			@default
		end
	end
end


class Interpreter
	attr_reader :ast

	def initialize(ast)
		@ast = ast
	end
		
	# add function `name` that evaluates using function `oper`
	def add_op(name, oper, node=@ast)
		puts ":: #{name}"
		node.scope.add_op(name, InterpOp.new(oper))
	end

	# add a simple builtin type with a constant constructor
	def add_s_type(tname, default, node=@ast)
		tp = IType.new(tname, default, [])
		add_op(tname, lambda{|nod, args| self.default_constructor(nod.node_type)}, node)
		node.scope.add_type(tname, tp)
	end

	def join_blocks(_node, args)
		args[-1].code? || error("can't join non-code nodes")

		puts("joining")
		
		args[-1].scope.dump
		(args.size-2).downto(0) do |i|
			args[i].scope.dump
			args[i].dump_short; puts
			args[i].code? || error("can't join non-code nodes")
			args[-1].args.insert(0, *args[i].args)
		end

		args[-1].adjust_sub_scopes

		puts "joined blocks"
		args[-1].scope.dump
		args[-1].dump_short; puts
		
		args[-1]
	end
	
	def eval_as_tuple_type(members)
		members.each do |m|
			if m.node_type != :def
				puts "member definition expected"
				exit
			end
			
		end
	end
	
	def define(node, args)
		# variable definition
		val = args[1]
		lhs = args[0].unquote
		str = lhs.symbol
		idname = lhs.node_type

		if idname == :tidentifier
			type_def(str, val)
		elsif idname == :identifier
			node.scope.add_var(str, val)
		end

		val
	end


	def define_simple_function(node, args)
		val = args[1]
		lhs = args[0].unquote
		str = lhs.symbol

		if ! val.code?
			error("quote expected in fn def")
		end

		add_op(str, simple_function(val), node)
	end


	def define_macro(node, args)
		if args.length != 2
			error("defmacro needs two arguments")
		end

		pattern = args[0].unquote
		replacement = args[1].unquote

		# don't think that's necessary
		# pattern.fncall? || error("pattern must be a fn call")
		macro = ReplMacro.new(pattern, replacement)
		
		if (m = node.scope.lookup_macro(macro.name)) == nil
			node.scope.add_macro(macro.name, [macro])
		else
			m << macro
		end

		return nil
	end
		
	
	def apply_macro(args, macros)

		puts "macro - trying to match: "
		args.dump_short; puts
		
		macros.each do |m|
			mt = m.match(args)
			if mt != nil
				return m.replace(mt)
			end
		end
		puts "macro not found"
		nil
	end

	# TODO
	# compound types
	# parametric types
	#   = function type -> type
	
	def type_def(name, impl)
		if impl.node_type == :rccode 
			if impl.args[0].node_type != :tuple1
				puts "expected list of definitions"
				exit
			end
			
			t_obj, constructors = eval_as_tuple_type(impl.args[0])
			# only works for 1 ATM, needs overloading for more
			constructors.each do |c|
				add_op(name, c)
			end	
		elsif impl.node_type == :type
			t_obj = impl
		end
		
		@stack.add_type(name, t_obj)
	end
		
	def assign(node, args)
		lhside = args[0].unquote
		val = args[1]

		if lhside.node_type != :identifier
			puts "lvalue required"
			exit
		end

		vname = lhside.symbol
		ret = node.scope.lookup_name(vname, VAR, val)
		ret || error(node.line, "unable to assign to #{vname}")
		return val
	end
		
	
	def evaluate_quote(node, args = [])
		node.code? || error("not a quote")

		puts "bare eval quote:"
		node.scope.dump
		
		# $0, etc.
		args.each do |a|
			puts "auto var: #{a[0]} = #{a[1]}"
			node.scope.add_name(a[0], a[1], VAR)
		end
		
		puts "eval quote w/ args:"
		node.scope.dump

		ret = nil
		for arg in node.args
			print "scope line "; arg.scope.dump
			#arg.scope.parent == node.scope || error(1, "scope!!")
			ret = evaluate(arg)
		end

		ret
	end
	

	def evaluate(node)
		puts "> #{node.token.line}"
		ntype = node.node_type
		symbol = node.symbol
		puts "\t-> #{ntype}, #{symbol}"

		# variables
		if ntype == :identifier || ntype == :sidentifier
			var_name = symbol
			ret = node.scope.lookup_var(var_name)
			ret || error(node.line, "symbol #{var_name} not found")
			return ret
		end

		# types
		if ntype == :tidentifier
			type_name = symbol
			ret = node.lookup_type(type_name)
			ret || error(node.line, "type #{type_name} not found")
			return ret
		end

		# code
		if ntype == :rocode || ntype == :rccode
			return node
		end

		# literals
		if node.token.typ == :term
			op = node.scope.lookup_op(ntype)
			op || error(node.line, "op #{ntype} not found")
			return op.evaluate(node, [])
		end

		# everything else is operators or function calls
		if ntype == :call
			op_args = node.call_args
			oper = node.call_oper
			# function
			if oper.node_type == :identifier || oper.node_type == :sidentifier
				op_name = oper.symbol
			# builtin operator
			else
				op_name = oper.node_type
			end

			puts "calling #{op_name}"
			
			if (macros = node.scope.lookup_macro(oper.symbol))
				puts "found macro #{symbol}:"
				puts "----"
				repl_node = apply_macro(node, macros)

				if repl_node == nil
					puts(node.token.line, "no match found for macro #{op_name}")
				else
					# quick and dirty solution
					# TODO do properly
					repl_node.copy_scope(node)			
					puts "macro result:"
					repl_node.scope.dump
					repl_node.dump_short; puts
					return evaluate(repl_node)
				end
			end
			op = node.scope.lookup_op(op_name)
			op || error(node.line, "op #{op_name} not found")
			op_args.map!{|arg| evaluate(arg)}
			#puts "args: #{op_args}"
			return op.evaluate(node, op_args)
		end

		error(node.token.line, "unknown node #{ntype}")
	end

	def run
		evaluate_quote(@ast)
	end
end


def binary(op)
	lambda {|node, args| args[0].public_send(op, args[1])}
end


def simple_function(body)
	if body.node_type != :rccode
		puts "fn decl requires c-code block"
		exit
	end

	lambda do |_node, arg_values|
		puts "sf lambda node: "
		_node.dump_short; puts
		puts "sf lambda body: "
		body.dump_short; puts
		fn_args = [[:$0, Node.create_call(",", :tuple, args:arg_values)]]
		for i in 0...arg_values.size
			fn_args << ["$#{i+1}".to_sym, arg_values[i]]
		end

		evaluate_quote(body, fn_args)
	end
end

def function(fn_decl)
	arg_decl = fn_decl.args[0]
	if arg_decl.node_type != :rccode
		puts "fn decl requires arg block"
		exit
	end

	args = arg_decl.args
	if args.size == 0
		arg_list = []
	elsif args.size == 1 && args[0].node_type == :identifier
		arg_list = [args[0]]
	elsif args.size == 1 && args[0].node_type == :tuple1
		arg_list = args[0].args
	else
		puts "malformed arg list"
		exit
	end
	
	fn_body = fn_decl.args[1]
	if fn_body.node_type != :rccode
		puts "fn decl requires c-code block"
		exit
	end

	lambda do |node, args|

		if arg_list.size != args.size
			puts "#{arg_list.size} arguments expected"
			exit
		end

		fn_args = []
		for i in 0...arg_list.size
			arg = arg_list[i].symbol
			val = args[i]
			fn_args << [arg, val]

			puts("arg ##{i}: #{arg} = #{val}")
		end

		evaluate_quote(fn_body, fn_args)
	end
end


def config_interp(int)
	int.add_s_type :I, 0
	int.add_s_type :F, 0.0
	int.add_s_type :S, ""
	
	int.add_op :$defvar, lambda{ |node, args| int.define(node, args) }
	int.add_op :$defsfun, lambda{ |node, args| int.define_simple_function(node, args) }
	int.add_op :$replace, lambda{ |node, args| int.define_macro(node, args) }
	int.add_op :$assign, lambda{ |node, args| int.assign(node, args) }
	
	int.add_op :nop, lambda{|node, args| nil}

	int.add_op :integer, lambda{|node, args| node.token.string.to_i}
	int.add_op :string, lambda{|node, args| node.token.string}

	int.add_op :tuple1, lambda{|node, args| [*args]}
	
	int.add_op :index, lambda{|node, args| args[0][args[1]]}

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

	int.add_op :println, lambda{|node, args| puts args}

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
