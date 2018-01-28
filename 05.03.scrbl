;05.03.scrbl
;5.3 结构子类
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          scribble/bnf
          "guide-utils.rkt"
          (for-label racket/dict racket/serialize))

@(define posn-eval (make-base-eval))

@title[#:tag "struct-subtypes"]{结构子类}

@racket[struct]的扩展表可以用来定义@defterm{结构子类型（structure subtype）}，它是一种扩展现有结构类型的结构类型：

@specform[
(struct struct-id super-id (field-id ...))
]

这个@racket[_super-id]必须是由@racket[struct]绑定的结构类型名称（即名称不能被作为表达式直接使用）。

@as-examples[@racketblock+eval[
#:eval posn-eval 
(struct posn (x y))
(struct 3d-posn posn (z))
]]

一个结构子类型继承其超类型的字段，并且子类型构造器接受这个值作为子类型字段在超类型字段的值之后。一个结构子类型的实例可以被用作这个超类型的断言和访问器。

@examples[
#:eval posn-eval 
(define p (3d-posn 1 2 3))
p
(posn? p)
(3d-posn-z p)
(code:comment "3d-posn有一个x字段，但是这里却没有3d-posn-x选择器：")
(3d-posn-x p)
(code:comment "使用基类型的posn-x选择器去访问x字段：")
(posn-x p)
]

@close-eval[posn-eval]