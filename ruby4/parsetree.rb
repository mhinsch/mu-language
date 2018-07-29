$operators = Hash.new

class Operator
	attr_reader :name, :letter, :lvl	
	
	def initialize(name, letter, lvl)
		@name = name
		@letter = letter
		@lvl = lvl
		$operators[@letter] = self
		@lvl.add_oper(self)
	end

	def assoc
		@lvl.assoc
	end

	def to_s
		@name
	end
end

class Level
	attr_reader :name, :assoc, :opers

	def initialize(name, assoc)
		@assoc = assoc
		@name = name
		@opers = Hash.new
	end

	def add_oper(oper)
		@opers[oper.name] = oper
	end
end

class Grammar

	attr_reader :levels

	def initialize
		@llit = Level.new(:lit, :none)
		@lfun = Level.new(:fun, :right)
		@lprod = Level.new(:prod, :left)
		@lsum = Level.new(:sum, :left)
		@lini = Level.new(:ini, :left)
		@ltuple = Level.new(:tuple, :none) 
		@lassign = Level.new(:assign, :right)
		@lexpr = Level.new(:expr, :none)

		@levels = [@llit, @lfun, @lprod, @lsum, @lini, @ltuple, @lassign, @lexpr]

		Operator.new(:lit, 'a', @llit)
		Operator.new(:call, '`', @lfun)
		Operator.new(:mult, '*', @lprod)
		Operator.new(:div, '/', @lprod)
		Operator.new(:mod, '%', @lprod)
		Operator.new(:plus, '+', @lsum)
		Operator.new(:minus, '-', @lsum)
		Operator.new(:decl, ':', @lini)
		Operator.new(:tuple, ',', @ltuple)
		Operator.new(:eq, '=', @lassign)
		Operator.new(:exp, '(', @lexpr)
		Operator.new(:b_exp, '{', @lexpr)
		Operator.new(:s_exp, '[', @lexpr)
	end

	def oper(o_name)
		@levels.each do |l|
			o = l.opers[o_name]
			if o 
				return o
			end
		end
		nil
	end

	def level(name)
		#print "is_level "
		#p name
		@levels.each do |l|
			if l.name == name
				return l
			end
		end

		puts "level of '#{name}' not found!"
		puts name.class
		nil
	end
end

$grammar = Grammar.new


class Node
	def indent(out, lvl)
		lvl.times {print("\t")}
	end

	def pprint(out, lvl)
		indent(out, lvl)
	end
end

class Oper < Node
	attr_reader :elems, :op

	def initialize(op, elems)
		# first pass, raw parser stuff
		if (op.is_a?(Symbol) && elems.is_a?(Array))
			@op = op
			#puts "op: #{op}, type #{op.class}"
			@elems = elems
		# expects "+", <xyz>
		else
			# keep the source pointer around 
			@source = op
			# actual operator object
			#puts "source: #{op}"
			@op = $operators[@source.to_s]
			@elems = [elems]
		end
	end

	def to_tree
		# at this point @op is the operator letter
		# level is needed for associativity
		l = $grammar.level(@op)

		if ! l
			puts "no level for #{@op}!"
		end
		
		for el in @elems
			el[1] = el[1].to_tree
		end

		if l.assoc == :right
			puts "RIGHT"
			
			el = @elems[-1][1]

			(@elems.size-2).downto(0) do |i|
				#                          op, elems
				eln = Oper.new(@elems[i+1][0], @elems[i][1])
				eln.add_right(el)
				el = eln
			end

			return el
		end

		if l.assoc == :left
			puts "LEFT"

			el = @elems[0][1]

			for i in 1...@elems.size do
				eln = Oper.new(*@elems[i])
				eln.add_left(el)
				el = eln
			end

			return el
		end

		if l.assoc == :none
			@elems.collect! {|el| el[1] }
			@source = @op
			@op = $grammar.oper(@op)
			return self
		end

		puts "unknown associativity!"
	end

	def add_left(el)
		if @elems.length != 1
			puts "add_left, @elems has #{@elems.length} elements!"
		end
		@elems.insert(0, el)
	end

	def add_right(el)
		if @elems.length != 1
			puts "add_right, @elems has #{@elems.length} elements!"
		end
		@elems.insert(-1, el)
	end

	def pprint(out, lvl)
		indent(out, lvl)
		out.puts("op: #{@op.to_s}")

		indent(out, lvl)
		out.print(" elems ")

		if @elems==nil then
			print("(0): ")
			puts("nil")
		elsif defined? @elems.each then
			puts("[#{@elems.size}]:")
			@elems.each {|e| e.pprint(out, lvl+1)}
		else
			puts("(1): ")
			@elems.pprint(out, lvl+1)
		end
	end
	
	def sprint(out)
		out.print("#{@op.to_s}(")
		@elems.each {|e| e.sprint(out); out.print(",")}
		out.print(")")
	end
end

class Parslet::Slice
	def pprint(out, lvl)
		lvl.times {print("\t")}
		puts self
	end

	def reshuffle
		return self
	end
end

class Lit < Oper
	def initialize(type, val)
		super(type, [val])
	end

	def to_tree
		@source = @op
		self
	end

	def pprint(out, lvl)
		indent(out, lvl)
		out.puts("Lit #{@op.to_s}: #{@elems[0].to_s}")
	end

	def sprint(out)
		out.print(@elems[0])
	end

	def to_s
		@elems[0].to_s
	end
end

class Exp < Oper
	def initialize(op, elems)
		# TODO this should probably happen in to_tree
		puts "Exp: #{op}"
		@source = op
		@op = $grammar.oper(op)
		@elems = elems.class == Array ? elems : [ elems ]
	end

	def to_tree
		@elems.collect! { |el| el = el.to_tree }
		self
	end
end
