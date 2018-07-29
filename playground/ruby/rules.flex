%{
#define YYSTYPE Node *

#include <iostream>

#include "arith.h"
#include "Expression.tab.h"

#define YY_USER_ACTION {yylloc.first_line = yylineno;}

int line = 0;
%}

%option noyywrap
%option yylineno

STRING		\"[^"]*\"
DIGIT		-?[0-9]
ID			[a-zA-Z][a-zA-Z0-9_]*
EXP			[eE][+-][0-9]+
WSNL		[ \t\n]*

%%

"//"[^\n]*

{ID}						{return NAME;}

{DIGIT}+					{return INT_LIT;}

{DIGIT}*"."{DIGIT}+{EXP}?	{return FLOAT_LIT;}
{DIGIT}+"."{EXP}?			{return FLOAT_LIT;}
{STRING}					{return STRING_LIT;}


"**"{WSNL}				return POW;
"*"{WSNL}				return MUL;
"/"{WSNL}				return DIV;
"%"{WSNL}				return MOD;

"~"{WSNL}				return NEG;
"+"{WSNL}				return ADD;
"-"{WSNL}				return SUB;

"++"{WSNL}				return CAT;

"<"{WSNL}				return LT;
">"{WSNL}				return GT;
"<="{WSNL}				return LTE;
">="{WSNL}				return GTE;
"=="{WSNL}				return EQ;
"><"{WSNL}				return UNEQ;

"~~"{WSNL}				return LNOT;
"&&"{WSNL}				return LAND;
"||"{WSNL}				return LOR;

"->"{WSNL}				return ARR;

"@"{WSNL}				return AS;

"::"{WSNL}				return TAG;
","{WSNL}				return TUPLE;

":"{WSNL}				return CALL;

"="{WSNL}				return ASSIGN;

";"						return TO_EXP;

"("{WSNL}				return LPAR;
")"						return RPAR;
"{"{WSNL}				return LBRA;
"}"						return RBRA;
"["{WSNL}				return LSBR;
"]"						return RSBR;

";;"					return NL;
\n						return NL;


<<EOF>> return 0;

[\t ]+
