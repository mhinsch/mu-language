require 'parsetree'

class ESymbol
	attr_reader :name, :typ, :code
end

class Scope 
	# keep global around to hand it to '{}' blocks
	attr_reader :surround, :global, :code, :decls

	def initialize(s, g, c)
		@surround = s 
		@global = g
		@code = c
		@decls = Hash.new
	end

	def symbol(s)
		@decls[s]
	end

	def lookup(name)
		# if we have surround, let it do the work
		# only ask global directly if we have no surround
		symbol(name) || 
			(@surround ? @surround.lookup(name) : @global && @global.lookup(name))
	end

	def add_decl(node)
		if node.elems[0].op != :var && node.elems[0].op != :typ
			puts "Error: __:__ requires a name on the left hand side!"
		end
		name = node.elems[0].to_s

		puts "adding decl #{name}"

		if @decls[name]
			puts "Error: double definition of #{name}!"
		elsif lookup(name)
			puts "Warning: #{name} shadows previous definition!"
		end

		@decls[name] = node
	end
end

# pre-compile steps
# 
# 1. assign scopes
# 	simple recursive walk
# 2. bind symbols to scopes
# 	let decl operatpors push symbols
# 	will catch double decls/shadowing
# 3. type declarations/inference ???
# 	* simple decls 'a : Int' - easy
# 	* complex decls 'a : (Int, Array Float) - later but doable
# 	* function decls - later, syntax?
# 	* implicit decls / inference 'a : 1', 'b : a * 3' - ???? 
# 		requires type info for literals, declared vars and operators/functions
#
# operations
# - scope
# - decl.: (:, var, type), (:, var, expr)


class Exp
	def assign_scope(sup)
		if (@op.name == :b_exp)
			@sc = Scope.new(nil,sup.global, self)
			@elems.each { |e| e.assign_scope(@sc) }
		else
			super
		end
	end
end

class Lit
	def assign_scope(s)
		@sc = s
	end

	def declare!
	end

	def check_declared
		if @op == :num
			return
		end
		if ! @sc.lookup(self.to_s)
			puts "Error: undeclared identifier #{self.to_s}!"
		end
	end
end

class Oper
	def assign_scope(sup)
		# every node gets its own scope; wasteful but easier
		@sc = Scope.new(sup, sup.global, self)
		@elems.each { |e| e.assign_scope(@sc) }
	end

	def check_declared
		@elems.each {|e| e.check_declared}
	end

	def scope
		@sc
	end

	def lookup(name)
		@sc.lookup(name)
	end

	def declare!
		# declaration
		if @op.name == :decl
			if @elems.size != 2
				puts "Error: operator : has arity 2"
				exit
			end

			@sc.surround.add_decl(self)
		end

		@elems.each {|e| e.declare!}
		self

	end

end

