/* A Bison parser, made by GNU Bison 2.3.  */

/* Skeleton interface for Bison's Yacc-like parsers in C

   Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003, 2004, 2005, 2006
   Free Software Foundation, Inc.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor,
   Boston, MA 02110-1301, USA.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     NL = 258,
     TO_EXP = 259,
     ASSIGN = 260,
     CALL = 261,
     TUPLE = 262,
     TAG = 263,
     AS = 264,
     ARR = 265,
     LOR = 266,
     LAND = 267,
     LNOT = 268,
     CAT = 269,
     UNEQ = 270,
     EQ = 271,
     GTE = 272,
     LTE = 273,
     GT = 274,
     LT = 275,
     SUB = 276,
     ADD = 277,
     NEG = 278,
     MOD = 279,
     DIV = 280,
     MUL = 281,
     POW = 282,
     F_CALL = 283,
     SUBSCR = 284,
     INT_LIT = 285,
     FLOAT_LIT = 286,
     NAME = 287,
     STRING_LIT = 288,
     LPAR = 289,
     RPAR = 290,
     LBRA = 291,
     RBRA = 292,
     LSBR = 293,
     RSBR = 294
   };
#endif
/* Tokens.  */
#define NL 258
#define TO_EXP 259
#define ASSIGN 260
#define CALL 261
#define TUPLE 262
#define TAG 263
#define AS 264
#define ARR 265
#define LOR 266
#define LAND 267
#define LNOT 268
#define CAT 269
#define UNEQ 270
#define EQ 271
#define GTE 272
#define LTE 273
#define GT 274
#define LT 275
#define SUB 276
#define ADD 277
#define NEG 278
#define MOD 279
#define DIV 280
#define MUL 281
#define POW 282
#define F_CALL 283
#define SUBSCR 284
#define INT_LIT 285
#define FLOAT_LIT 286
#define NAME 287
#define STRING_LIT 288
#define LPAR 289
#define RPAR 290
#define LBRA 291
#define RBRA 292
#define LSBR 293
#define RSBR 294




#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef int YYSTYPE;
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
# define YYSTYPE_IS_TRIVIAL 1
#endif

extern YYSTYPE yylval;

#if ! defined YYLTYPE && ! defined YYLTYPE_IS_DECLARED
typedef struct YYLTYPE
{
  int first_line;
  int first_column;
  int last_line;
  int last_column;
} YYLTYPE;
# define yyltype YYLTYPE /* obsolescent; will be withdrawn */
# define YYLTYPE_IS_DECLARED 1
# define YYLTYPE_IS_TRIVIAL 1
#endif

extern YYLTYPE yylloc;
