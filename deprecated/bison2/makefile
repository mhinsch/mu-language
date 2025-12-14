etac: eta_parse.tab.c eta_lex.yy.c *.h
	gcc -g -x c++ -o $@ eta_parse.tab.c eta_lex.yy.c -lstdc++

visitorfw.h : nodes.lst
	ruby crVisitorFW.rb $< > $@
	
eta_parse.tab.c : eta_parse.y
	bison -tvd $<
	
eta_lex.yy.c : eta_lex.flex
	flex -o $@  $<
	
clean:
	rm -f etac eta_lex.yy.c eta_parse.tab.*
