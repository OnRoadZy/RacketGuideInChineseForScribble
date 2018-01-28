;04.06.05.scrbl
;4.6.5 多值绑定：let-values，let*-values，letrec-values
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "guide-utils.rkt")

@title{多值绑定：let-values，let*-values，letrec-values}

以@racket[define-values]同样的方式绑定定义的多个结果（见《多值和define-values》）（@secref["multiple-values"]），@racket[let-values]、@racket[let*-values]和@racket[letrec-values]值绑定多个局部结果。

@specform[(let-values ([(id ...) expr] ...)
            body ...+)]
@specform[(let*-values ([(id ...) expr] ...)
            body ...+)]
@specform[(letrec-values ([(id ...) expr] ...)
            body ...+)]

每个@racket[_expr]必须产生许多值作为@racket[_id]的对应。绑定的规则是和没有@racketkeywordfont{-values}的形式的表相同：@racket[let-values]的@racket[_id]只绑定在@racket[_body]里，@racket[let*-values]的@racket[_id]绑定在后面从句的@racket[_expr]里，@racket[letrec-value]的@racket[_id]绑定是针对对所有的@racket[_expr]。

@examples[
(let-values ([(q r) (quotient/remainder 14 3)])
  (list q r))
]