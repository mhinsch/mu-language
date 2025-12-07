class InterpOp
	attr_reader :evaluate

	def initialize(run)
		@evaluate = run
	end

	def evaluate(node, args)
		@evaluate.call(node, args)
	end
end

MACRO = 0
VAR = 1
OP = 2
TYPE = 3


class IScope
	attr_reader :scopes, :node

	def initialize(node)
		@node = node
		@scopes = [Hash.new, Hash.new, Hash.new, Hash.new]
	end

	def has_name?(name, kind)
		@scopes[kind].has_key?(name)
	end

	def name(name, kind)
		@scopes[kind][name]
	end

	def add_name(name, val, kind)
		@scopes[kind][name] = val
	end
		
	def set_value(name, kind, val)
		@scopes[kind][name] = val
	end
	
	def is_open?
		@node.op.name == :rocode
	end
end


class IStack
	attr_reader :scopes

	def initialize
		@scopes = [IScope.new(nil)]
	end
	
	def dump
		@scopes.reverse_each do |scope|
			puts scope.node == nil ? "((" : (scope.is_open? ? "[" : "{")
			puts "VAR"
			puts scope.scopes[VAR]
			puts "OP"
			puts scope.scopes[OP]
			puts "TYPE"
			puts scope.scopes[TYPE]
			puts scope.node == nil ? "))" : (scope.is_open? ? "]" : "}")
		end
	end

	def lookup_name(name, kind, new_val = nil, required = true)
#		puts "looking up #{name} #{name.class}, readonly: #{new_val == nil}"
		@scopes.reverse_each do |scope|
			if scope.has_name?(name, kind)
				if new_val != nil
					scope.set_value(name, kind, new_val)
				end
				return scope.name(name, kind)
			end
			if ! scope.is_open?
				break
			end
		end

#		puts "checking global scope"

		kname = case kind
			when MACRO
				"macro"
			when VAR
				"var"
			when OP
				"op"
			when TYPE
				"type"
			end
		
		# check in global scope
		# global scope is readonly, so no setting of variables
		if @scopes[0].has_name?(name, kind)
			if new_val != nil 
				puts "#{kname} #{name} global scope is readonly"
			else
				return @scopes[0].name(name, kind)
			end
		end

		if required
			puts "#{kname} #{name} not found"
			dump

			throw "exec error"
		end

		nil
	end

	def lookup_macro(vname)
		lookup_name(vname, MACRO, nil, false)
	end

	def add_macro(vname, val)
		puts "adding macro #{val.symbol}"
		@scopes.last.add_name(vname, val, MACRO)
	end
	
	def lookup_var(vname)
		lookup_name(vname, VAR)
	end

	def add_var(name, val)
		@scopes.last.add_name(name, val, VAR)
	end

	def set_value(name, val)
		lookup_name(name, VAR, val)
	end
	
	def lookup_op(oname)
		lookup_name(oname, OP)
	end

	def add_op(name, val)
		@scopes.last.add_name(name, val, OP)
	end

	def lookup_type(tname)
		lookup_name(tname, TYPE)
	end

	def add_type(name, val)
		@scopes.last.add_name(name, val, TYPE)
	end

	def push(node, args)
		@scopes << IScope.new(node)
		args.each do |arg| 
			add_var(arg[0], arg[1])
		end
	end

	def pop()
		@scopes.pop
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
	attr_reader :stack

	def initialize
		@stack = IStack.new
	end

	def print_stack
		@stack.dump
	end
	
	def lookup_macro(vname)
		@stack.lookup_macro(vname)
	end
		
	def add_macro(name, val)
		@stack.add_macro(name, val)
	end
	
	def lookup_var(vname)
		@stack.lookup_var(vname)
	end
		
	def add_var(name, val)
		@stack.add_var(name, val)
	end

	def set_value(name, val)
		@stack.set_value(name, val)
	end

	def lookup_op(oname)
		@stack.lookup_op(oname)
	end
		
	# add function `name` that evaluates using function `oper`
	def add_op(name, oper)
		puts ":: #{name}"
		@stack.add_op(name, InterpOp.new(oper))
	end
	
	def lookup_type(tname)
		@stack.lookup_type(tname)
	end

	def add_type(name, val)
		puts ":T #{name}"
		@stack.add_type(name, val)
	end

	# add a simple builtin type with a constant constructor
	def add_s_type(tname, default)
		tp = IType.new(tname, default, [])
		add_op(tname, lambda{|node, args| self.default_constructor(node.op.name)})
		add_type(tname, tp)
	end

	def eval_as_tuple_type(members)
		members.each do |m|
			if m.op.name != :def
				puts "member definition expected"
				exit
			end
			
		end
	end
	
	def define(node, args)
		#puts "define LHS:"
		#args[0].dump(0, true)
		#puts "define RHS:"
		#args[1].dump(0, true)

		# variable definition
		val = args[1]
		lhs = args[0].args[0]
		str = lhs.symbol
		idname = lhs.op.name

		if idname == :tidentifier
			type_def(str, val)
		elsif idname == :identifier
			add_var(str, val)
		end

		val
	end

	def define_macro(node, args)
		# mdef->quote->call->op
		str = args[0].args[0].args[0].op.name
		add_macro(str, args[1].args[0])

		return nil
	end
		

	# TODO
	# compound types
	# parametric types
	#   = function type -> type
	
	def type_def(name, impl)
		if impl.op.name == :rccode 
			if impl.args[0].op.name != :tuple1
				puts "expected list of definitions"
				exit
			end
			
			t_obj, constructors = eval_as_tuple_type(impl.args[0])
			# only works for 1 ATM, needs overloading for more
			constructors.each do |c|
				add_op(name, c)
			end	
		elsif impl.op.name == :type
			t_obj = impl
		end
		
		@stack.add_type(name, t_obj)
	end
		

	# replace $0... in node with args[...]
	def insert_args(node, args)
		if node.op.name == :sidentifier && (m = node.symbol.match(/\$([0-9]+)/))
			puts "found macro arg #{node.symbol}!"
			idx = m[1].to_i
			return args[idx]
		end

		node.args.each_index do |i|
			node.args[i] = insert_args(node.args[i], args)
		end

		node	
	end
	
	
	def apply_macro(node, template)
		args = node.args

		new_node = template.copy
		puts "applying macro!"
		node.dump(0, true)
		puts "===>"
		insert_args(new_node, args)
		new_node.dump(0, true)
		new_node
	end
		
	
	def evaluate_quote(node, args = [])
		if node.op.name != :rccode && node.op.name != :rocode
			puts "not a quote"
			exit
		end

		@stack.push(node, args)

		ret = nil
		for arg in node.args
			ret = evaluate(arg)
		end

		@stack.pop
		ret
	end
	

	def evaluate(node, resolve_macros=true)
		name = node.op.name
		symbol = node.symbol
		puts "\t## #{name}, #{symbol}"

		# variables
		if name == :identifier
			vname = symbol
			return lookup_var(vname)
		end

		# types
		if name == :tidentifier
			tname = symbol
			return lookup_type(tname)
		end

		# code
		if name == :rocode || name == :rccode
			return node
		end

		# =
		if name == :assign
			lhside = node.args[0]
			if lhside.op.name != :identifier
				puts "lvalue required"
				exit
			end

			vname = lhside.symbol
			val = evaluate(node.args[1])
			set_value(vname, val)
			return val
		end

		# literals
		if node.op.typ == :term
			op = lookup_op(node.op.name)
			return op.evaluate(node, [])
		end

		# everything else is operators or function calls
		if name == :call
			op_args = node.args[1..-1]
			# function
			if node.args[0].op.name == :identifier || node.args[0].op.name == :sidentifier
				op_name = node.args[0].symbol
			# operator
			else
				op_name = node.args[0].op.name
			end

			puts "calling #{op_name}"
			# operator, token generated in standardise_calls
			#else
			#	op_name = node.args[0].name
			#end
			
			if resolve_macros && (template = lookup_macro(op_name))
				puts "found macro #{symbol}:"
				template.dump(0, true)
				puts "----"
				repl_node = apply_macro(node, template)
				return evaluate(repl_node)
			end
			op = lookup_op(op_name)
			op_args.map!{|arg| evaluate(arg)}
			#puts "args: #{op_args}"
			return op.evaluate(node, op_args)
		end

		error(node.op.line, "unknown node #{name}")
	end

end


def binary(op)
	lambda {|node, args| args[0].public_send(op, args[1])}
end


# simplistic syntax for now:
# name :: [args, ...] => [body]
def function(fn_decl)
	arg_decl = fn_decl.args[0]
	if arg_decl.op.name != :rccode
		puts "fn decl requires arg block"
		exit
	end

	args = arg_decl.args
	if args.size == 0
		arg_list = []
	elsif args.size == 1 && args[0].op.name == :identifier
		arg_list = [args[0]]
	elsif args.size == 1 && args[0].op.name == :tuple1
		arg_list = args[0].args
	else
		puts "malformed arg list"
		exit
	end
	
	fn_body = fn_decl.args[1]
	if fn_body.op.name != :rccode
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
	
	int.add_op :$defvar, lambda{|node, args|
		int.define(node, args) }
	int.add_op :defmacro, lambda{|node, args|
		int.define_macro(node, args) }
	
	int.add_op :nop, lambda{|node, args| nil}

	int.add_op :integer, lambda{|node, args| node.op.string.to_i}
	int.add_op :string, lambda{|node, args| node.op.string}

	int.add_op :tuple1, lambda{|node, args| [*args]}
	
	int.add_op :index, lambda{|node, args| args[0][args[1]]}
	
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
