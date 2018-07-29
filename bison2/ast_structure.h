#ifndef STRUCTURE_H
#define STRUCTURE_H

#include "ast_generic.h"


struct Variable : public Name
	{
	Variable(const string & v, int l=-1)
		: Name(v, l) {}
	
	void accept(Visitor * v) {v->visit(this);}
	};
	
struct CTuple : public Nary
	{
	CTuple(Node * lines, int l=-1)
		: Nary(lines, l)
		{}

	void accept(Visitor * v) {v->visit(this);}
	};

struct Tuple : public Nary
	{
	Tuple(Node * elems, int l=-1)
		: Nary(elems, l)
		{}

	void accept(Visitor * v) {v->visit(this);}
	};

struct Tag : public Binary
	{
	Tag(Node * l, Node * r, int li=-1)
		:Binary(l, r, li)
		{}

	void accept(Visitor * v) {v->visit(this);}
	};

struct FCall : public Binary
	{
	FCall(Node * l, Node * r, int li=-1)
		:Binary(l, r, li)
		{}

	void accept(Visitor * v) {v->visit(this);}
	};

struct Subscript : public Binary
	{
	Subscript(Node * l, Node * r, int li=-1)
		: Binary(l, r, li)
		{}
	
	void accept(Visitor *v) {v->visit(this);}
	};

struct Nest : public Unary
	{
	Nest(Node * c)
		: Unary(c)
		{}
	void accept(Visitor * v){v->visit(this);}
	};

#endif	//STRUCTURE_H
