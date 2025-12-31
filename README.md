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
