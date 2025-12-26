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
	
	def open?
		@node.node_type == :rocode
	end
end


class IStack
	attr_reader :scopes

	def initialize
		@scopes = [IScope.new(nil)]
	end
	
	def dump
		@scopes.reverse_each do |scope|
			puts scope.node == nil ? "((" : (scope.open? ? "[" : "{")
			puts "VAR"
			puts scope.scopes[VAR]
			puts "OP"
			puts scope.scopes[OP]
			puts "TYPE"
			puts scope.scopes[TYPE]
			puts scope.node == nil ? "))" : (scope.open? ? "]" : "}")
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
			if ! scope.open?
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
		puts "adding macro #{vname}"
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
