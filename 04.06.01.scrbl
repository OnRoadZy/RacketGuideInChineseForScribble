;04.06.01.scrbl
;4.6.1 平行绑定：let
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "guide-utils.rkt")

@title{平行绑定：let}

一个@racket[let]表绑定一组标识符，每个标识符都是某个表达式的结果，用于@racket[let]主体：

@specform[(let ([id expr] ...) body ...+)]{}

@racket[_id]绑定处于”平行”状态，即对于任何@racket[_id]，没有一个@racket[_id]绑定到右边的@racket[_expr]，但都可在@racket[_body]内找到。@racket[_id]必须被定义为彼此不同的形式。

@examples[
(let ([me "Bob"])
  me)
(let ([me "Bob"]
      [myself "Robert"]
      [I "Bobby"])
  (list me myself I))
(let ([me "Bob"]
      [me "Robert"])
  me)
]

事实上，一个@racket[_id]的@racket[_expr]不会明白自己的绑定通常对封装有用，必须转回到旧的值：

@interaction[
(let ([+ (lambda (x y)
           (if (string? x)
               (string-append x y)
               (+ x y)))]) (code:comment @#,t{use original @racket[+]})
  (list (+ 1 2)
        (+ "see" "saw")))
]