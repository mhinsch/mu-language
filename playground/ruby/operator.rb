class Token
	attr_reader :name, :pattern
	
	def initialize(name, pattern)
		@name = name
		@pattern = pattern
		end
	
	def match(string, at)
		string.index(@pattern, at) == at
		end
	end

class Operator < Token
	attr_reader :bindl, :bindr
	def initialize(name, pattern, bindl, bindr)
		super name, pattern
		@precl = bindl
		@precr = bindr
		end
	end
	
class Parser
	attr_reader :ops
	
	def initialize
		@ops = {}
		@order = []
		end
	
	def operator(name, token, bindl, bindr)
		@order << Operator.new(name, token, bindl, bindr)
		@ops[name] = @order.last
		end
	
	
	def scan(string)
		at = 0
		while at < string.length-1
			cur = match(string, at)
			if cur == nil
				puts "error: no match!"
				exit
				end
			
			
		end
	
	def match(string, at)
		@order.each do |p|
			if p.match(string, at)
				return p
				end
			end
		return nil
		end
	end