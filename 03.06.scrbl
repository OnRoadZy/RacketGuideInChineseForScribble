;03.06.scrbl
;3.6 符号（Symbol）
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "guide-utils.rkt")

@title[#:tag "symbols"]{符号（Symbol）}

@deftech{符号（symbol）}是一个原子值，它像前面的标识符那样以@litchar{'}前缀打印。一个表达式以@litchar{'}开始并以标识符继续表达式产生一个符号值。

@examples[
'a
(symbol? 'a)]

对于任何字符序列，一个相应的符号被@defterm{保留（interned）}；调用@racket[string->symbol]程序，或@racket[read]一个语法标识，产生一个保留符号。由于互联网的符号可以方便地用@racket[eq?]（或这样：@racket[eqv?]或@racket[equal?]）进行比较，所以他们作为一个易于使用的标签和枚举值提供。

符号是区分大小写的。通过使用一个@racketfont{#ci}前缀或其它方式，在读者保留默认情况下，读者可以将大小写字符序列生成一个符号。

@examples[
(eq? 'a 'a)
(eq? 'a (string->symbol "a"))
(eq? 'a 'b)
(eq? 'a 'A)
(eval:alts
 @#,elem{@racketfont{#ci}
  @racketvalfont{@literal{'A}}}
 #ci'A)]

任何字符串（即，任何字符序列）都可以提供给@racket[string->symbol]以获得相应的符号。读者输入任何字符都可以直接出现在一个标识符里，除了空白和以下特殊字符：

@t{
  @hspace[2] @litchar{(} @litchar{)} @litchar{[} @litchar{]}
  @litchar["{"] @litchar["}"]
  @litchar{"} @litchar{,} @litchar{'} @litchar{`}
  @litchar{;} @litchar{#} @litchar{|} @litchar{\}
}

实际上，@litchar{#}只有在一个符号开始是不允许的，或者仅仅如果随后是@litchar{%}；然而，@litchar{#}也被允许。同样。.它本身不是一个符号。

空格或特殊字符可以通过用@litchar{|}或@litchar{\}引用包含标识符。这些引用机制用于包含特殊字符或可能看起来像数字的标识符的打印形式中。

@examples[
(string->symbol "one, two")
(string->symbol "6")
]

@racket[write]函数打印一个没有@litchar{'}前缀的符号。一个符号的@racket[display]表与相应的字符串相同。
 
@examples[
(write 'Apple)
(display 'Apple)
(write '|6|)
(display '|6|)
]

 @racket[gensym]和@racket[string->uninterned-symbol]过程产生新的非保留（@defterm{uninterned}）符号，那不等同于（比照@racket[eq?]）任何先前的保留或非保留符号。非保留符号是可用的新标签，不能与任何其它值混淆。

@examples[
(define s (gensym))
(eval:alts s 'g42)
(eval:alts (eq? s 'g42) #f)
(eq? 'a (string->uninterned-symbol "a"))
]
