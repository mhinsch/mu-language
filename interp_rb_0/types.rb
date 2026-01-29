# static version, TBD


class Node
	alias_method :init_previous, :initialize
	attr_reader :tags

	def initialize(op_token)
		init_previous(op_token)

		@tags = {}
	end

	def set_tag(key, value)
		@tags[key] = value
	end

	def assign_mutability
		@args.each do |arg|
			arg.assign_mutability
		end


		

	end
end
