#ifndef TREE_H
#define TREE_H

#include <string>
#include <vector>

#include "visitorfw.h"

using namespace std;

class Scope;
struct Type;

struct Node
	{
	Node(int l)
		: line(l){}
		
	int line;
	
	Scope * scope;
	Type * type;
	
	virtual void accept(Visitor * visitor) = 0;
	virtual ~Node(){}
	};

struct Empty : public Node
	{
	Empty(int l=-1)
		:Node(l){}
		
	void accept(Visitor * v)
		{v->visit(this);}
	};
	
struct Token
	{
	Token(const string & v)
		: value(v)
		{}
		
	const string & getValue() const
		{
		return value;
		}
	
	string value;
	};

struct Name : public Node, public Token
	{
	Name(const string & v, int l=-1)
		: Node(l), Token(v){}
	
	void accept(Visitor * v) {v->visit(this);}
	};

struct Term : Node
	{
	Term(int l=-1)
		: Node(l){}
	};

struct String : public Term, public Token
	{
	String(const string & v, int l=-1)
		: Term(l), Token(v)
		{}
	
	void accept(Visitor * v) {v->visit(this);}
	};

struct Unary : public Term
	{
	Unary(Node * c, int l=-1)
		:Term(l), child(c)
		{}
	
	~Unary()
		{
		delete child;
		}
		
	Node * child;
	};
	
struct Binary : public Term
	{
	Binary(Node * l, Node * r, int li=-1)
		: Term(li), left(l), right(r)
		{}

	~Binary()
		{
		delete left;
		delete right;
		}
		
	Node * left, * right;
	};

struct Nary : public Term
	{
	Nary(Node * child, int l=-1)
		: Term(l)
		{
		children.push_back(child);
		}
	
	Nary * append(Node * child)
		{
		children.push_back(child);
		return this;
		}
	
	~Nary()
		{
		for(int i=0; i<children.size(); i++)
			delete children[i];
		}

	vector<Node *> children;
	};


struct Cat : public Binary
	{
	Cat(Node * l, Node * r, int li=-1)
		:Binary(l, r, li)
		{}

	void accept(Visitor * v) {v->visit(this);}
	};



#endif	//TREE_H
