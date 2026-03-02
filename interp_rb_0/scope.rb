MACRO = 0
VAR = 1
OP = 2
TYPE = 3

# TODO
# * change builtin types to tagging contructors
# * store literals in ILit?



$scope_id = 0


class IObj
	attr_reader :name, :value, :tags

	def initialize(name, value, tags = Hash.new)
		@name = name
		@value = value
		@tags = tags
	end

	def assign(new_val)
		@val = new_val
	end

	def set_tag(tag, val)
		@tags[tag] = val
	end

	def mu_type
		@tags[:type]
	end

	def mu_const
		@tags[:const]
	end
end


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

	
	def has_obj?(name, kind)
		@scopes[kind].has_key?(name)
	end

	def get_obj(name, kind)
		@scopes[kind][name]
	end
		
	def set_value(name, kind, val)
		get_obj(name, kind).set_value(val)
	end
	
	def open?
		@scope_node.node_type == :rocode
	end

	def top?
		@parent == nil
	end
	
	def lookup_obj(a_name, kind, new_val = nil, readonly = false)
		if new_val && readonly
			error("#{a_name} is readonly")
		end
		
		if has_obj?(a_name, kind)
			if new_val != nil
				set_value(a_name, kind, new_val)
			end
			return get_obj(a_name, kind)
		end
		
		if ! open? && new_val != nil
			return nil
		end

		if top?
			return nil
		end

		@parent.lookup_obj(a_name, kind, new_val, readonly || !open?)
	end

	def lookup_macro(vname)
		lookup_obj(vname, MACRO, nil, false)
	end

	def lookup_var(vname)
		lookup_obj(vname, VAR)
	end

	def lookup_op(oname)
		lookup_obj(oname, OP)
	end

	def lookup_type(tname)
		lookup_obj(tname, TYPE)
	end

	def define_macro(name, val)
		define_obj(name, val, false, MACRO)
	end
	
	def define_var(name, val, mut)
		define_obj(name, val, mut, VAR)
	end
	
	def define_op(name, val)
		define_obj(name, val, false, OP)
	end
	
	def define_type(name, val)
		define_obj(name, val, false, TYPE)
	end
	
	def define_obj(name, val, const, kind=VAR)
		var = IObj.new(name, val, {:const => const})
		var.set_tag(:type, val.mu_type)
		
		@scopes[kind][name] = var

		puts "define #{name}"
		dump
		
		val
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

