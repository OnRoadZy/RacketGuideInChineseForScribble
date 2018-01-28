;04.04.03.scrbl
;4.4.3 声明关键字（keyword）参数
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "guide-utils.rkt")

@(define greet-eval (make-base-eval))

@title{声明关键字（keyword）参数}

一个@racket[lambda]表可以声明要通过关键字传递的参数，而不是位置。关键字参数可以与位置参数混合，也可以为两种参数提供默认值表达式：

@specform/subs[
(lambda gen-formals
  body ...+)
([gen-formals (arg ...)
              rest-id
              (arg ...+ . rest-id)]
 [arg arg-id
      [arg-id default-expr]
      (code:line arg-keyword arg-id)
      (code:line arg-keyword [arg-id default-expr])])
]{}

由一个应用程序使用同一个@racket[(code:line _arg-keyword _arg-id)]关键字提供一个参数，该参数指定为@racket[_arg-keyword]。在参数列表中关键字标识符对的位置与应用程序中的参数匹配并不重要，因为它将通过关键字而不是位置与参数值匹配。

@def+int[
(define greet
  (lambda (given #:last surname)
    (string-append "Hello, " given " " surname)))

(greet "John" #:last "Smith")
(greet #:last "Doe" "John")
]

 @racket[(code:line _arg-keyword [_arg-id _default-expr])]参数指定一个带默认值的关键字参数。

@defexamples[
#:eval greet-eval
(define greet
  (lambda (#:hi [hi "Hello"] given #:last [surname "Smith"])
    (string-append hi ", " given " " surname)))

(greet "John")
(greet "Karl" #:last "Marx")
(greet "John" #:hi "Howdy")
(greet "Karl" #:last "Marx" #:hi "Guten Tag")
]

@racket[lambda]表不支持创建一个接受“rest”关键字的函数。要构造一个接受所有关键字参数的函数，请使用@racket[make-keyword-procedure]函数。这个函数支持@racket[make-keyword-procedure]通过前两个（位置）参数中的并行列表接受关键字参数，然后由应用程序的所有位置参数作为剩余位置参数。

@defexamples[
#:eval greet-eval
(define (trace-wrap f)
  (make-keyword-procedure
   (lambda (kws kw-args . rest)
     (printf "Called with ~s ~s ~s\n" kws kw-args rest)
     (keyword-apply f kws kw-args rest))))
((trace-wrap greet) "John" #:hi "Howdy")
]