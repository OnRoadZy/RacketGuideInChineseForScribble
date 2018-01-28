;02.02.06.scrbl
;2.2.6 函数重复调用
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          scribble/bnf
          "guide-utils.rkt")

@(define app2-expr-stx
   @BNF-seq[@litchar{(}
            @nonterm{expr}
            @kleenestar{@nonterm{expr}}
            @litchar{)}])

@title{函数重复调用}

在我们早期的函数语法调用，我们是过分简单化的。一个函数调用的语法允许任意的函数表达式，而不是一个@nonterm{ID}：

@racketblock[
 #,app2-expr-stx]

第一个@nonterm{expr}常常是一个@nonterm{id}，比如@racket[string-append]或@racket[+]，但它可以是对一个函数的求值的任意情况。例如，它可以是一个条件表达式：

@def+int[
(define (double v)
  ((if (string? v) string-append +) v v))
(double "mnah")
(double 5)
]

在语法上，在一个函数调用的第一个表达甚至可以是一个数——但那会导致一个错误，因为一个数不是一个函数。

@interaction[(1 2 3 4)]

当您意外地忽略函数名或在表达式中使用额外的括号时，你通常会得到像这样“expected a procedure”的错误。