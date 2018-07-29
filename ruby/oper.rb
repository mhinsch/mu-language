
class Oper
	attr_reader :name, :arg_types, :ret_type, :op, :arity

	def initialize(name, arg_types, ret_type)
		@name = name
		@arg_types = arg_types
		@ret_type = ret_type
		
		if @arg_types.length > 1 && @arg_types[-1] == -1
			@arg_types.pop
			@arity = -1
		else
			@arity = @arg_types.length
			end
		end
	
	def match?(t1, t2)
		t1 == t2 || t1 == '*' || t2 == '*'
		end
		
	def matches?(mode, node)
		puts "Oper::matches?: " + mode.to_s + " " + self.class.to_s + " " + 
			node.elems.collect{|a| a.typeName(mode)}.join(",")

		if @arity == -1
			node.elems.each do |a|
				if ! match?(a.typeName(mode), @arg_types[0])
					return false
					end
				end
		elsif node.elems.length != @arity
			return false
		else
			@arg_types.each_index do |i|
				if ! match?(node.elems[i].typeName(mode), @arg_types[i])
					return false
					end
				end
			end
			
		true
		end
	
	def typeName
		@ret_type
		end
	end
