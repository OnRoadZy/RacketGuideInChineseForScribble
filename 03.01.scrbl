;03.01.scrbl
;3.1 布尔值（Boolean）
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "guide-utils.rkt")

@title[#:tag "booleans"]{布尔值（Boolean）}

Racket有表示布尔值的两个常数：@racket[#t]表示真，@racket[#f]表示假。大写的@racketvalfont{#T}和@racketvalfont{#F}在语法上描述为同样的值，但小写形式是首选。

@racket[boolean?]过程识别两个布尔常量。然而，在对@racket[if]、@racket[cond]、 @racket[and]、@racket[or]等等的测试表达式的结果里，除了@racket[#f]外，任何值都是记为真。

@examples[
 (= 2 (+ 1 1))
 (boolean? #t)
 (boolean? #f)
 (boolean? "no")
 (if "no" 1 0)]