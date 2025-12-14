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
	attr_reader :name, :assoc, :opers, :up, :down

	def initialize(name, assoc)
		@assoc = assoc
		@name = name
	end

	def add_oper(oper)
	end
end

class Grammar
	def initialize
		@lsum = Level.new(:sum, :left)
		@lprod = Level.new(:prod, :left)
		@ltuple = Level.new(:tuple, :none) 
		@lassign = Level.new(:assign, :right)

		@levels = [@lsum, @lprod, @ltuple, @lassign]

		Operator.new(:plus, '+', @lsum)
		Operator.new(:minus, '-', @lsum)
		Operator.new(:mult, '*', @lprod)
		Operator.new(:div, '/', @lprod)
		Operator.new(:mod, '%', @lprod)
		Operator.new(:eq, '=', @lassign)
		Operator.new(:comma, ',', @ltuple)
	end

	def is_level?(name)

		print "is_level "
		p name
		@levels.each do |l|
			if l.name == name
				return l
			end
		end

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
	def initialize(op, elems)
		opn = op.to_s
		@op = $operators.has_key?(opn) ? $operators[opn] : op.to_s
		@elems = elems
	end

	def reshuffle
		l = $grammar.is_level?(@op)
		
		if ! l or @elems.size < 2
			@elems = @elems.collect {|e| e.reshuffle}
			return self
		end

		dir = l.assoc

		if dir == :right
			puts "RIGHT"
			el = @elems[0]
			for i in 1...@elems.size-1 do
				el = @elems[i].addleft(el)
			end
			@elems = [el.reshuffle, @elems.last.elems[0].reshuffle]
			@op = @elems.last.op
			return self
		end

		if false # dir == :left
			el = @elems.last
			for i in 1...@elems.size-1 do
				el = @elems[i].addleft(el)
			end
			@elems = [el.reshuffle, @elems.last.elems[0].reshuffle]
			@op = @elems.last.op
			return self
		end

		self
	end

	def pprint(out, lvl)
		if $grammar.is_level?(@op)
			puts("level!")
		end

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
end

