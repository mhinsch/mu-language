#ifndef ARITH_H
#define ARITH_H

#include "ast_generic.h"

struct Assign : public Binary
	{
	Assign(Node * l, Node * r, int li=-1)
		: Binary(l, r, li)
		{}
			
	void accept(Visitor * v) {v->visit(this);}
	};
	
struct Number : public Term, public Token
	{
	Number(const string & v, int l=-1)
		: Term(l), Token(v)
		{}
	};

struct Float : Number
	{		
	Float(const string & v, int l=-1)
		: Number(v, l)
		{}

	void accept(Visitor * v) {v->visit(this);}
	};

struct Integer : Number
	{
	Integer(const string & v, int l=-1)
		: Number(v, l)
		{}

	void accept(Visitor * v) {v->visit(this);}
	};


struct Add : public Binary
	{
	Add(Node * l, Node * r, int li=-1)
		: Binary(l, r, li)
		{}

	void accept(Visitor * v) {v->visit(this);}
	};

struct Sub : public Binary
	{
	Sub(Node * l, Node * r, int li=-1)
		:Binary(l, r, li)
		{}

	void accept(Visitor * v) {v->visit(this);}
	};

struct Mul : public Binary
	{
	Mul(Node * l, Node * r, int li=-1)
		:Binary(l, r, li)
		{}

	void accept(Visitor * v) {v->visit(this);}
	};

struct Div : public Binary
	{
	Div(Node * l, Node * r, int li=-1)
		:Binary(l, r, li)
		{}

	void accept(Visitor * v) {v->visit(this);}
	};

struct Mod : public Binary
	{
	Mod(Node * l, Node * r, int li=-1)
		: Binary(l, r, li)
		{}

	void accept(Visitor * v) {v->visit(this);}
	};

struct Pow : public Binary
	{
	Pow(Node * l, Node * r, int li=-1)
		: Binary(l, r, li)
		{}

	void accept(Visitor * v) {v->visit(this);}
	};

struct Neg : public Unary
	{
	Neg(Node * child, int l=-1)
		: Unary(child, l)
		{}

	void accept(Visitor * v) {v->visit(this);}
	};

struct LowT : public Binary
	{
	LowT(Node * l, Node * r, int li=-1)
		: Binary(l, r, li)
		{}

	void accept(Visitor * v) {v->visit(this);}
	};

struct GreT : public Binary
	{
	GreT(Node * l, Node * r, int li=-1)
		: Binary(l, r, li)
		{}

	void accept(Visitor * v) {v->visit(this);}
	};

struct LowTEq : public Binary
	{
	LowTEq(Node * l, Node * r, int li=-1)
		: Binary(l, r, li)
		{}

	void accept(Visitor * v) {v->visit(this);}
	};

struct GreTEq : public Binary
	{
	GreTEq(Node * l, Node * r, int li=-1)
		: Binary(l, r, li)
		{}

	void accept(Visitor * v) {v->visit(this);}
	};

struct Equal : public Binary
	{
	Equal(Node * l, Node * r, int li=-1)
		: Binary(l, r, li)
		{}

	void accept(Visitor * v) {v->visit(this);}
	};

struct Uneq : public Binary
	{
	Uneq(Node * l, Node * r, int li=-1)
		: Binary(l, r, li)
		{}

	void accept(Visitor * v) {v->visit(this);}
	};


#endif	//ARITH_H
