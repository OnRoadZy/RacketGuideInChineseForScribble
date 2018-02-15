;04.01.scrbl
;4.1 标记法
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "guide-utils.rkt")

@title[#:tag "syntax-notation"]{标记法}

这一章（和其余的文档）使用了一个稍微不同的标记法，而不是基于字符的《Racket语言概要》（@secref["to-scheme"]）章节语法。使用语法表@racketkeywordfont{something}的语法如下所示：

@specform[(#,(racketkeywordfont "something") [id ...+] an-expr ...)]

斜体的元变量在本规范中，如@racket[_id]和@racket[_an-expr]，使用Racket标识符的语法，所以@racket[_an-expr]是一元变量。命名约定隐式定义了许多元变量的含义：

@itemize[
         
 @item{以@racket[_id]结尾的元变量表示标识符，如@racketidfont{x}或@racketidfont{my-favorite-martian}。}
        
 @item{一元标识符以@racket[_keyword]结束代表一个关键字，如@racket[#:tag]。}
 
 @item{一元标识符以@racket[_expr]结束表达代表任何子表，它将被解析为一个表达式。}
 @item{一元标识符以@racket[_body]结束代表任何子表；它将被解析为局部定义或表达式。只有在没有任何表达式之前，一个@racket[_body]才能解析为一个定义，而最后一个@racket[_body]必须是一个表达式；参见《内部定义》（@secref["intdefs"]）部分。}
 
 ]

在语法的方括号表示形式的括号序列，其中方括号通常用于（约定）。也就是说，方括号@italic{并不（do not）}意味着是句法表的可选部分。

@racketmetafont{...}表示前一个表的零个或多个重复，@racketmetafont{...+}表示前面数据的一个或多个重复。否则，非斜体标识代表自己。

根据上面的语法，这里有一些@racketkeywordfont{something}的合乎逻辑的用法：

@racketblock[
(#,(racketkeywordfont "something") [x])
(#,(racketkeywordfont "something") [x] (+ 1 2))
(#,(racketkeywordfont "something") [x my-favorite-martian x] (+ 1 2) #f)
]

一些语法表规范指的是不隐式定义而不是预先定义的元变量。这样的元变量在主表定义后面使用BNF-like格式提供选择：

@specform/subs[(#,(racketkeywordfont "something-else") [thing ...+] an-expr ...)
               ([thing thing-id
                       thing-keyword])]

上面的例子表明，在 @racketkeywordfont{something-else}表中，一个@racket[_thing]要么是标识符要么是关键字。