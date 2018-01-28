;04.10.scrbl
;4.10 引用：quote和'
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "guide-utils.rkt")

@title{引用：@racket[quote]和@racketvalfont{@literal{'}}}

引用（@racket[quote]）表产生一个常数：

@specform[(#,(racketkeywordfont "quote") datum)]

@racket[datum]的语法在技术上被指定为@racket[read]函数解析为单个元素的任何内容。@racket[quote]表的值与@racket[read]将产生给定的@racket[_datum]的值相同。

@racket[_datum]可以是一个符号、一个布尔值、一个数字、一个（字符或字节）字符串、一个字符、一个关键字、一个空列表、一个包含更多类似值的配对（或列表），一个包含更多类似值的向量，一个包含更多类似值的哈希表，或者一个包含其它类似值的格子。

@examples[
(eval:alts (#,(racketkeywordfont "quote")
            apple)
           'apple)
(eval:alts (#,(racketkeywordfont "quote")
            #t)
           #t)
(eval:alts (#,(racketkeywordfont "quote")
            42)
           42)
(eval:alts (#,(racketkeywordfont "quote")
            "hello")
           "hello")
(eval:alts (#,(racketkeywordfont "quote")
            ())
           '())
(eval:alts (#,(racketkeywordfont "quote")
            ((1 2 3) #2("z" x) . the-end))
           '((1 2 3) #2("z" x) . the-end))
(eval:alts (#,(racketkeywordfont "quote")
            (1 2 #,(racketparenfont ".") (3)))
           '(1 2 . (3)))
]

正如上面最后一个示例所示，@racket[_datum]不需要匹配一个值的格式化的打印表。一个@racket[_datum]不能作为从@litchar{#<}开始的打印呈现，所以不能是@|void-const|、@|undefined-const|或一个过程。

@racket[quote]表很少用于@racket[_datum]的布尔值、数字或字符串本身，因为这些值的打印表可以用作常量。@racket[quote]表更常用于符号和列表，当没有被引用时，它具有其他含义（标识符、函数调用等）。

一个表达式：

@specform[(quote @#,racketvarfont{datum})]

是

@racketblock[
(#,(racketkeywordfont "quote") #,(racket _datum))
]

的简写。

这个简写几乎总是用来代替@racket[quote]。简写甚至应用于@racket[_datum]中，因此它可以生成包含@racket[quote]的列表。

@examples[
'apple
'"hello"
'(1 2 3)
(display '(you can 'me))
]