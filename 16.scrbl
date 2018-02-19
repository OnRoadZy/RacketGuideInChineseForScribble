;16.scrbl
;16 宏（Macro）
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "guide-utils.rkt")

@title[#:tag "macros" #:style 'toc]{宏（macro）}

@deftech{宏（macro）}是一种语法表，它有一个关联的@deftech{转换器（transformer）}，它将原有的表@deftech{扩展（expand）}为现有的表。换句话说，宏是Racket编译器的扩展。@racketmodname[racket/base]和@racketmodname[racket]的大部分句法表实际上是宏，扩展成一小部分核心结构。

像许多语言一样，Racket提供基于模式的宏，使得简单的转换易于实现和可靠使用。Racket还支持任意的宏转换器，它在Racket中实现，或在Racket中的宏扩展变体中实现。

（对于自下而上的Racket宏的介绍，你可以参考：《@(hyperlink "http://www.greghendershott.com/fear-of-macros/" "宏的担忧")》）

@;------------------------------------
@local-table-of-contents[]

@;---------------------------------------
@include-section["16.01.scrbl"]
@include-section["16.02.scrbl"]