require 'set'


class Node
	def flatten_naries(naries)
		@args.each do |t|
			if t.class == Node
				t.flatten_naries(naries)
			end
		end

		# sequences of naries go together
		if naries.member?(@op.name)
			puts "flattening #{@op.name}"
			args = []
			@args.each do |a|
				if a.class == Node && a.op.name == @op.name
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

		if @op.name == :rccode || @op.name == :rocode 
			if @args.size != 1
				error(@op.line, "too many args")
			end
			# we don't need to keep top-level tuples in code blocks
			if @args[0].op.name == :tuple0 || @args[0].op.name == :tuple
				@args = @args[0].args
			end
		end

		# after flattening tuples we don't need to keep these around
		if @op.name == :rpar
			if @args.size != 1
				error(@op.line, "too many args")
			end

			@op = @args[0].op
			@args = @args[0].args
		end
	end

	def remove_nops(nop)
		@args.delete_if{|arg| arg.op.name == nop}
		@args.each{|arg| arg.remove_nops(nop)}
	end

	def fun_arg_tuples
		@args.each do |arg|
			if arg.is_a? Token
				next
			end
			arg.fun_arg_tuples
		end

		if @op.name == :juxt || @op.name == :call
			if @args.length != 2
				puts "line #{@op.line}: too many or too few args, I think: #{@args}"
				exit
			end

			if @args[1].op.name == :tuple1
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
		
		if ops.include?(@op.name)
			@args.insert(0, Node.new(@op))
			@op = Token.new("'", :call, :op, nil)
		end

		if @op.name == :juxt
			@op.name = :call
		end
	end
end


