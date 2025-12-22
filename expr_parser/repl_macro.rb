
class ReplMacro
	attr_reader :name, :pattern, :template

	def initialize(pattern, template)
		pattern.is_a?(Node) || error("macro pattern has to be a node")
		template.is_a?(Node) || error("macro pattern has to be a node")
		@name = pattern.call_oper.symbol
		@pattern = pattern
		@template = template
		puts "created macro"
		@pattern.dump
		@template.dump
	end

	def matches?(pattern, node)
		# $name eats entire node
		if pattern.node_type == :sidentifier
			puts "#{pattern.symbol} matches #{node.node_type}"
			return {pattern.symbol => node}
		end
		
		# in all other cases node types have to be identical
		if pattern.node_type != node.node_type
			puts "#{pattern.node_type} != #{node.node_type}"
			return nil
		end

		# identifiers match themselves
		if pattern.identifier?
			if node.symbol != pattern.symbol
				puts "#{node.symbol} != #{pattern.symbol}"
				return nil
			else
				return {}
			end
		end

		pargs = pattern.args
		nargs = node.args

		if pargs.size == 0 && nargs.size == 0
			return {}
		end

		m = matches?(pargs[0], nargs[0])
		if !m
			return nil
		end

		(1..pargs.size-1).each do |i|
			if i >= nargs.size
				puts "not enough arguments"
				return nil
			end
			arg = pargs[i]
			# $name_ matches the rest of the arguments
			if arg.node_type == :sidentifier && arg.symbol[-1] == '_'
				m[arg.symbol] = nargs[i:-1]
				return m
			end

			m_i = matches?(arg, nargs[i])
			if m_i == nil
				return nil
			end

			m.merge!(m_i) { |key, _v1, _v2| error("duplicate capture var: #{key}") }
		end

		# NOW we check for size mismatch since apparently no wildcard match occured
		if pargs.size != nargs.size
			puts "unmatched arguments #{pargs.size} != #{nargs.size}"
			return nil
		end

		m
	end
	
	def match(node)
		puts "matching:"
		@pattern.dump(1)
		matches?(@pattern, node)
	end

	# replace $0... in node with args[...]
	def replace(matches, node = @template.copy)
		if node.node_type == :insert
			var = node.args[0]
			if var.node_type != :sidentifier
				error("unknow insertion type #{var.node_type}")
			end
			
			repl = matches[var.symbol]
			if repl == nil
				error("unknown insertion symbol #{var.symbol}")
			end
			puts "found macro arg #{var.symbol}!"
			return repl
		end

		node.args.each_index do |i|
			node.args[i] = replace(matches, node.args[i])
		end

		node	
	end
	
end
