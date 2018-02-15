;02.02.03.scrbl
;2.2.3 标识符
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          scribble/bnf
          "guide-utils.rkt")

@title[#:tag "identifiers"]{标识符}

Racket的标识符语法特别自由。不含特殊字符。

@t{
 @hspace[2] @litchar{(} @litchar{)} @litchar{[} @litchar{]}
 @litchar["{"] @litchar["}"]
 @litchar{"} @litchar{,} @litchar{'} @litchar{`}
 @litchar{;} @litchar{#} @litchar{|} @litchar{\}}

除了文字，使常数数字序列，几乎任何非空白字符序列形成一个@nonterm{ID}。例如，@racketid[substring]是一个标识符。另外，@racketid[string-append]和@racketid[a+b]是标识符，而不是算术表达式。这里还有几个例子：

@racketblock[
@#,racketid[+]
@#,racketid[Hfuhruhurr]
@#,racketid[integer?]
@#,racketid[pass/fail]
@#,racketid[john-jacob-jingleheimer-schmidt]
@#,racketid[a-b-c+1-2-3]]