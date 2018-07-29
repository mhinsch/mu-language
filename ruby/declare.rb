require 'compile'
require 'oper'

module D_T_Nop
	def evaluate(block, node)
		D_E_Nop.new(node)
		end
	end
	
class D_E_Nop
	def apply(block)
		end
	end

class D_T_Simple
	include D_T_Nop
	
	attr_reader :name, :typeName
	
	def initialize(name, typeName)
		@name = name
		@typeName = typeName
		end
	
	def matches?(node)
		true
		end
	end
	
# very simple
# type in :compile will be more complicated
class D_T_Type < D_T_Simple	
	def initialize(name)
		super(name, "type")
		end	
	end
	
class D_Oper < Oper
	def initialize(name, arg_types, ret_type)
		super
		end
	
	def matches?(node)
		super("declare", node)
		end
	end
	
class D_T_Expression < D_T_Simple
	def initialize(name)
		super(name, "expression")
		end	
	end
	
	
class D_T_Symbol < D_T_Simple
	def initialize(name)
		super(name, "symbol")
		end	
	end

class D_T_Block < D_T_Simple
	def initialize(name)
		super(name, 'block')
		end
	
	def matches?(node)
		true
		end
	
	def evaluate(block, node)
		node.elems.each do |e|
			op = block.evaluateElem("declare", e)
			op && op.apply(node)
			end
		end
	end
	
class D_T_Tuple < D_Oper
	
	def initialize(name)
		super(name, ['*', -1], '*')
		end
	
	def matches?(node)
		
		true
		end
		
	def evaluate(block, node)
		
		end
	
	def typeName
		end
	end

class D_E_AddEntity
	attr_reader :declare, :compile
	
	def initialize(decl, comp)
		@declare = decl
		@compile = comp
		end
	
	def apply(block)
		@declare.apply(block)
		@compile.apply(block)
		end
	end

class D_T_NewSymbol < D_Oper
	def initialize(name)
		super(name, ['symbol', 'type'], 'new_symbol')
		end
		
	def evaluate(block, node)
		D_E_AddEntity.new(
			AddEntity.new('declare', D_T_Expression.new(node.elems[0].elems[0])),
			AddEntity.new('compile', 
				C_Identifier.new(
					node.elems[0].elems[0], node.elems[1].elems[0], 
		                     node.interval, nil)))
		end
	end

# could actually go into :compile
# type inference will probably require it to stay here, though
class D_T_NewSymbolIni < D_Oper
	def initialize(name)
		super(name, ['new_symbol', 'expression'], 'new_symbol_ini')
		end
	
	def evaluate(block, node)
		ops = block.evaluateElem('declare', node.elems[0])
		ops.compile.entity.setIni(node.elems[1])
		
		ops
		end
	end

class D_T_NewFunSymbol < D_Oper
	def initialize(name)
		super(name, ['symbol', 'new_symbol'], 'new_fun_symbol')
		end
	
	def evaluate(block, node)
		# TODO
		end
	end

class D_T_NewFunRet < D_Oper
	def initialize(name)
		super(name, ['new_fun_symbol', 'type'], 'new_fn_ret')
		end
	
	def evaluate(block, node)
		# TODO
		end
	
	end

class D_T_NewFunIni < D_Oper
	def initialize(name)
		super(name, ['new_fun_ret', 'expression'], 'new_fn_ini')
		end
	
	def evaluate(block, node)
		# TODO
		end
	
	end