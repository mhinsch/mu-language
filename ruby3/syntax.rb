require 'parsetree'

class Scope < Oper
	def initialize(op, elems, s)
		super(op, elems)
		@sc = s
	end
end

class Node
	def scope(s)
		@sc = s
		self
	end
end

# each tree run is a type annotation process (that mutates the tree)
#
# 1. scopes
# 2. declarations
# 3. 


class Oper
	
	# check arity of operators, where necessary
	# adjust according to binding direction
	def normalize
	end

	def scope(s)

		if @op != ';'
			this = self
			@sc = s
		else
			s = Scope.new(@op, @elems, s)
			this = s
		end
		
		if @op
			@elems.each { |e| e = e.scope(s) }
		end

		this
	end

	# type checks tree in decl phase
	#
	# available types:
	# new_name, type_spec, value, name, type
	#
	# defined operators (for now):
	# : 	(new_name, type_spec -> ??)
	# <fn> 	(type_spec, value -> type_spec)
	#
	# for <fn> to work this way ':' has to rewrite its subtree, type_spec
	# is not distinguishable on its own
	#
	def declare_type
	end

	def declare!
		# declaration
		if @op == ':'
			if @elems.size != 2
				puts "Error: operator : has arity 2"
				exit
			end
				

			@sc.addDecl(self)
			return nil
		end

		# exe tuple
		if @op == ';'
			@elems.select { |e| e.declare! }
			return self
		end

		if @op == nil
			return self
		end

		@elems.each {|e| e.declare!}
		self

		# what about decls inside e.g. +???
	end

end

