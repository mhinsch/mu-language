#ifndef SIMPLE2C_H
#define SIMPLE2C_H

#include <typeinfo>
#include <map>

using namespace std;

#include "visitor.h"
#include "support.h"

class Simple2CVisitorImpl
	{
protected:
	struct Operator
		{
		Operator() {}
		Operator(string o, int p)
			{
			op = o;
			pref = p;
			}
		
		string op;
		int pref;
		};
	
	map<string, Operator> ops;
	Visitor * _self;
	int _indent;
	bool _suppressSC;
	vector<Scope> _scopeStack;
	
public:
	Simple2CVisitorImpl()
		:_indent(-1), _suppressSC(false)
		{
		ops[typeid(Assign).name()] = Operator("=", 1);
		ops[typeid(As).name()] = Operator("", 2);
		ops[typeid(LOr).name()] = Operator("||", 3);
		ops[typeid(LAnd).name()] = Operator("&&", 4);
		ops[typeid(Equal).name()] = Operator("==", 5);
		ops[typeid(Uneq).name()] = Operator("!=", 5);
		ops[typeid(LowT).name()] = Operator("<", 7);
		ops[typeid(GreT).name()] = Operator(">", 7);
		ops[typeid(LowTEq).name()] = Operator("<=", 7);
		ops[typeid(GreTEq).name()] = Operator(">=", 7);
		ops[typeid(Add).name()] = Operator("+", 9);
		ops[typeid(Sub).name()] = Operator("-", 9);
		ops[typeid(Mul).name()] = Operator("*", 10);
		ops[typeid(Div).name()] = Operator("/", 10);
		ops[typeid(Mod).name()] = Operator("%", 10);		
		ops[typeid(Neg).name()] = Operator("-", 12);
		ops[typeid(LNot).name()] = Operator("!", 12);
		ops[typeid(FCall).name()] = Operator("", 15);
		ops[typeid(Subscript).name()] = Operator("", 15);
		ops[typeid(Pow).name()] = Operator("", 15);
		ops[typeid(Float).name()] = Operator("", 20);
		ops[typeid(Integer).name()] = Operator("", 20);
		ops[typeid(Name).name()] = Operator("", 20);
		ops[typeid(CTuple).name()] = Operator("", 20);
		}
		
	void testValid(Node * n)
		{	
		if (!ops.count(typeid(*n).name()))
			{
			cerr << "line " << n->line << ": unknown operator: " << typeid(*n).name() << endl;
			exit(1);
			}
		}
	
	void setSelf(Visitor * self)
		{
		_self = self;
		}
		
	bool lower(Node * c, Node * p)
		{
		return !ops.count(typeid(*p).name()) || !ops.count(typeid(*c).name()) ||
			ops[typeid(*p).name()].pref > ops[typeid(*c).name()].pref;
		}
	
	void doVisit(Empty * e)
		{
//		cout << "";
		}
	
	void doVisit(Name * t)
		{
		cout << t->value;
		}
	
	void doVisit(String * t)
		{
		cout << t->value;
		}
	
	void doVisit(Number * n)
		{
		cout << n->value;
		}
	
	void doVisit(Pow * p)
		{
		cout << "pow(";
		p->left->accept(_self);
		cout << ", ";
		p->right->accept(_self);
		cout << ")";
		}
	
	void doVisit(FCall * f)
		{
		if (isa<Name>(f->left))
			{
			
			}
		
		f->left->accept(_self);
		cout << "(";
		f->right->accept(_self);
		cout << ")";
		}
	
	void doVisit(Subscript * s)
		{
		s->left->accept(_self);
		cout << "[";
		s->right->accept(_self);
		cout << "]";
		}
	
	void printIndent()
		{
		for (int in=0; in<_indent*4; in++)
			cout << ' ';
		}
	
	void doVisit(CTuple * ct)
		{
		_indent ++;
		// check for toplevel
		if (_indent>0)
			{
			printIndent();
			cout << "{\n";
			}
		
		for (int i=0; i<ct->children.size(); i++)
			{
			printIndent();	
			ct->children[i]->accept(_self);
			if (!_suppressSC)
				cout << ";\n";
			_suppressSC = false;
			}
		
		// check for toplevel
		if (_indent>0)
			{
			printIndent();	
			cout << "}\n";
			}
		_indent --;
		}
		
	void doVisit(Tuple * t)
		{
		for (int i=0; i<t->children.size()-1; i++)
			{
			t->children[i]->accept(_self);
			cout << ", ";
			}		
		t->children.back()->accept(_self);
		}
	
	void doVisit(As * a)
		{
		a->right->accept(_self);
		cout << " ";
		a->left->accept(_self);
		}
	
	void doVisit(Assign * a)
		{
		if (!isa<As>(a->left))
			{
			this->doVisit((Binary*)a);
			return;
			}
		
		Binary * l_as = (Binary*)(a->left);
		
		// inits of non-functions are fine
		if (!isa<FCall>(l_as->left))
			{
			this->doVisit((Binary*)a);
			return;
			}
		
		a->left->accept(_self);
		cout << '\n';
		a->right->accept(_self);
		_suppressSC = true;
		}
	
	void doVisit(Nary * n)
		{
		for (int i=0; i<n->children.size(); i++)
			{
			n->children[i]->accept(_self);
			cout << "\n";
			}
		}
	
	void doVisit(Binary * b)
		{
		testValid(b);
			
		bool parNeeded = lower(b->left, b) || lower(b->right, b); 
		
		if (parNeeded) cout << "(";	
		b->left->accept(_self);
		if (parNeeded) cout << ")";
		
		cout << ops[typeid(*b).name()].op;
		
		if (parNeeded) cout << "(";	
		b->right->accept(_self);
		if (parNeeded) cout << ")";
		}
		
	
	void doVisit(Unary * u)
		{
		testValid(u);
		
		bool parNeeded = lower(u, u->child);
		
		cout << ops[typeid(*u).name()].op;
		if (parNeeded) cout << "(";
		u->child->accept(_self);
		if (parNeeded) cout << ")";
		}
		
	};

typedef CVisitor<Simple2CVisitorImpl> Simple2CVisitor;

#endif	//SIMPLE2C_H
