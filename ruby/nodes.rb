require 'set'

class Treetop::Runtime::SyntaxNode
	def tree
		N_Nop.new
		end
	end
	

class EtaNode
	attr_reader :elems, :interval, :name
	
	def initialize(int, name = "")
		@name = name
		@interval = int
		@elems = []
		end
	
	def print(ind)
		puts ind + self.class.to_s + " " + name + " " + @elems.length.to_s
		@elems.each {|e| e.print(ind+"  ")}
		nil
		end
	
	def liftElems
		@elems.collect! {|e| e.lift }
		self
		end
	
	def dropNop
		@elems.reject! {|e| e.class == N_Nop}
		self
		end
	
	def dropSelf
		if @elems.length == 1
			@elems[0]
		else
			self
			end
		end
		
	
	def lift
		liftElems
		dropNop
		dropSelf
		end
	end

class N_Nop < EtaNode
	def initialize
		@elems = []
		end
	
	def print(ind)
		puts ind + self.class.to_s
		end
	end
	
class NAry < EtaNode	
	def initialize(el, int, name)
		super int, name
		@elems = [el]
		end
	
	def add(el)
		@elems << el
		self
		end	
	end

class N_Block < NAry
	def initialize(el, int, name)
		super
		end

	# blocks have to be kept
	def lift
		liftElems
		dropNop
		self
		end
	end
	
class N_Oper < NAry	
	def initialize(el, int, name, assoc = :none)
		super(el, int, name)
		@name = name
		@assoc = assoc
		@ops = []
		end
	
	def add(el, op = nil)
		super el
		op ||= @name
		@ops << op
		self
		end
		
	def print(ind)
		puts ind + self.class.to_s + " " + name + " " + @elems.length.to_s
		@elems.each {|e| e.print(ind+"  ")}
		nil
		end
	
	def makeBinary
		if @assoc == :none || @elems.length < 3
			return self
			end
		
		if @assoc == :left
			cur = @elems[0]
			c = 1
			while c < @elems.length do
				cur = self.class.new(cur, @interval, @name)
				cur.add(@elems[c], @ops[c-1])
				c += 1
				end
		else		
			cur = @elems[-1]
			@elems.pop
			while @elems.length > 0 do
				ncur = self.class.new(@elems[-1], @interval, @name)
				ncur.add(cur, @ops[-1])
				cur = ncur
				@elems.pop
				@ops.pop
				end
			end

		cur		
		end
	
	def lift
		liftElems
		dropNop
		makeBinary.dropSelf
		end
	end

class N_Tuple < NAry
	def initialize(el, int, name)
		super(el, int, name)
		end
	
	def lift
		liftElems
		dropNop
		dropSelf
		end	
	end
	
class N_Terminal < N_Oper
	def initialize(el, int, name)
		@elems = [el]
		@interval = int
		@name = name
		end
	
	def print(ind)
		puts ind + self.class.to_s + " " + @elems[0].to_s
		end
		
	def lift
		self
		end
	end

class String
	def name
		self
		end
	end

class N_Number < N_Terminal
	def initialize(el, int, name="__NUM__")
		super
		end
	end

class N_Symbol < N_Terminal
	def initialize(el, int, name="__SYM__")
		super
		end
	end

class N_String < N_Terminal
	def initialize(el, int, name="__STR__")
		super
		end
	end

