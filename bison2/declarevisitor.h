#ifndef DECLAREVISITOR_H
#define DECLAREVISITOR_H


#include "visitor.h"
#include "semantics.h"


class DeclareVisitorImpl
	{
protected:
	Visitor * _self;
	
public:
	DeclareVisitorImpl() {}
	
	void setSelf(Visitor * self)
		{
		_self = self;
		}
	
	void doVisit(Node *)
		{
		}

	void doVisit(Unary * u)
		{
		u->child->accept(_self);
		}

	void doVisit(Binary * b)
		{
		b->left->accept(_self);
		b->right->accept(_self);
		}

	void doVisit(Nary * t)
		{
		for (int i=0; i<t->children.size(); i++)
			{
			t->children[i]->accept(_self);
			}
		}
	
	void doVisit(As * a)
		{
		cout << "line " << a->line << ": decl."  << endl;

		a->scope->addDeclaration(a);
		}
	
	// sort of a hack
	// effectively changes syntax via semantic manipulations
	void doVisit(Assign * a)
		{
		if (!isa<As>(a->left))
			{
			// force call of more general function
			this->doVisit((Binary*)a);
			return;
			}
		
		cout << "line " << a->line << ": idecl."  << endl;
		
		As * as = dynamic_cast<As*>(a->left);
		Node * ini = a->right;
		
		a->scope->addDeclaration(as, ini);
		
		ini->accept(_self);
		}
	};

typedef CVisitor<DeclareVisitorImpl> DeclareVisitor;

#endif	// DECLAREVISITOR_H