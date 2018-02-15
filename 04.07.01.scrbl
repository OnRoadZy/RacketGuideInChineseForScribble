;04.07.01.scrbl
;4.7.1 简单分支：if
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "guide-utils.rkt")

@title[#:tag "simple-branching-if"]{简单分支：@racket[if]}

在@racket[if]表：

@specform[(if test-expr then-expr else-expr)]

@racket[_test-expr]总是求值。如果它产生任何非@racket[#f]值，然后对@racket[_then-expr]求值。否则，@racket[_else-expr]被求值。

@racket[if]表必须既有一个@racket[_then-expr]也有一个@racket[_else-expr]；后者不是可选的。执行（或跳过）基于一个@racket[_test-expr]的副作用，使用@racket[when]或@racket[unless]，将在后边《顺序》（@secref["begin"]）部分描述。