{
;; Note:
;; Make closures explicit, i.e.:
;; - [] has lexical scope but *can't* be assigned, copied or returned (-> type system),
;;   only moved or executed
;; - {} has dynamic scope and can be assigned, but any closing over external variables
;;   has to be made explicit
;; Then function arguments and closed over variables become very similar and should have
;; similar syntax.


;; some syntactic sugar
$replace' [$pattern :=> $replacement], [$replace' \$pattern, \$replacement]

;; we don't want to have to quote the lhs of definitions and assignments, so
;; we use some macros to make things nicer.

;; as long as , is a fn call this needs to be captured first
[$:tuple1 $args_ : $val] :=> [$defvar' [\$args_], \$val]
;; strictly plain functions, no overloading etc.
;; $0, $1, ... are always defined, but we want to use named args
[$fname $arg : $block] :=> [ $defsfun' [\$fname], { \$arg : $0 } => \$block ]
[$fname $args_ : $block] :=> [ $defsfun' [\$fname], { \$args_ : $0 } => \$block ]

;; some sugar
[$var : $val] :=> [$defvar' [ \$var ], \$val] 
[$lhs = $rhs] :=> [$assign' [ \$lhs ], \$rhs]

a : 1+5

b : (1, 2, 3)

c : 0

c = b#1

d : (1, 2,..(3, 4),..(5, 6), 7)

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
