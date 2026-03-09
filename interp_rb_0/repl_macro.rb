
class ReplMacro
	attr_reader :name, :pattern, :template

	def initialize(pattern, template)
		pattern.is_a?(Node) || error("macro pattern has to be a node")
		template.is_a?(Node) || error("macro pattern has to be a node")
		@name = pattern.call_oper.symbol
		@pattern = pattern
		@template = template
		puts "created macro"
		print "\t"; @pattern.dump_short
		puts "=>"
		print "\t"; @template.dump_short
		puts
	end

	def mu_type
		:macro
	end
	
	def match_one_or_many(arg)
		arg.node_type == :sidentifier && arg.symbol[-1] == '_' && arg.symbol[-2] != '_'
	end
	
	def match_remaining(arg)
		arg.node_type == :sidentifier && arg.symbol[-1] == '_' && arg.symbol[-2] == '_'
	end
	
	def matches?(pattern, node)
		# $name eats entire node
		if pattern.node_type == :sidentifier
			puts "\t#{pattern.symbol} matches #{node.node_type}"
			return {pattern.symbol => node}
		end
		
		# in all other cases node types have to be identical
		if pattern.node_type != node.node_type
			puts "\t#{pattern.node_type} != #{node.node_type}"
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

		# no args, done
		if pargs.size == 0 && nargs.size == 0
			return {}
		end

		# check if the op is the same
		m = matches?(pargs[0], nargs[0])
		if !m
			return nil
		end

		# check args
		(1..pargs.size-1).each do |i|
			if i >= nargs.size
				puts "not enough arguments"
				return nil
			end
			arg = pargs[i]
			# $name__ collects the rest of the arguments in a tuple
			# $name_ returns a tuple or a single value
			# $name only matches single values
			if match_remaining(arg) || (match_one_or_many(arg) && i<(nargs.size-1))
				m[arg.symbol] = Node.create_tuple(nargs[i..-1])
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
		puts "\tmatching:"
		print "\t"; @pattern.dump_short; puts
		matches?(@pattern, node)
	end

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
			puts "\tfound macro arg #{var.symbol}!"
			return repl
		end

		(node.args.size - 1).downto(0) do |i|
			repl = replace(matches, node.args[i])
			if repl.is_a?(Node)
				node.args[i] = repl
			else
				repl.is_a?(Array) || error("replacement has to be Array or Node")
				node.args.delete_at(i)
				node.args.insert(i, *repl)
			end
		end

		node	
	end
	
end
