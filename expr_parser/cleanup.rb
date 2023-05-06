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
end


class Symbol
	attr_reader :name, :typ, :definition
	def initialize(name, typ, d)
		@name = name
		@typ = typ
		@definition = d
	end
end


class Scope
	def initilize()
		@symbols = []
	end

	def add_symbol(s)
		@symbols << s
	end
end
