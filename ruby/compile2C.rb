
class C2C_Base
	attr_reader :name
	
	def initialize(name)
		@name = name
		end
	
	def matches?(node)
		true
		end

	def evaluate(block, node)
		""
		end
	
	def typeName
		@name
		end
	end

class C2C_Oper < C2C_Base
	attr_reader :prec, :op
	
	def initialize(name, prec, op)
		super name
		@prec = prec
		@op = op
		end
		
	def evaluate(block, node)
		res = []
		node.elems.collect do |e|
			pre = ""
			post = ""
			t = e.typeObject('c2c')
			if t.class == C2C_Oper && t.prec <= @prec
				pre = "("
				post = ")"
				end
			pre + e.evaluate('c2c') + post
			end.join(@op)
		end
	end

class C2C_Block < C2C_Base
	def initialize(name)
		super
		end
	
	def evaluate(block, node)
		"{\n" + 
		node.elems.collect do |e|
			e.evaluate('c2c') + ";"
			end.join("\n") + "\n}\n"
		end
	end

class C2C_Terminal < C2C_Base
	def initialize(name)
		super
		end
	
	def evaluate(block, node)
		node.elems[0]
		end
	end
	
class C2C_FCall < C2C_Base
	def initialize(name)
		super
		end
		
	def evaluate(block, node)
		# assume only symbols
		node.elems[0].evaluate('c2c') + "(" + node.elems[1].evaluate('c2c') + ")"
		end
	end

class C2C_Decl < C2C_Base
	def initialize(name)
		super
		end
	
	def evaluate(block, node)
		node.elems[1].evaluate('c2c') + " " + node.elems[0].evaluate('c2c')
		end
	end

class C2C_DeclIni < C2C_Base
	def initialize(name)
		super
		end
		
	# works only for regular variables (no functions)
	def evaluate(block, node)
		node.elems[0].evaluate('c2c') + 
			(node.elems[0].elems[0].typeObject('c2c').class == C2C_FCall ? "" : " = ") +
			node.elems[1].evaluate('c2c')
		end
	end