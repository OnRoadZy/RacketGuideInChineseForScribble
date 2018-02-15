;04.03.scrbl
;4.3 函数调用（过程程序）
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "guide-utils.rkt")

@title[#:tag "application"]{函数调用）@aux-elem{（过程程序）}}

一个表表达式：

@specsubform[
(proc-expr arg-expr ...)
]

是一个函数调用——也被称为一个@defterm{应用程序（procedure
application）}——@racket[_proc-expr]不是标识符，而是作为一个语法翻译器（如@racket[if]或@racket[define]）。