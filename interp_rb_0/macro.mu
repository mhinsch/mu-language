{

;; some syntactic sugar
$replace' [$pattern :=> $replacement], [$replace' \$pattern, \$replacement]

;; we don't want to have to quote the lhs of definitions and assignments, so
;; we use some macros to make things nicer.

;; a few special cases of definitions
;; these need to be captured first to disambiguate them from function calls

;; tuple on LHS of definition
;; as long as , is a fn call this needs to be captured first
;; $:... is special-cased in the parser atm, needs a better solution
[$:tuple1 $args__ : $val] :=> [$defvar' [\$args__], \$val]
;; mutable variables
;; ref doesn't evaluate, so this is fine
[$var! : $val] :=> [$defvar' [\$var], \$val, 0]

;; function calls

;; strictly plain functions, no overloading etc.
;; $0, $1, ... are always defined, but we want to use named args
[$fname $args_ : $block] :=> [ $defsfun' [\$fname], { \$args_ : $0 } => \$block ]

;; overloading
;; with a bit of reflection match should be implementable as a regular function

[$fname $args_ :: $block] :=> 
	[ 
	$addpattern' [\$fname], [\$args_], { \$args_ : $0 } => \$block
	[ \$fname $callargs_ ] :=> [ match([\$fname], [\\$callargs_])' \\$callargs_ ] 
	]

[$var!] :=> [$mut [\$var]]

;; finally, this is the plain definition
[$var : $val] :=> [$defvar' [ \$var ], \$val] 
;; plain assignment
[$lhs = $rhs] :=> [$assign' \$lhs!, \$rhs]
;; static index needs a symbol or a statically evaluatable expression
[$expr.$idx] :=> [$index' \$expr, [\$idx]]



a : 1+5

b : (1, 2, 3)

c! : 0

c = b.1

d : (1, 2,* (3, 4),* (5, 6))

println d

log (x, y) :
	{	
	println $0
	println x
	println y
	}

log' a, b 

println x

;;println c

;;2+a*3

;;if' a==6,
;;	[ log "bla" ],
;;	[ println 111 ]

;;i : 1

;;while' [i<3],
;;	[
;;	println "loop"
;;	println i
;;	i = i + 1
;;	]
}
