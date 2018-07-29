class ArithmeticPrecedenceGrammar < Dhaka::Grammar
   precedences do
     left %w|+ -|
     left %w|* /|
   end

   for_symbol(Dhaka::START_SYMBOL_NAME) do
     expression %w| E |
   end

   for_symbol('E') do
     addition 					%w| E + E |
     subtraction				%w| E - E |
	 multiplication 			%w| E * E |
	 division 					%w| E / E |
     literal					%w| n |
     parenthetized_expression ['(', 'E', ')']
     negated_expression ['-', 'E'], :prec => '*'
   end
 end

