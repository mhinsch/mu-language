require './tokeniser.rb'

class Syntax
	attr_reader :bind_l, :bind_r, :is_paren, :is_sep, :is_term
	def initialize(bl, br, is_paren: false, is_sep: false, is_term: false)
		@bind_l = bl
		@bind_r = br
		@is_paren = is_paren
		@is_sep = is_sep
		@is_term = is_term
	end

	def arity
		(@bind_l >= 0 ? 1 : 0) +
		(@bind_r >= 0 ? 1 : 0)
	end
end


class Node
	attr_reader :op,	# parser Token
		:args			# child Node objects

	def initialize(o)
		@op = o
		@args = []
	end

	def copy
		nnode = Node.new(@op)
		@args.each do |arg|
			nnode.add(arg.copy)
		end
		nnode
	end

	def add(t1, *t)
		@args.push(t1, *t)
	end

	def string
		@op.string + "(" + @args.size.to_s + ")"
	end

	def symbol
		@op.string.to_sym
	end

	def visit(oper, &transform)
		if @op.name == oper
			transform.call(self)
		end

		@args.each do |arg|
			arg.visit(oper, &transform)
		end
	end


	def dump(l=0, use_name=true)
		l.times do
			print "  "
		end
		#puts (use_name ? @op.name : @op.string)
		puts "#{self.class.name} #{@op.name}, #{@op.typ} (\"#{@op.string}\"): #{@args.size}"

		@args.each do |t|
			t.dump(l+1, use_name)
		end
	end
end

# TODO nary operators (?)

def error(line, txt)
	$stderr.puts "line #{line}: #{txt}"
	exit
end

class Parser
	def initialize()
		@typeof = {}
		@closes = {}
	end

	# TODO expose associativity
	def infix(name, bind, is_sep=false)
		@typeof[name] = Syntax.new(bind-1, bind, is_sep: is_sep)
	end

	def postfix(name, bind)
		@typeof[name] = Syntax.new(bind, -1)
	end

	def prefix(name, bind)
		@typeof[name] = Syntax.new(-1, bind)
	end

	def parens(left, right)
		@closes[left] = right
		@typeof[left] = Syntax.new(-1, 0, is_paren: true)
		@typeof[right] = Syntax.new(1, -1, is_paren: true)
	end

	def term(name)
		@typeof[name] = Syntax.new(-1, -1, is_term: true)
	end

	def get_syntax(token)
		s = @typeof[token.name]
		if s == nil
			error(token.line, "#{token.name} has no defined get_syntax")
		end
		s
	end

	def reduce_postfix(ops, terms, t)
		if get_syntax(t).is_paren
			if ops.empty?
				error(t.line, "missing opening parenthesis for #{t.string}")
			end
			if !closed_by?(ops.last, t)
				error(t.line, "#{t.string} does not close #{ops.last.string}")
			end
			ops.pop
		end
		new_term = Node.new(t)
		new_term.add(terms.last)
		terms.pop
		terms << new_term
	end

	def reduce(ops, terms, b)
		while !ops.empty? && b <= get_syntax(ops.last).bind_r
			sl = get_syntax(ops.last)

			if terms.size < sl.arity
				error(ops.last.line, "reduce: op #{ops.last.string}: only #{terms.size} arguments found")
			end

			print "#{ops.last.line} >> o #{ops.last.string}"
			new_term = Node.new(ops.last)
			(1..sl.arity).reverse_each do |i|
				a = terms[-i]
				print ", #{a.string}"
				new_term.add(a)
			end
			terms.pop(sl.arity)
			puts
			ops.pop
			terms << new_term
		end
	end

	def closed_by?(left, right)
		@closes[left.name] == right.name
	end

	def parse(tokens)
		terms = []
		ops = []

		i = 0

		p = -1
		token = nil
		need_arg = true
		open_op = nil

		while i < tokens.length do
			token_prev = token
			syntax_prev = token_prev ? get_syntax(token_prev) : nil
			token = tokens[i]
			syntax = get_syntax(token)

			# only terms or open parentheses allowed at beginning of input
			if token_prev == nil
				if syntax.bind_l < 0
					if syntax.is_paren
						puts "<< o #{token.string}"
						ops << token
					else
						puts "<< token #{token.string}"
						terms << token
					end
					i += 1
					next
				else
					error(token.line, "operator at start of input")
				end
			end

			# op op 
			if syntax.bind_l >= 0 && syntax_prev.bind_r >= 0
				# separators and parentheses are allowed to have no operand
				# insert nops to make parsing simpler
				if ((syntax_prev.is_sep || syntax_prev.is_paren) &&
						(syntax.is_sep || syntax.is_paren)) # sep sep
					token = Token.new("()", :nop, :term, token.line)
					syntax = get_syntax(token)
					i -= 1
				else
					error(token.line,
						"expecting new term after #{tokens[i-1].string}, got #{token.string}")
				end
			end

			# term term is its own operator
			if syntax.bind_l < 0 && syntax_prev.bind_r < 0
				token = Token.new("'", :juxt, :op, token.line)
				syntax = get_syntax(token)
				i -= 1
			end

			# term op
			if syntax.bind_l >= 0
				if !ops.empty? && syntax.bind_l < get_syntax(ops.last).bind_r
					reduce(ops, terms, syntax.bind_l)
				end

				# at this point everything binding stronger than syntax has been reduced
				# to a single term
				
				# postfix operator or closing parentheses
				if syntax.bind_r < 0
					reduce_postfix(ops, terms, token)
					i += 1
					next
				end
			end

			# par or prefix
			if syntax.bind_r >= 0
				puts "#{token.line} << o #{token.string}"
				ops << token
			else
				puts "#{token.line} << token #{token.string}"
				terms << (syntax.is_term ? Node.new(token) : token)
			end
			i += 1
		end

		[terms, ops]
	end # parse
		
end # Parser




