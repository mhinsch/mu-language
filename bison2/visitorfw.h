#ifndef VISITORFW_H
#define VISITORFW_H
struct CTuple;
struct Assign;
struct Tuple;
struct FCall;
struct As;
struct Arrow;
struct Tag;
struct LAnd;
struct LOr;
struct LNot;
struct Cat;
struct LowT;
struct GreT;
struct LowTEq;
struct GreTEq;
struct Equal;
struct Uneq;
struct Add;
struct Sub;
struct Neg;
struct Mul;
struct Div;
struct Mod;
struct Pow;
struct Integer;
struct Float;
struct String;
struct Name;
struct Empty;
struct Subscript;
struct Nest;


class Visitor
	{
public:
	virtual void visit(CTuple * n) = 0;
	virtual void visit(Assign * n) = 0;
	virtual void visit(Tuple * n) = 0;
	virtual void visit(FCall * n) = 0;
	virtual void visit(As * n) = 0;
	virtual void visit(Arrow * n) = 0;
	virtual void visit(Tag * n) = 0;
	virtual void visit(LAnd * n) = 0;
	virtual void visit(LOr * n) = 0;
	virtual void visit(LNot * n) = 0;
	virtual void visit(Cat * n) = 0;
	virtual void visit(LowT * n) = 0;
	virtual void visit(GreT * n) = 0;
	virtual void visit(LowTEq * n) = 0;
	virtual void visit(GreTEq * n) = 0;
	virtual void visit(Equal * n) = 0;
	virtual void visit(Uneq * n) = 0;
	virtual void visit(Add * n) = 0;
	virtual void visit(Sub * n) = 0;
	virtual void visit(Neg * n) = 0;
	virtual void visit(Mul * n) = 0;
	virtual void visit(Div * n) = 0;
	virtual void visit(Mod * n) = 0;
	virtual void visit(Pow * n) = 0;
	virtual void visit(Integer * n) = 0;
	virtual void visit(Float * n) = 0;
	virtual void visit(String * n) = 0;
	virtual void visit(Name * n) = 0;
	virtual void visit(Empty * n) = 0;
	virtual void visit(Subscript * n) = 0;
	virtual void visit(Nest * n) = 0;
	};


template<class IMPL>
class CVisitor : public Visitor, public IMPL
	{
public:
	void visit(CTuple * n)
		{this->doVisit(n);}
	void visit(Assign * n)
		{this->doVisit(n);}
	void visit(Tuple * n)
		{this->doVisit(n);}
	void visit(FCall * n)
		{this->doVisit(n);}
	void visit(As * n)
		{this->doVisit(n);}
	void visit(Arrow * n)
		{this->doVisit(n);}
	void visit(Tag * n)
		{this->doVisit(n);}
	void visit(LAnd * n)
		{this->doVisit(n);}
	void visit(LOr * n)
		{this->doVisit(n);}
	void visit(LNot * n)
		{this->doVisit(n);}
	void visit(Cat * n)
		{this->doVisit(n);}
	void visit(LowT * n)
		{this->doVisit(n);}
	void visit(GreT * n)
		{this->doVisit(n);}
	void visit(LowTEq * n)
		{this->doVisit(n);}
	void visit(GreTEq * n)
		{this->doVisit(n);}
	void visit(Equal * n)
		{this->doVisit(n);}
	void visit(Uneq * n)
		{this->doVisit(n);}
	void visit(Add * n)
		{this->doVisit(n);}
	void visit(Sub * n)
		{this->doVisit(n);}
	void visit(Neg * n)
		{this->doVisit(n);}
	void visit(Mul * n)
		{this->doVisit(n);}
	void visit(Div * n)
		{this->doVisit(n);}
	void visit(Mod * n)
		{this->doVisit(n);}
	void visit(Pow * n)
		{this->doVisit(n);}
	void visit(Integer * n)
		{this->doVisit(n);}
	void visit(Float * n)
		{this->doVisit(n);}
	void visit(String * n)
		{this->doVisit(n);}
	void visit(Name * n)
		{this->doVisit(n);}
	void visit(Empty * n)
		{this->doVisit(n);}
	void visit(Subscript * n)
		{this->doVisit(n);}
	void visit(Nest * n)
		{this->doVisit(n);}
	};
#endif	//VISITORFW_H
