require 'nodes'


class EtaNode
	attr_reader :block, :myType
	
	def setBlock(block)
		puts self.class.to_s + " setBlock"
		@block = block
		@elems.each {|e| e.setBlock(block)}
		end	

	def typeName(mode)
		@myType ||= Hash.new
		
		# cache the type
		@myType[mode] ||= 
				@block.typeElem(mode, self)
		end
	
	def typeObject(mode)
		@block.typeObjectElem(mode, self)
		end
	
	def evaluate(mode)
		typeObject(mode).evaluate(@block, self)
		end
	end

class N_Oper	
	def setBlock(block)
		puts self.class.to_s + ": " + self.name + " setBlock"
		@block = block
		@elems.each {|e| e.setBlock(block)}
		end	
	end

class N_Terminal
	def setBlock(block)
		@block = block
		end
	end

class N_Symbol
	def typeName(mode)
		@block.typeElem(mode, elems[0]) || @block.typeElem(mode, self)
		end
	end

class N_Number
	def typeName(mode)
		@block.typeElem(mode, self)
		end
	end
	
class N_Block
	attr_reader :dicts
		
	def setNamespace(mode, ns)
		@dicts ||= {"declare" => Namespace.new, "compile" => Namespace.new}
		@dicts[mode] = ns
		end

	def typeElem(mode, node)
		@dicts ||= {"declare" => Namespace.new, "compile" => Namespace.new}
		(@dicts[mode] && @dicts[mode].typeName(node)) || 
				(@block && @block.typeElem(mode, node))
		end
	
	def typeObjectElem(mode, node)
		@dicts ||= {"declare" => Namespace.new, "compile" => Namespace.new}
		(@dicts[mode] && @dicts[mode].get(node)) || 
				(@block && @block.typeObjectElem(mode, node))
		end
	
	def evaluateElem(mode, node)
		puts "Block::evaluate: " + node.name
		
		# retrieve the type object from the dictionary
		t = typeObjectElem(mode, node)

		puts "\t" + (t ? t.typeName.to_s : "nil")
		# if we found it, evaluate it
		t && t.evaluate(self, node)
		end
		
	def addEntity(mode, entity)
		@dicts[mode].add(entity)
		end	

	def setBlock(block)
		@block = block
		@elems.each {|e| e.setBlock(self)}
		end
		
	def evaluate(mode)
		evaluateElem(mode, self)
		end
	end

class Namespace
	attr_reader :entities

	def add(entity)
		@entities ||= Hash.new
		@entities[entity.name] ||= []
		@entities[entity.name] << entity
		end
	
	def get(node)
		@entities ||= Hash.new
		
		e_name = @entities[node.name]
		
		e_name && e_name.find{|e| e.matches?(node)}
		end
		
	def typeName(node)
		e = get(node)
		e && e.typeName
		end
	end

class AddEntity
	attr_reader :name, :mode, :entity
	
	def initialize(mode, entity)
		@mode, @entity = mode, entity
		@name = entity.name
		end
	
	def apply(block)
		block.addEntity(@mode, @entity)
		end
	
	end
	
