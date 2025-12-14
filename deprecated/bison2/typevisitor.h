#ifndef TYPEVISITOR_H
#define TYPEVISITOR_H

class TypeVisitorImpl
	{
protected:
	Visitor * _self;

public:
	
	void setSelf(Visitor * self)
		{
		_self = self;
		}
	
	void doVisit(Unary * u)
		{
		u->child->accept(_self);
		
		Type * childType = u->child->type;
		
		Operator * op = builtin.match(type_str(u), childType);

		if (op == 0)
			{
			cerr << "no match for operator " << type_str(u) << endl;
			exit(0);
			}
		
		u->type = op->returnType();
		}
	
	void doVisit(Binary * b)
		{
		b->left->accept(_self);
		b->right->accept(_self);
		
		Operator * op = builtin.match(type_str(b), 
			typeVector(nodeType[b->left], nodeType[b->right]));
		
		if (op == 0)
			{
			cerr << "no match for operator " << type_str(b) << endl;
			exit(0);
			}
		
		b->type = op->returnType();
		}
	
	void doVisit(FCall * f)
		{
		l->accept(_self); // we need this e.g. for functions as return value
		r->accept(_self);
		
		// formally only 1 arg!
		Operator * op = currentScope().match(f->name, r->type);
		
		f->type = op->returnType();
		}
	
	void doVisit(Tuple * t)
		{
		for (int i=0; i<t->children.size(); i++)
			{
			t->children[i]->accept(_self);
			}
// 		each tuple creates its own type which is just a list of types
//		for efficiency these should maybe be joined?
		TupleType * tt = new TupleType;
		
		for (int i=0; i<t->children.size(); i++)
			{
			tt->elems.push_back(nodeType[t->children[i]]);
			}
		
		t->type = tt;
		}
	
	void doVisit(CTuple * c)
		{
		FunctionType * t = new FunctionType;
		// have to collect return statements?
		}
	};

typedef CVisitor<TypeVisitorImpl> TypeVisitor;

#endif	//TYPEVISITOR_H