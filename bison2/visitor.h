#ifndef VISITOR_H
#define VISITOR_H

#include <iostream>
#include <sstream>
#include <algorithm>
#include <map>
#include <typeinfo>

using namespace std;

#include "nodes.h"


class EvalVisitorImpl
	{
public:
	EvalVisitorImpl()
		:value(0)
		{}
	
	void doVisit(Node * n){}
		
	void pop2andPush(float v)
		{
		value.pop_back();
		value.back() = v;
		}
	
	void doVisit(Float * f)
		{
		value.push_back(0);
		istringstream str(f->value);
		str >> value.back();
		}
	
	void doVisit(Integer * f)
		{
		int i = 0;
		istringstream str(f->value);
		str >> i;
		value.push_back(i);
		}
	
	template<typename OP>
	void binaryOp(OP op)
		{
		pop2andPush(op(*(value.end()-1), *(value.end()-2)));
		}
	
	void doVisit(Add * a)
		{
		binaryOp(plus<float>());
		}

	void doVisit(Mul * a)
		{
		binaryOp(multiplies<float>());
		}

	void doVisit(Sub * a)
		{
		binaryOp(minus<float>());
		}

	void doVisit(Div * a)
		{
		binaryOp(divides<float>());
		}

	void doVisit(Mod * a)
		{
		binaryOp(multiplies<float>());
		}
	
	void doVisit(Neg * a)
		{
		value.back() = -value.back();
		}

	void doVisit(CTuple * p)
		{
		for (int i=0; i<value.size(); i++)
			cout << value[i] << "\n";
		}
	
	void doVisit(Assign * a)
		{
		if (variables.find(((Name *)(a->left))->value) == variables.end())
			{
			cerr << "Error! Variable " << ((Name *)(a->left))->value 
				<< " undefined!\n";
			exit(1);
			}
		
		variables[((Name *)(a->left))->value] = value.back();
		value.pop_back();
		}
	
protected:
	vector<float> value;
	map<string, float> variables;
	};
typedef CVisitor<EvalVisitorImpl> EvalVisitor;
	
		
class PrintVisitorImpl
	{
public:
	void doVisit(Node * n)
		{
		cout << typeid(*n).name() << " ";
		}
	
	void doVisit(Name * n)
		{
		cout << n->value << " ";
		}
	
	void doVisit(Number * f)
		{
		cout << f->value << " ";
		}
	
	void doVisit(Assign * a)
		{
		cout << typeid(*a).name() << endl;
		}
	};
typedef CVisitor<PrintVisitorImpl> PrintVisitor;
	
class TraverseDepthImpl
	{
protected:
	Visitor * _visitor;
	Visitor * _self;

public:
	TraverseDepthImpl(Visitor * visitor=0)
		:_visitor(visitor)
		{}
	
	void setVisitor(Visitor * visitor)
		{
		_visitor = visitor;
		}
	void traverse(Node * node, Visitor * self)
		{
		_self = self;
		node->accept(self);
		}
	
	void doVisit(Node * node)
		{
		node->accept(_visitor);
		}
	
	void doVisit(Assign * node)
		{
		node->left->accept(_self);
		node->right->accept(_self);
		node->accept(_visitor);		
		}
	
	void doVisit(Unary * node)
		{
		node->child->accept(_self);
		node->accept(_visitor);
		}

	void doVisit(Binary * node)
		{
		node->left->accept(_self);
		node->right->accept(_self);
		node->accept(_visitor);
		}
	
	void doVisit(Nary * node)
		{
		for (unsigned i=0; i<node->children.size(); i++)
			node->children[i]->accept(_self);
		node->accept(_visitor);
		}
	};

typedef CVisitor<TraverseDepthImpl> TraverseDepth;

#endif	//VISITOR_H
