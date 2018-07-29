#ifndef ISA_H
#define ISA_H

// *** definitions

template<class T, class VT>
bool isa(VT * v)
	{
//	cerr << typeid(*v).name()<<endl;
//	cerr << typeid(T).name()<<endl;
	return typeid(*v) == typeid(T);
	}

template<class T, class VT>
bool isa(VT & v)
	{
	return typeid(v) == typeid(T);
	}

template<class T>
const char * type_str(T * v)
	{
	return typeid(*v).name();
	}

template<class T>
const char * type_str(T & v)
	{
	return typeid(v).name();
	}


//#define ISA(var, type) (typeid(var) == typeid(type))
//#define ISAp(var, type) (typeid(*(var)) == typeid(type))
//#define TYPE_STR(var) (typeid(var).name())
//#define TYPE_STRp(var) (typeid(*(var)).name())

#endif	//ISA_H