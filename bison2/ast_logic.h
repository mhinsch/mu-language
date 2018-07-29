#ifndef LOGIC_H
#define LOGIC_H


#include "ast_generic.h"


struct LOr : public Binary
	{
	LOr(Node * l, Node * r, int li=-1)
		: Binary(l, r, li)
		{}

	void accept(Visitor * v) {v->visit(this);}
	};

struct LAnd : public Binary
	{
	LAnd(Node * l, Node * r, int li=-1)
		: Binary(l, r)
		{}

	void accept(Visitor * v) {v->visit(this);}
	};

struct LNot : public Unary
	{
	LNot(Node * child, int l=-1)
		: Unary(child, l)
		{}

	void accept(Visitor * v) {v->visit(this);}
	};


#endif	//LOGIC_H
