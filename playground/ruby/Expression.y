%{
#define YYSTYPE Node *
#include <string>

extern char * yytext;
int yylex ();
void yyerror (char const *);
//extern YYLTYPE yyloc;

using namespace std;

Node * top;

%}


%left 		NL
%left 		TO_EXP
%right 		ASSIGN
%left 		CALL
%right 		TUPLE
%nonassoc 	TAG
%right	 	AS
%right		ARR
%left 		LAND LOR
%nonassoc 	LNOT
%left 		CAT
%left 		LT GT LTE GTE EQ UNEQ
%left 		ADD SUB
%nonassoc 	NEG 
%left 		MUL DIV MOD
%right 		POW
%left 		F_CALL
%left		SUBSCR

%token 		INT_LIT FLOAT_LIT NAME STRING_LIT
%token 		LPAR
%token 		RPAR
%token 		LBRA
%token 		RBRA
%token		LSBR
%token		RSBR


%%


program : el code_lit el 	{top = $2;}

expr : TO_EXP expr					{$$ = new CTuple($2, @1.first_line);} 
	| expr ASSIGN expr				{$$ = new Assign($1, $3, @2.first_line);} 
	| expr CALL expr 				{$$ = new FCall($1, $3, @2.first_line);}
	| expr TUPLE expr				{Tuple * t = new Tuple($1, @2.first_line); 
									 $$ = t->append($3);}
	| expr TAG expr					{$$ = new Tag($1, $3, @2.first_line);}
	| expr AS expr					{$$ = new As($1, $3, @2.first_line);}
	| expr AS						{$$ = new As($1, new Empty, @2.first_line);}
	| expr ARR expr					{$$ = new Arrow($1, $3, @2.first_line);}
	| expr LOR expr					{$$ = new LOr($1, $3, @2.first_line);}
	| expr LAND expr				{$$ = new LAnd($1, $3, @2.first_line);}
	| expr UNEQ expr				{$$ = new Uneq($1, $3, @2.first_line);}
	| expr EQ expr					{$$ = new Equal($1, $3, @2.first_line);}
	| expr GTE expr					{$$ = new GreTEq($1, $3, @2.first_line);}
	| expr LTE expr					{$$ = new LowTEq($1, $3, @2.first_line);}
	| expr GT expr					{$$ = new GreT($1, $3, @2.first_line);}
	| expr LT expr					{$$ = new LowT($1, $3, @2.first_line);}
	| expr CAT expr					{$$ = new Cat($1, $3, @2.first_line);}
	| expr SUB expr					{$$ = new Sub($1, $3, @2.first_line);}
	| expr ADD expr					{$$ = new Add($1, $3, @2.first_line);}
	| expr DIV expr					{$$ = new Div($1, $3, @2.first_line);}
	| expr MUL expr					{$$ = new Mul($1, $3, @2.first_line);}
	| expr POW expr					{$$ = new Pow($1, $3, @2.first_line);}
	| expr expr %prec F_CALL		{$$ = new FCall($1, $2, @1.first_line);}
	| expr subscript %prec SUBSCR	{$$ = new Subscript($1, $2, @2.first_line);}
	| LPAR expr RPAR				{$$ = $2;}//new Nest($2);}
	| LPAR RPAR						{$$ = new Empty(@1.first_line);}
	| literal						{$$ = $1;}
	| NAME							{$$ = new Name(yytext, @1.first_line);}
		

literal : INT_LIT					{$$ = new Integer(yytext, @1.first_line);}
	| FLOAT_LIT						{$$ = new Float(yytext, @1.first_line);}
	| STRING_LIT					{$$ = new String(yytext, @1.first_line);}
	| code_lit

code_lit : code_block				{$$ = $1;}

code_block : LBRA lines RBRA		{$$ = $2;}
	| LBRA lines al RBRA			{$$ = $2;}
	
lines : 							{$$ = new CTuple(new Empty);}
	| expr							{$$ = new CTuple($1, @1.first_line);}
	| lines al expr					{CTuple * t = (CTuple*)$1;
									 $$ = t->append($3);}

subscript : LSBR expr RSBR			{$$ = $2;}

al : NL								{$$ = 0;}
	| al NL							{$$ = 0;}

el : 								{$$ = 0;}
	| NL							{$$ = 0;}
	| el NL							{$$ = 0;}

%%

main ()
	{
	if (yyparse())
		{
		cerr << "parse failed!" << endl;
		exit(1);
		}
	
	ScopeVisitor s2c;
	s2c.setSelf(&s2c);
	top->accept(&s2c);
	cout << endl;
	}
     
void yyerror (char const * s)  /* Called by yyparse on error */
	{
	yydebug = 1;
	cerr << s << endl;
	}

