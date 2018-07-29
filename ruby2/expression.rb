class Node
	attr_reader :name, :par, :par_dir, :left, :l_prio, :right, :r_prio

	def initialize(name, l_prio, r_prio)
		@l_prio = l_prio
		@r_prio = r_prio
		@name = name
	end

	def show(lvl)
		puts ("\t"*lvl) + @name
		if @left
			@left.show(lvl+1)
		end
		if @right
			@right.show(lvl+1)
		end
	end

	def right_open
		@right == nil && @r_prio > 0
	end

	def left_open
		@left == nil && @l_prio > 0
	end

	def bound
		if @par == nil
			return 0
		end

		@par_dir ? @par.l_prio : @par.r_prio
	end

	def setPar(node, dir)
		@par = node
		@par_dir = dir
	end

	def insert(node, dir)
		if dir
			@left = node
			node.setPar(self, dir)
		else
			@right = node
			node.setPar(self, dir)
		end
	end

	def attach(node)
		show(0)
		if right_open == node.left_open
			$stderr.puts "[#{@name} ^ #{node.name}] error: operand needed"
			exit
		end
		
		if right_open 
			insert(node, false)
			return node
		end

		if !right_open
			if @r_prio > -1 && node.l_prio > @r_prio
				node.insert(@right, true)
				insert(node, false)
				node
			else
				if @par != nil
					@par.attach(node)
				else
					node.insert(self, true)
					node
				end
			end
		end
	end

end


class ParNode < Node
	def initialize(name, open_par, l_prio, r_prio)
		super(name, l_prio, r_prio)
		@open_par = open_par
	end

	def close
		@r_prio = -1
	end

	def attach(node)
		if @open_par && node.name == @name && ! node.open_par
			close
			return self
		else
			super.attach(node)
		end
	end
end


nodes = [
	ParNode.new("(", true, -1, 1), 
	Node.new("a", -1, -1), 
	Node.new("+", 10, 10), 
	Node.new("b", -1, -1), 
	ParNode.new("(", false, 1, -1),
	Node.new("*", 20, 20), 
	Node.new("c", -1, -1)]

node = nodes.shift

nodes.each do |n|
	node = node.attach(n)
end

while node.par 
	node = node.par
end

node.show(0)
