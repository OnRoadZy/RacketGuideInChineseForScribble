;05.02.scrbl
;5.2 复制和更新
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          scribble/bnf
          "guide-utils.rkt"
          (for-label racket/dict racket/serialize))

@(define posn-eval (make-base-eval))

@title[#:tag "struct-copy"]{复制和更新}

@racket[struct-copy]复制一个结构并可选地更新克隆中的指定字段。这个过程有时称为@deftech{功能性更新（functional update）}，因为结果是一个具有更新字段值的结构。但原来的结构没有被修改。

@specform[
(struct-copy struct-id struct-expr [field-id expr] ...)
]

出现在@racket[struct-copy]后面的@racket[_struct-id]必须是由@racket[struct]绑定的结构类型名称（即这个名称不能作为一个表达式直接被使用）。@racket[_struct-expr]必须产生结构类型的一个实例。结果是一个新实例，就像旧的结构类型一样，除这个被每个@racket[_field-id]标明的字段得到相应的@racket[_expr]的值之外。

@examples[
#:eval posn-eval 
(define p1 (posn 1 2))
(define p2 (struct-copy posn p1 [x 3]))
(list (posn-x p2) (posn-y p2))
(list (posn-x p1) (posn-x p2))
]

@close-eval[posn-eval]