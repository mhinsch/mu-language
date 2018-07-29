/* Test */

%{
#define YYERROR_VERBOSE
#define YYSTYPE int
%}

/* BISON Declarations */
%token NUM

/* Grammar follows */
%%

S:	E		{printf("1: %d\n", $$);}
	;

     
E:	E '+' T	{printf("2: %d ->\n", $$);}
	| T		{printf("3: %d ->\n", $$);}
	;

T:	NUM		{printf("4: %d ->\n", $$);}

%%

main ()
	{
	yyparse ();
	}

#include <stdio.h>

yyerror (s)  /* Called by yyparse on error */
	char *s;
	{
	printf ("%s\n", s);
	}

#include <ctype.h>

yylex ()
	{
	int c;
	
	/* skip white space  */
	while ((c = getchar ()) == ' ' || c == '\t' || c == '\n')
	;
	/* process numbers   */
	if (isdigit (c))
		{
		ungetc (c, stdin);
		scanf ("%d", &yylval);
		return NUM;
		}
	/* return end-of-file  */
	if (c == EOF)
		return 0;
	/* return single chars */
	return c;
	}
