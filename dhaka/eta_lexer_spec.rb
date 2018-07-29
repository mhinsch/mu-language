# lipi:lexer_spec
class EtaLexerSpec < Dhaka::LexerSpecification
  
  for_pattern('==') do
    create_token('==')
  end

  %w| = - > < , + * ( ) /|.each do |char|
    for_symbol(char) do
      create_token(char)
    end
  end

  for_pattern("\n") do 
    create_token('newline')
  end
  
  for_pattern(' ') do
    # ignore whitespace
  end
  
  #lipi:keywords
  for_pattern('\w+') do
      create_token 'word_literal'
  end
  #lipi:keywords
  
  for_pattern('\d*(\.\d+)?') do
    create_token('numeric_literal')
  end
end
# lipi:lexer_spec
