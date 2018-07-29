#ifndef SCOPEVISITOR_H
#define SCOPEVISITOR_H

#include <typeinfo>
#include <map>

using namespace std;

#include "visitor.h"
#include "semantics.h"

// detects scopes and finds decalarations in scopes
class ScopeVisitorImpl
	{
protected:
	Visitor * _self;
	vector<Scope *> _scopes;
	vector<Scope *> _scopeStack;
	int _depth;
	
public:
	ScopeVisitorImpl()
		: _depth(0)
		{
		}
		
	void setSelf(Visitor * self)
		{
		_self = self;
		}
	
	void setGlobal(Scope * global)
		{
		_scopes.push_back(global);
		}
	
	Scope * top()
		{
		return _scopes[0];
		}
	
	Scope * currentScope()
		{
		return _scopeStack.size() ? _scopeStack.back() : 0;
		}
	
	void setScope(Node * n)
		{
		n->scope = currentScope();
		}
	
	void doVisit(Node * e)
		{
		setScope(e);
		}
	
	void doVisit(CTuple * ct)
		{
		setScope(ct);
		
		for (int i=0; i<_depth; i++)
			cout << "\t";
			
		cout << "{\n";
		_depth++;
		_scopes.push_back(new Scope(ct));
		_scopeStack.push_back(_scopes.back());
		
		for (int i=0; i<ct->children.size(); i++)
			ct->children[i]->accept(_self);
		
		for (int i=0; i<_depth-1; i++)
			cout << "\t";
		cout << "} ";
		cout << "\n";
		_depth--;
		
		_scopeStack.pop_back();
		}
		
	void doVisit(Nary * t)
		{
		setScope(t);
		
		for (int i=0; i<t->children.size(); i++)
			{
			t->children[i]->accept(_self);
			}
		}

	void doVisit(Unary * u)
		{
		setScope(u);
		u->child->accept(_self);
		}

	void doVisit(Binary * b)
		{
		setScope(b);
		b->left->accept(_self);
		b->right->accept(_self);
		}	
	};

typedef CVisitor<ScopeVisitorImpl> ScopeVisitor;


#endif	//SCOPEVISITOR_H
