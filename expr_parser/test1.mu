{
;; Note:
;; Make closures explicit, i.e.:
;; - [] has lexical scope but *can't* be assigned, copied or returned (-> type system),
;;   only moved or executed
;; - {} has dynamic scope and can be assigned, but any closing over external variables
;;   has to be made explicit
;; Then function arguments and closed over variables become very similar and should have
;; similar syntax.


x : I (,)
Bla :: {x : I, y : F}
z : Bla


a : 1+5

log :
	{	
	;;println $0
	}

2+a*3

if' a==6,
	[
	log "bla"
	],
	[
	println 111
	]

i : 1

while' [i<3],
	[
	log "loop"
	log i
	i = i + 1
	]
}
