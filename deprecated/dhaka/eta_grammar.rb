class EtaGrammar < Dhaka::Grammar

	precedences do
		nonassoc %w| == |
		nonassoc %w| < > |
		left     %w| + - |
		left     %w| * / |
		nonassoc %w| ^ |
		nonassoc %w| ~ |
	end
  
	for_symbol(Dhaka::START_SYMBOL_NAME) do
		program                             %w| preamble block |
	end

	for_symbol('block') do
		expressionlist 						%w| { expressions } |
	end
  
	for_symbol('expressions') do
		single_expr          				%w| expression |
		multiple_expr						%w| expression newline expressions |
	end

	for_symbol('expression') do
		assignment_expr                		%w| expression = expression |
	end
      
	for_symbol('var_name') do
		variable_name                       %w| word_literal |
	end
  
	for_symbol('expression') do
		negation                            %w| ~ expression |
		equality_comparison                 %w| expression == expression |
		greater_than_comparison             %w| expression > expression |
		less_than_comparison                %w| expression < expression |
		addition                            %w| expression + expression |
		subtraction                         %w| expression - expression |
		multiplication                      %w| expression * expression |
		division                            %w| expression / expression |
		literal                             %w| numeric_literal |
		function_call_expression            %w| expression expression |
		variable_reference                  %w| var_name |
		parenthetized_expression            %w| ( expression ) |
	end
    
end