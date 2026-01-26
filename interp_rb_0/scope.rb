MACRO = 0
VAR = 1
OP = 2
TYPE = 3


$scope_id = 0


class IScope
	attr_reader :scopes, :scope_node, :parent, :id

	def initialize(node, parent)
		@scope_node = node
		@parent = parent
		@scopes = [Hash.new, Hash.new, Hash.new, Hash.new]
		@id = $scope_id
		puts "** #{@id}"
		$scope_id += 1
	end

	def dump
		#puts @scopes[0]
		if open?
			print "[#{@id}]"
		else
			print "{#{@id}}"
		end
		if @parent != nil
			if @parent.open?
				print "[#{@parent.id}]"
			else
				print "{#{@parent.id}}"
			end
		end
		puts ": #{@scopes[1]}"
		#puts @scopes[2]
		#puts @scopes[3]
	end

	
	def has_name?(name, kind)
		@scopes[kind].has_key?(name)
	end

	def name(name, kind)
		@scopes[kind][name]
	end

	def add_name(name, val, kind)
		@scopes[kind][name] = val
	end
		
	def set_value(name, kind, val)
		@scopes[kind][name] = val
	end
	
	def open?
		@scope_node.node_type == :rocode
	end

	def top?
		@parent == nil
	end
	
	def lookup_name(a_name, kind, new_val = nil, const = false)
		if new_val && const
			error("#{a_name} is const")
		end
		
		if has_name?(a_name, kind)
			if new_val != nil
				set_value(a_name, kind, new_val)
			end
			return name(a_name, kind)
		end
		
		if ! open? && new_val != nil
			return nil
		end

		if top?
			return nil
		end

		@parent.lookup_name(a_name, kind, new_val, const || !open?)
	end

	def lookup_macro(vname)
		lookup_name(vname, MACRO, nil, false)
	end

	def add_macro(vname, val)
		puts "adding macro #{vname}"
		add_name(vname, val, MACRO)
	end
	
	def lookup_var(vname)
		lookup_name(vname, VAR)
	end

	def add_var(name, val)
		add_name(name, val, VAR)
	end

	def lookup_op(oname)
		lookup_name(oname, OP)
	end

	def add_op(name, val)
		add_name(name, val, OP)
	end

	def lookup_type(tname)
		lookup_name(tname, TYPE)
	end

	def add_type(name, val)
		add_name(name, val, TYPE)
	end
end


class Node
	attr_reader :scope	# scope object containing visible names 

	def assign_scope(parent)
		#puts "scope: " + @op.name.to_s + " " + parent.class.name

		par_scope = parent ? parent.scope : nil
		# scope of [ is linked to parent
		if code?
			@scope = IScope.new(self, par_scope)
		else
			@scope = par_scope
		end

		adjust_sub_scopes
	end

	def copy_scope(node)
		@scope = node.scope

		adjust_sub_scopes
	end
		
	def adjust_sub_scopes
		@args.each do |arg|
			arg.assign_scope(self)
		end
	end
		
end

