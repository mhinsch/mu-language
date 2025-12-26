
class Node

	def fncall?
		node_type == :call
	end

	def code?
		node_type == :rccode || node_type == :rocode
	end

	def identifier?
		node_type == :identifier || node_type == :tidentifier
	end
	
	def call_oper
		if !fncall?
			nil
		else
			@args[0]
		end
	end
	
	def call_args
		if !fncall?
			nil
		else
			@args[1..-1]
		end
	end

	def unquote
		if ! code?
			error("can't unquote non-quote")
		end

		@args[0]
	end

	def self.create_call(str, typ, kind=:op, args=[])
		cal = Node.new(Token.new("'", :call, :op, nil))
		cal.args << Node.new(Token.new(str, typ, kind, nil))
		cal.args[0].args.concat(args)
		cal
	end
end
