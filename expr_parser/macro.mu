{
;; Note:
;; Make closures explicit, i.e.:
;; - [] has lexical scope but *can't* be assigned, copied or returned (-> type system),
;;   only moved or executed
;; - {} has dynamic scope and can be assigned, but any closing over external variables
;;   has to be made explicit
;; Then function arguments and closed over variables become very similar and should have
;; similar syntax.


$replace' [$pattern :=> $replacement], [$replace' \$pattern, \$replacement]

;; TODO args needs to be splatted
[($arg, $args_) : $val] :=> [$defvar' [\$arg, \$args_], \$val]
;; strictly plain functions, no overloading etc.
;; we special-case the definition for now
[$fn $arg : $block] :=> [ $defsfun' [\$fn], { \$arg : $0 } => \$block ]
[$fn $args_ : $block] :=> [ $defsfun' [\$fn], { \$args_ : $0 } => \$block ]

[$var : $val] :=> [$defvar' [ \$var ], \$val] 
[$lhs = $rhs] :=> [$assign' [ \$lhs ], \$rhs]

a : 1+5

b : (1, 2, 3)

c : 0

c = b#1

log (x, y) :
	{	
	println $0
	println $1
	println $2
	}

log' a, c 

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
