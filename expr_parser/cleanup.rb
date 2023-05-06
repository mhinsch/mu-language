class Node
	def flatten
		@args.each do |t|
			if t.class == Node
				t.flatten
			end
		end

		#if @op.arity > 0
		#	return
		#end

		@args.each_index do |i|
			t = @args[i]
			if t.class == Node && t.op.name == @op.name
				n = t.args.size
				@args.insert(i, *t.args)
				@args.delete_at(i)
				i += n - 1
			end
		end
	end
end
			

