require './tokeniser.rb'

class Syntax
	attr_reader :bind_l, :bind_r, :is_paren, :is_sep
	def initialize(bl, br, isp=false, is=false)
		@bind_l = bl
		@bind_r = br
		@is_paren = isp
		@is_sep = is
	end

	def arity
		(@bind_l >= 0 ? 1 : 0) +
		(@bind_r >= 0 ? 1 : 0)
	end
end


class Node
	attr_reader :op, :args

	def initialize(o)
		@op = o
		@args = []
	end

	def add(t1, *t)
		@args.push(t1, *t)
	end

	def string
		@op.string + "(" + @args.size.to_s + ")"
	end

	def dump(l=0, use_name=true)
		l.times do
			print "  "
		end
		puts (use_name ? @op.name : @op.string)

		@args.reverse_each do |t|
			t.dump(l+1, use_name)
		end
	end
end

# TODO nary operators (?)

def error(txt)
	$stderr.puts txt
	exit
end

class Parser
	def initialize()
		@typeof = {}
		@closes = {}
	end

	# TODO expose associativity
	def infix(name, bind, is_sep=false)
		@typeof[name] = Syntax.new(bind-1, bind, false, is_sep)
	end

	def postfix(name, bind)
		@typeof[name] = Syntax.new(bind, -1, false, false)
	end

	def prefix(name, bind)
		@typeof[name] = Syntax.new(-1, bind, false, false)
	end

	def parens(left, right)
		@closes[left] = right
		@typeof[left] = Syntax.new(-1, 0, true)
		@typeof[right] = Syntax.new(1, -1, true)
	end

	def term(name)
		@typeof[name] = Syntax.new(-1, -1)
	end

	def syntax(token)
		s = @typeof[token.name]
		if s == nil
			error("#{token.name} has no defined syntax")
		end
		s
	end

	def reduce_postfix(ops, terms, t)
		if syntax(t).is_paren
			if ops.empty?
				error("missing opening parenthesis for #{t.string}")
			end
			if !closed_by?(ops.last, t)
				error("#{t.string} does not close #{ops.last.string}")
			end
			ops.pop
		end
		nterm = Node.new(t)
		nterm.add(terms.last)
		terms.pop
		terms << nterm
	end

	def reduce(ops, terms, b)
		while !ops.empty? && b <= syntax(ops.last).bind_r
			sl = syntax(ops.last)

			if terms.size < sl.arity
				error("reduce: op #{ops.last.string}: only #{terms.size} arguments found")
			end

			print ">> o #{ops.last.string}"
			nterm = Node.new(ops.last)
			(1..sl.arity).each do
				a = terms.last
				print ", #{a.string}"
				nterm.add(a)
				terms.pop
			end
			puts
			ops.pop
			terms << nterm
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
		t = nil
		need_arg = true
		open_op = nil

		while i < tokens.length do
			t_p = t
			s_p = t_p ? syntax(t_p) : nil
			t = tokens[i]
			s = syntax(t)

			# only terms or open parentheses allowed at beginning of input
			if t_p == nil
				if s.bind_l < 0
					if s.is_paren
						puts "<< o #{t.string}"
						ops << t
					else
						puts "<< t #{t.string}"
						terms << t
					end
					i += 1
					next
				else
					error "operator at start of input"
				end
			end

			# op op 
			if s.bind_l >= 0 && s_p.bind_r >= 0
				# separators and parentheses are allowed to have no operand
				# insert nops to make parsing simpler
				if ((s_p.is_sep || s_p.is_paren) && (s.is_sep || s.is_paren)) # sep sep
					t = Token.new("()", :nop, :term)
					s = syntax(t)
					i -= 1
				else
					error("expecting new term after #{tokens[i-1].string}, got #{t.string}")
				end
			end

			# term term is its own operator
			if s.bind_l < 0 && s_p.bind_r < 0
				t = Token.new("'", :juxt, :op)
				s = syntax(t)
				i -= 1
			end

			# term op
			if s.bind_l >= 0
				if !ops.empty? && s.bind_l < syntax(ops.last).bind_r
					reduce(ops, terms, s.bind_l)
				end

				# at this point everything binding stronger than s has been reduced
				# to a single term
				
				# postfix operator or closing parentheses
				if s.bind_r < 0
					reduce_postfix(ops, terms, t)
					i += 1
					next
				end
			end

			# par or prefix
			if s.bind_r >= 0
				puts "<< o #{t.string}"
				ops << t
			else
				puts "<< t #{t.string}"
				terms << t
			end
			i += 1
		end

		[terms, ops]
	end # parse
		
end # Parser




