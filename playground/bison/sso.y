/* Test */

%{
#define YYERROR_VERBOSE
#define YYSTYPE vector<string>

#include <vector>
#include <string>
#include <iostream>

using namespace std;

namespace SSO
{

int yylex();
int yyerror(char * s);

void printObj(vector<string> o)
	{
	for (vector<string>::iterator i=o.begin(); i!=o.end(); i++)
		{
		cout << *i;
		}
	}

%}

/* BISON Declarations */

%token ID

/* Grammar follows */
%%

SSO:	'{' OBJ '}'	
	;

OBJ:	OBJ PRP ';'		{ $$ = $1; $$.insert($$.end(), $2.begin(), $2.end()); }
	|	PRP ';'	
	;

PRP:	ID '=' VAL		{ $$ = $1; $$.push_back("="); 
						  $$.insert($$.end(), $3.begin(), $3.end()); 
						  $$.push_back("\n"); }
	;

VAL:	VAL ID			{ $$ = $1; $$.push_back(":"); 
						  $$.insert($$.end(), $2.begin(), $2.end()); }
	|	ID			
	;

%%


#include <ctype>


void skipComment(istream & in)
	{
	char c;
	
	do
		{
		c = in.get();
		}
	while(c != '#' && !in.eof());
	}

void skipWhiteSpace(istream & in)
	{
	char c;
	
	do
		{
		c = in.get();
		if (in.eof()) return;
		}
	while(isspace(c));

	in.putback(c);
	}

void skipSpace(istream & in)
	{
	char c;
	
	while(!in.eof())
		{
		in.get(c);
		if (c == '#') skipComment(in);
		else if (isspace(c)) skipWhiteSpace(in);
		else 
			{
			in.putback(c);
			return;
			}
		}	
	}

int yylex()
	{
	istream & in = *file2Parse;

	skipSpace(in);
	
	char c = in.get();
	string word;
	string delim = "{}=;";
	
	if (delim.find(c) == delim.npos)
		{
		bool quote = c == '"';
		string vDelim;
		if (quote)
			{
			delim = "";
			vDelim = "\"";
			}
		else
			{
			word += c;
			vDelim = " \t\n";
			}
		
		while(
			delim.find(c=in.get()) == delim.npos && 
			vDelim.find(c) == vDelim.npos)
			{
			if (in.eof()) return 0;
			word += c;
			}
		
		// grammar signs have to be put back
		if (delim.find(c) != delim.npos)
			in.putback(c);
		yylval = vector<string>(1, word);
		return ID;
		}
	
	return c;
	}

int yyerror(char * s)
	{
	cout << s;
	}

};

