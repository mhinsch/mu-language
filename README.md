# Mu

BEWARE: Mu is not finished or even usable yet (by a long shot). It is also (so far) strictly a personal hobby project.

Mu is intended to become a
language with a tiny generic core that is powerful enough to implement the features I am looking for in a language. At this point it
is as much experiment and learning experience as language implementation.

Features I would like it to have (most of which are not implemented or even designed yet):

* strong, static typing
* aot compilation
* value semantics
* zero cost abstractions
* multiple dispatch
* strong macro system
* simple, unambiguous syntax
* multiple memory models (gc, ownership/borrowing, RAII)
* capabilities/effects
* ...

Maybe think of Mu as a statically typed cross between Lisp (sans the parentheses) and C++ that also had some encounters with a.o. TCL, Red, Julia and Rust


## Concepts

A few concepts that are important for mu, in no particular order. Note that all syntax is potentially subject to change.

### Consistency and orthogonality

I am trying to make mu as consistent and orthogonal as possible. There are admittedly not really any good practical reasons for this. We seem to be totally fine with our messy natural languages and even mathematical notation relies a lot on context to disambiguate between potential interpretations. The language I'm using for most of my work at the moment - Julia - has a syntax that is a lot more consistent than let's say C++, but it still heavily re-uses symbols and even syntactic constructs. Nevertheless I never had any issues reading Julia code. So, this is probably mostly a point of personal aesthetics. 

### Bicameral syntax

I always found the concept of homoiconicity a bit dodgy, but [this](https://parentheticallyspeaking.org/articles/bicameral-not-homoiconic/) very nice blog post by Shriram Krishnamurthi finally made it make sense. When I read it I realised that this was exactly what I was trying to do with mu. 

Mu has a very simple pre-defined syntax consisting only of binary and unary operator expressions plus a few types of brackets. The basic parser can therefore be very simple and, apart from operator precedence, doesn't encode any semantic information.

Similar to Lisp, only a small subset of syntactically valid mu programs is semantically valid, however. For example, the definition operator `:` (currently) requires either a symbol, a tuple of symbols or a function call expression (with additional, more complicated constraints) as a first argument.

### Explicit evaluation

Most languages eagerly evaluate expressions and special-case some constructs or functions whose arguments are left as is. In ALGOL-type languages, for example, constructs like `if` or `while` do not evaluate their code bodies (nor the condition in the case of while) before the construct itself is invoked. This is usually built into the syntax of the language itself. Lisps are a bit more principled and make no surface-level distinction between ordinay function calls and those that do not evaluate their arguments (special forms - IMHO this is one of the reasons why Lisps are so hard to read). The distinction still exists, though, and special forms still need to be special-cased in the compiler/interpreter.

In mu the distinction between evaluation and quotation is explicit. Two types of brackets '{}' and '[]' quote their content (they differ in how they handle scope). I decided that having to do this everywhere would actually be too annoying in practice, however, (for example the LHS of declarations or assignments would always have to be quoted as would be any reference) so for a few cases I use AST macros to translate an unquoted into a quoted form.

For example this translates the definition operator into a call to the built-in function `$defvar`, in the process quoting its first argument.
```
[$var : $val] :=> [$defvar' [ \$var ], \$val] 
```

Note, though, that these macros are part of the program and completely optional.

### Multiple dispatch

After years of using Julia the idea of blessing the first argument of a function with a special role just feels wrong, so multiple dispatch it is. I think it does have practical advantages, although it has been overhyped (substantially) in the Julia community in my opinion.

Static multiple dispatch is easy (and quite a few languages do it), but *efficient* runtime multiple dispatch (i.e. runtime polymorphism that includes more than one argument) is hard (and no, Julia has definitely not solved this one). I think I have an idea how to do it, but it's going to be a while before that becomes relevant.


### Pattern matching

There is some overlap with the previous point. Essentially languages with static, type-based overloading, like C++, implement a limited form of compile time pattern matching. I want to have reified compile time patterns and pattern matching in mu, so that function calls are just a special case with a nice syntax. Unsurprisingly I'm not the first one to have this idea (I know of at least one language that uses pattern matching for function calls and one that has first-class patterns (I'll dig up the links at some point)); I did come up with it on my own, though.

I'm a bit concerned that this might end up being one of those features that make it very easy to write incomprehensible code (like macros) without (unlike macros) providing a lot of benefits in return, but we'll see.


## Roadmap

### interpreter mu_0 (Ruby)

* [x] tokeniser
* [x] parser
* [x] uniform AST
* [x] basic arithmetic
* [x] tuples
* [x] assignments
* [x] variable declarations
* [x] \(executable) code blocks
* [x] if, while
* [x] nested static scopes
* [x] pattern-based AST macros
* [x] simple (non-overloaded) functions
	* [x] automatic parameters ($0, ...)
	* [x] user-named parameters
* [ ] constness
* [ ] types
* [ ] simple static overloading
* [ ] compound types
* [ ] basic library functions

### compiler mu_0 -> C (mu_0)

* [ ] all of mu_0
	* [ ] tokeniser
	* [ ] parser
	* ...

### compiler mu_1 -> C (mu_0)

* [ ] modules
* [ ] run-time polymorphism
* [ ] compile-time vs. run-time
* ...

### compiler mu_1 -> C (mu_1)

* ...

### interpreter mu_1 (mu_1)

* ...

## History

This project started (as so many) out of a deep frustration with the eldritch abomination that is C++. 
Its vast collection of features that can interact in subtle, arcane ways while at the same time not providing many of the amenities of more modern languages makes
it easy to forget that at its core C++ is based on a very elegant idea: Pay only for what you use, reduce all complexity at compile time to (relatively) straighforward 
run-time semantics. 

My initial idea was to build an alternative to C++ that kept the core principles - value semantics, static typing, generics, zero-cost abstractions - 
but a) throw away all the unnecessary complecity and b) make it *consistent*. I kept tinkering with that on and off until two things happened:

* Julia
* Rust

This took away a large part of the motivation for the project. Julia is so much easier, more powerful and more productive than C++, 
that I happily pay the 10%-50% runtime overhead. I switched to Julia full-time in 2018 and it's been a joy ever since. Rust on the 
other hand essentially fills the C++-but-better niche.

At the same time I realised that I had long since moved away from my original aim anyway. It turned out what I was *actually* trying to do, was to
find a minimal core that a language like C++ or Rust could be built from. At this point I also had learned *a lot* more about programming languages and 
noticed that spiritually languages like Lisp, TCL or Red were much closer to my ideas than C++.

Over the years I went through various aborted attempts to write a compiler or interpreter for mu (along with changes in the language itself, as well as its name), but I think enough parts of the language and the concepts behind it have now crystallised in my mind that this is actually going to go somewhere. 
