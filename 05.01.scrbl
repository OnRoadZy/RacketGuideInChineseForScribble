;05.01.scrbl
;5.1 简单的结构类型：struct
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          scribble/bnf
          "guide-utils.rkt"
          (for-label racket/dict racket/serialize))

@(define posn-eval (make-base-eval))

@title{简单的结构类型：struct}

一个最接近的，@racket[struct]的语法是

@specform[
(struct struct-id (field-id ...))
]{}

@as-examples[@racketblock+eval[
#:eval posn-eval
(struct posn (x y))
]]

@racket[struct]表将@racket[_struct-id]和从@racket[_struct-id]和@racket[_field-id]构建的数值标识符绑定在一起：

@itemize[

@item{@racket[_struct-id]：一个@deftech{构造函数（constructor）}，它将一些参数作为@racket[_field-id]的数值，并返回结构类型的一个实例。

@examples[#:eval posn-eval (posn 1 2)]}

@item{@racket[_struct-id]@racketidfont{?}：一个@deftech{判断函数（predicate）}，它获取单个参数，如果它是结构类型的实例返回@racket[#t]，否则返回@racket[#f]。

@examples[#:eval posn-eval (posn? 3) (posn? (posn 1 2))]}

@item{@racket[_struct-id]@racketidfont{-}@racket[_field-id]：每个@racket[_field-id]，@deftech{访问器（accessor）}从结构类型的一个实例中解析相应的字段值。

@examples[#:eval posn-eval 
                 (posn-x (posn 1 2)) (posn-y (posn 1 2))]}

@item{@racketidfont{struct:}@racket[_struct-id]：一个@deftech{结构类型描述符（structure type descriptor）}，这是一个值，它体现结构类型作为第一类值（与@racket[#:super]和《@secref["struct-options"]》一起作为后续讨论）。}

]

一个@racket[struct]表不限制在结构类型的实例中可以出现的字段的值类型。例如，@racket[(posn "apple" #f)]过程产生一个@racket[posn]实例，即使@racket["apple"]和@racket[#f]对@racket[posn]的实例的显性使用是无效的配套。执行字段值的约束，比如要求它们是数字，通常是合约的工作，如后面讨论的《@secref["contracts"]》那样。

@close-eval[posn-eval]