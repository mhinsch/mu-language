
class Token
	attr_reader :string, :name, :typ, :line
	def initialize(s, n, t, l)
		@string = s
		@name = n
		@typ = t
		@line = l
	end

	def dump(l = 0, use_name=true)
		l.times do
			print "  "
		end
		puts (use_name ? @name : @string)
	end
end


class Tokeniser
	def initialize()
		@terms = {}
		@whitespace = []
		@operators = {}

		@str = ""
		@i = 0
		@line = 0

		@m = nil
	end

	def whitespace(ws)
		@whitespace << ws
	end

	def term(pat, typ)
		@terms[pat] = typ
	end

	def op(str, name, eat_ws)
		re = Regexp.new('\G' + Regexp.escape(str))
		@operators[re] = [name, eat_ws]
	end

	def match_idx(expr)
		@m = @str.match(expr, @i)
	end

	def advance
		@i = @m.end(0)
	end

	def with_match(rex)
		if match_idx(rex)
			advance()
			if block_given?
				yield @m[0]
			end
			#puts "matched #{rex}"
			return true
		end

		false
	end

	def eat_ws_nl_c
		while match_idx(/(\G\s+)|(\G;;[^\n]*)/)
			advance()
		end
	end

	def count_lines(str, from)
		for i in from..@i
			if str[i] == "\n"
				@line += 1
			end
		end
	end

	def tokenise(str)
		@str = str
		@i = 0
		@line = 0
		i_last = 0
		tokens = []
		
		eat_ws_nl_c()

		while @i < @str.length
			count_lines(str, i_last)
			i_last = @i


			matched = false
			@whitespace.each do |ws|
				if with_match(ws)
					matched = true
					break 
				end
			end
			
			if matched
				next
			end

			@terms.each do |pat, name|
				if with_match(pat) { |m|
						tokens << Token.new(m, name, :term, @line)
						#puts tokens.last.name
					}
					matched = true
					break
				end
			end

			if matched
				next
			end

			@operators.each do |pat, props|
				name = props[0]
				eat_ws = props[1]
				if with_match(pat) { |m|
						tokens << Token.new(m, name, :op, @line)
						#puts tokens.last.name
						if eat_ws
							eat_ws_nl_c()
						end
					}
					matched = true
					break
				end
			end

			if matched
				next
			end

			$stderr.puts("unknown syntax at line #{@line}: ", @str[i..-1])
			exit
		end

		tokens
	end
end
