
inp = 
	if ARGV.size == 0 then
		$stdin
	else
		File.open(ARGV[0])
		end

lines = inp.readlines.collect {|l| l.chomp}

# include guard
puts "#ifndef VISITORFW_H"
puts "#define VISITORFW_H"

# struct forward declarations
lines.each do |l|
	puts "struct " + l + ";"
	end
	
puts
puts

# Visitor ABC
puts "class Visitor"
puts "\t{"
puts "public:"
lines.each do |l|
	puts "\tvirtual void visit(" + l + " * n) = 0;"
	end
	
puts "\t};"

puts 
puts

# link to implemementation
puts "template<class IMPL>"
puts "class CVisitor : public Visitor, public IMPL"
puts "\t{"
puts "public:"
lines.each do |l|
	puts "\tvoid visit(" + l + " * n)"
	puts "\t\t{this->doVisit(n);}"
	end
puts "\t};"

#end of include guard
puts "#endif\t//VISITORFW_H"
