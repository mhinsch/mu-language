
class C_Identifier
	attr_reader :name, :myType, :interval, :ini

	def initialize(name, type, interval, ini)
		@name = name
		@myType = type
		@interval = interval
		@ini = ini
		
		puts "CI: " + name.to_s + " " + type.to_s
		end
	
	def matches?(mode, node)
		true
		end
	
	def setIni(ini)
		@ini = ini
		end
	end
	