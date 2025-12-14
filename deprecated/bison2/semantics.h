#ifndef	SEMANTICS_H
#define SEMANTICS_H

#include <set>

#include "isa.h"

struct Symbol;
	
struct Type
	{
	string name;
	
	virtual ~Type() {};	// we need RTTI
	};

class Scope;

struct Symbol
	{
	string name;
	Type * type;
	Node * decl;
	Node * ini;
	Scope * scope;
	};

struct RawType : public Type
	{
	Node * node;
	};
	
// int, float, etc.
struct AtomicType : public Type
	{
	};

struct TupleType : public Type
	{
	vector<Type *> elems;
	};

struct FunctionType : public Type
	{
	Type * in;
	Type * out;
	};

class Scope
	{
protected:
	typedef map<string, Symbol> SymList;
	SymList _symbols;
	vector<Symbol *> _declOrder;
	
	Scope * _super;
	Node * _node;

public:
	Scope(Node * node = 0, Scope * super=0)
		: _node(node), _super(super)
		{}
	
	Scope * super()
		{
		return _super;
		}
	
	Scope * top()
		{
		if (_super == 0)
			return this;
		else
			return _super->top();
		}
	
	void addDeclaration(As * decl, Node * ini = 0)
		{		
		if (!isa<Name>(decl->left))
			{
			cerr << "line " << decl->line << ": NOT IMPLEMENTED: implicit types\n";
			exit(1);
			}
		// at this point decl->left has to be a name
		string name = ((Name*)(decl->left))->getValue();

		Node * type = decl->right;
		
		if (isa<Empty>(type) && ini == 0)
			{
			cerr << "line " << decl->line << ":\nerror: declaration needs to provide either a type";
			cerr << " or an initializing expression\n";
			exit(1);
			}
		
		addSimpleSymbol(decl, name, decl->right, ini);
		}
	
	void addSimpleSymbol(Node * decl, const string & name, Node * type, Node * ini)
		{		
//		cout << _node->line << "\t" << name << endl;
		
		if (_symbols.count(name) > 0)
			{
			cerr << "error: multiple definition of symbol " << name << "\n";
			cerr << "lines: " << _symbols[name].decl->line << " and " << 
				decl->line << endl;
			exit(1);
			}
		
		Symbol symbol = {name, 0, decl, ini, this};
		RawType * rt = new RawType;
		rt->node = type;
		symbol.type = rt;
		
		_symbols[name] = symbol;
		_declOrder.push_back(&(_symbols[name]));
		}
	
	void printSymbols()
		{
		for (SymList::iterator i=_symbols.begin(); i!=_symbols.end(); i++)
			cout << i->first << " ";
		}
	
/*	Operator * match(string opName, Type * argType)
		{
		}*/
	};

class Builtin : public Scope
	{
protected:
	Type _IntT, _FloatT, _StringT;
	
public:
	Builtin()
		{
		}
	};

extern Scope builtin;

#endif	//SEMANTICS_H
