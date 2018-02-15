;02.02.04.scrbl
;2.2.4 函数调用(过程应用程序)
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          scribble/bnf
          "guide-utils.rkt")

@(define app-expr-stx
   @BNF-seq[@litchar{(}
            @nonterm{id}
            @kleenestar{
             @nonterm{expr}}
            @litchar{)}])

@title[#:tag "function-calls"]{函数调用(过程应用程序)}

我们已经看到过许多函数调用，更传统的术语称之为@defterm{过程应用程序}。函数调用的语法是：

@racketblock[
 #,app-expr-stx]

@nonterm{expr}决定了@nonterm{ID}命名函数提供的参数个数。

@racketmodname[racket]语言预定义了许多函数标识符，比如@racket[substring]和@racket[string-append]。下面有更多的例子。

Racket代码例子贯穿整个文档，预定义的名称的使用链接到参考手册。因此，你可以单击标识符来获得关于其使用的详细信息。

@interaction[
 (code:line (string-append "rope" "twine" "yarn")
            (code:comment @#,t{添加字符串}))
 
 (code:line (substring "corduroys" 0 4)
            (code:comment @#,t{提取子字符串}))

 (code:line (string-length "shoelace")
            (code:comment @#,t{获取字符串长度}))

 (code:line (string? "Ceci n'est pas une string.")
            (code:comment @#,t{识别字符串}))
 (string? 1)
 
 (code:line (sqrt 16)
            (code:comment @#,t{找一个平方根}))
 (sqrt -16)

 (code:line (+ 1 2)
            (code:comment @#,t{数字相加}))
 
 (code:line (- 2 1)
            (code:comment @#,t{数字相减}))
 
 (code:line (< 2 1)
            (code:comment @#,t{数字比较}))
 (>= 2 1)
 
 (code:line (number? "c'est une number")
            (code:comment @#,t{识别数字}))
 (number? 1)

 (code:line (equal? 6 "half dozen")
            (code:comment @#,t{任意比较}))
 (equal? 6 6)
 (equal? "half dozen" "half dozen")]