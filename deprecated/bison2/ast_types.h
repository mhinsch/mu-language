#ifndef TYPES_H
#define TYPES_H


struct As : public Binary
	{
	As(Node * l, Node * r, int li=-1)
		: Binary(l, r, li)
		{}

	void accept(Visitor * v) {v->visit(this);}
	};

	
struct Arrow : public Binary
	{
	Arrow(Node * l, Node * r, int li=-1)
		: Binary(l, r, li)
		{}

	void accept(Visitor * v) {v->visit(this);}
	};
	
#endif	//TYPES_H
