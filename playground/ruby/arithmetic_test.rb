dir = File.dirname(__FILE__)
#require File.expand_path("#{dir}/test_helper")

require File.expand_path("#{dir}/arithmetic_node_classes")
Treetop.load File.expand_path("#{dir}/arithmetic")

@parser = ArithmeticParser.new
p @parser.parse("a + b * c")

