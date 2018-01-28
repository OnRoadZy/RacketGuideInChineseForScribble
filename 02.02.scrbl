;02.02.scrbl
;2.2 简单的定义与表达式
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          scribble/bnf
          "guide-utils.rkt")

@title{简单的定义与表达式}

一个程序模块一般被写作：

@racketblock[
             @#,BNF-seq[@litchar{#lang}
                        @nonterm{langname}
                        @kleenestar{@nonterm{topform}}]]

@nonterm{topform}既是一个@nonterm{definition}也是一个@nonterm{expr}。@tech{REPL}也对@nonterm{topform}求值。

在语法规范里，文本使用灰色背景，比如@litchar{#lang}，代表文本。文本与非结束符（像@nonterm{ID}）之间必须有空格，除了@litchar{(}、@litchar{)}及@litchar{[}、@litchar{]}之前或之后不需要空格。注释以@litchar{;}开始，直至这一行结束，空白也做相同处理。

《Racket参考》中提供了更多不同的注释形式。

后边遵从如下惯例：@kleenestar{}在程序中表示零个或多个前面元素的重复，@kleeneplus{}表示前一个或多个前面元素的重复，@BNF-group{} 组合一个序列作为一个元素的重复。

@include-section["02.02.01.scrbl"]
@include-section["02.02.02.scrbl"]
@include-section["02.02.03.scrbl"]
@include-section["02.02.04.scrbl"]
@include-section["02.02.05.scrbl"]
@include-section["02.02.06.scrbl"]
@include-section["02.02.07.scrbl"]
@include-section["02.02.08.scrbl"]
