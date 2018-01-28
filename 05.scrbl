;05.scrbl
;5 自定义的数据类型
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          scribble/bnf
          "guide-utils.rkt"
          (for-label racket/dict racket/serialize))

@title[#:tag "define-struct"]{自定义的数据类型}

新的数据类型通常用@racket[struct]表来创造，这是本章的主题。基于类的对象系统，我们参照《@secref["classes"]》，它提供了用于创建新的数据类型的另一种机制，但即使是类和对象也是结构类型的实现方式。

@include-section["05.01.scrbl"]
@include-section["05.02.scrbl"]
@include-section["05.03.scrbl"]
@include-section["05.04.scrbl"]
@include-section["05.05.scrbl"]
@include-section["05.06.scrbl"]
@include-section["05.07.scrbl"]
@include-section["05.08.scrbl"]
