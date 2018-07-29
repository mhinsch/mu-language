#include "visitorfw.h"

class RubyVisitorImpl
	{
protected:
	Visitor * _self;
	int count;

public:
	TraverseDepthImpl()
		:_visitor(0)
		{
		count = 0;
		}
	
	void traverse(Node * node, Visitor * self)
		{
		_self = self;
		node->accept(self);
		}
	
	void doVisit(Node * node)
		{
		}
		
	void doVisit(Unary * node)
		{
		node->child->accept(_self);
		count++;
		cout << "node_" << count << " = Unary.new(node_" << count-1 << ")\n";
		}

	void doVisit(Binary * node)
		{
		node->left->accept(_self);
		int count_first = count;
		node->right->accept(_self);
		count++;
		cout << "node_" << count << " = Binary.new(node_" << count_first << 
			", node_" << count-1 << ")\n";
		}
	
	void doVisit(Nary * node)
		{
		// !!!TODO!!! build a vector of numbers
		for (unsigned i=0; i<node->children.size(); i++)
			node->children[i]->accept(_self);
		cout << "node_" << count << " = Nary.new("
		}

	void doVisit(Name * n)
		{
		count++;
		cout << "node_" << count << " = Term.new(\"" << 
			n->value << "\")\n";
		}
	
	void doVisit(Number * f)
		{
		count++;
		cout << "node_" << count << " = Term.new(\"" << 
			n->value << "\")\n";
		}
	
	};

typedef CVisitor<RubyVisitorImpl> RubyVisitor;
