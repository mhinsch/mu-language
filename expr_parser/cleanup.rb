require 'set'


class Node
	def node_type
		@token.name
	end

	def set_node_type(typ)
		@token.name = typ
	end
	
	def flatten_naries(naries)
		@args.each do |t|
			if t.class == Node
				t.flatten_naries(naries)
			end
		end

		# sequences of naries go together
		if naries.member?(node_type)
			puts "flattening #{node_type}"
			args = []
			@args.each do |a|
				if a.class == Node && a.node_type == node_type
					args.concat(a.args)
				else
					args << a
				end
			end
			@args = args
		end
	end

	def remove_pars
		@args.each do |t|
			if t.class == Node
				t.remove_pars
			end
		end

		if node_type == :rccode || node_type == :rocode 
			if @args.size != 1
				error(@token.line, "too many args")
			end
			# we don't need to keep top-level tuples in code blocks
			if @args[0].token.name == :tuple0 || @args[0].token.name == :tuple
				@args = @args[0].args
			end
		end

		# after flattening tuples we don't need to keep these around
		if node_type == :rpar
			if @args.size != 1
				error(@token.line, "too many args")
			end

			@token = @args[0].token
			@args = @args[0].args
		end
	end

	def remove_nops(nop)
		@args.delete_if{|arg| arg.token.name == nop}
		@args.each{|arg| arg.remove_nops(nop)}
	end

	def fun_arg_tuples
		@args.each do |arg|
			if arg.is_a? Token
				next
			end
			arg.fun_arg_tuples
		end

		if node_type == :juxt || node_type == :call
			if @args.length != 2
				puts "line #{@token.line}: too many or too few args, I think: #{@args}"
				exit
			end

			if @args[1].token.name == :tuple1
				@args = [ @args[0], *@args[1].args]
			end
		end
	end

	def standardise_op_calls(ops)
		@args.each do |arg|
			if arg.is_a? Token
				next
			end
			arg.standardise_op_calls(ops)
		end
		
		if ops.include?(node_type)
			@args.insert(0, Node.new(@token))
			@token = Token.new("'", :call, :op, nil)
		end

		if node_type == :juxt
			set_node_type(:call)
		end
	end
end


