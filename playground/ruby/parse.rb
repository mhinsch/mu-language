class Lexer
	def initialize
		@tokens = Hash.new
		@order = []
		end
	
	def setString(string)
		@scanner = StringScanner.new(string)
		end

	def lex
		@order.each do |name|
			res = @scanner.match(@tokens[name])
			if res
				yield name, res
				end
			end
		yield nil
		end

	def add(name, pattern)
		@tokens[name] = pattern
		@order << name
		end
	end
		
class Operator
	def attr_reader :token, :prio, :bind, :arity
	def initialize(token, prio, bind, arity = 2)
		@token = token
		@prio = prio
		@bind = bind
		@arity = arity
		end
	end
	
class Parser
	def initialize
		@tokens = Hash.new
		end

	def setLexer(lexer)
		@lexer = lexer
		end

	def parse(string)
		@lexer.setString(string)
		while true do
			res = @lexer.lex
			if !res
				exit
				end
				
			tok, string = res[0], res[1]
			oper = @tokens[tok]
			if @stack.empty?
				if oper.arity > 1 || (oper.arity==1 && oper.bind!=:right)
					puts "expected prefix or symbol"
					exit
					end
				
			
			last_a = @stack.last.arity
			last_p = @stack.last.prio
			
			if oper.prio
			
			case last.arity
				when 0
				when 1
				when 2
				else
					puts "error!"
					exit
				end	
			end
		end

	end
