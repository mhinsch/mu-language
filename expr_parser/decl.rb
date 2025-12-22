

class Scope
	attr_reader :defs, :parent
	def initialize(p = nil)
		@defs = Hash.new
		@parent = p
	end

	def add_def(str, defn)
		@defs[str] = defn
	end


end


class NType
	attr_reader :name, :def
end


class Node
	attr_reader :scope,	# scope object containing visible names 

	def check_scope(parent)
		#puts "scope: " + @op.name.to_s + " " + parent.class.name
		# scope of [ is linked to parent
		if @token.name == :rocode
			@scope = Scope.new(parent)
		# scope of { has no parent
		elsif @token.name == :rccode
			@scope = Scope.new(nil)
		# regular tuples create their own open scope
		elsif @token.name == :tuple1
			@scope = Scope.new(parent)
		else
			@scope = parent
		end

		@args.each do |arg|
			arg.check_scope(@scope)
		end
	end

	# TODO this should be moved into explicit
	# compile time operator
	def register_defs()
		visit(:def) do |node|
			id = node.args[0]
			if id.op.name != :identifier
				$stderr.puts "error in line #{id.op.line}: definition requires identifier"
				exit
			end
			node.scope.add_def(id.op.name, node)
		end
	end

	def check_types()

	end
end

