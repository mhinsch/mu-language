{
;; Note:
;; Make closures explicit, i.e.:
;; - [] has lexical scope but *can't* be assigned, copied or returned (-> type system),
;;   only moved or executed
;; - {} has dynamic scope and can be assigned, but any closing over external variables
;;   has to be made explicit
;; Then function arguments and closed over variables become very similar and should have
;; similar syntax.


;;[f args : block ] :=> [ $defvar' \f, [ \args : $0 ] => \block ]
[$fn $args_ : $block ] :=> [ $defvar' \$fn, [ $0 : \$args ] => \$block ]

[$var : $val] :=> [$defvar' [ \$var ], \$val] 

[$lhs = $rhs] :=> [$assign' [ \$lhs ], \$rhs]

a : 1+5

b : (1, 2, 3)

c : 0

c = b#1

log :
	{	
	;;println $0
	}

2+a*3

if' a==6,
	[ println "bla" ],
	[ println 111 ]

i : 1

while' [i<3],
	[
	println "loop"
	println i
	i = i + 1
	]
}
