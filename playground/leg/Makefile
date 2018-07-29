all : parser test

test : test.c
	gcc -o $@ $<

test.c : test.leg
	leg $< > $@


parser: parser.cc
	gcc -g -fexceptions -o $@ $< -lstdc++

parser.cc : eta.leg
	leg $< > $@

clean:
	rm -f parser.c parser.cc parser
