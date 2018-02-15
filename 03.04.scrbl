;03.04.scrbl
;3.4 字符串（Unicode Strings）
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "guide-utils.rkt")

@title[#:tag "strings"]{字符串（Unicode Strings）}

@deftech{字符串（string）}是固定长度的@seclink["characters"]{字符（characters）}数组。它使用双引号打印，双引号和反斜杠字符在字符串中是用反斜杠转义。其他常见的字符串转义是支持的，包括@litchar{\n}换行， @litchar{\r}回车，使用@litchar{\}后边跟随三个八进制数字实现八进制转义，使用@litchar{\u}（达四位数）实现十六进制转义。在打印字符串时通常用@litchar{\u}显示字符串中的不可打印字符。

@racket[display]过程直接将字符串的字符写入当前输出端口（见《输入和输出》）（ @secref["i/o"]），与打印字符串结果的字符串常量语法形成对照。

@examples[
"Apple"
(eval:alts @#,racketvalfont{"\u03BB"} "\u03BB")
(display "Apple")
(display "a \"quoted\" thing")
(display "two\nlines")
(eval:alts (display @#,racketvalfont{"\u03BB"}) (display "\u03BB"))]

字符串可以是可变的，也可以是不可变的；作为表达式直接写入的字符串是不可变的，但大多数其他字符串是可变的。 @racket[make-string]过程创建一个给定长度和可选填充字符的可变字符串。@racket[string-ref]程序从字符串（用0字符串集索引）存取一个字符。@racket[string-set!]过程更改可变字符串中的一个字符。

@examples[
(string-ref "Apple" 0)
(define s (make-string 5 #\.))
s
(string-set! s 2 #\u03BB)
s]

字符串排序和状态操作通常是区域无关（@defterm{locale-independent}）的，也就是说，它们对所有用户都是相同的。提供了一些与区域相关（@defterm{locale-dependent}）的操作，允许字符串折叠和排序的方式取决于最终用户的区域设置。如果你在排序字符串，例如，如果排序结果应该在机器和用户之间保持一致，使用@racket[string<?]或者@racket[string-ci<?]，但如果排序纯粹是为最终用户订购字符串，使用@racket[string-locale<?]或者@racket[string-locale-ci<?]。

@examples[
(string<? "apple" "Banana")
(string-ci<? "apple" "Banana")
(string-upcase "Stra\xDFe")
(parameterize ([current-locale "C"])
  (string-locale-upcase "Stra\xDFe"))]

对于使用纯ASCII、处理原始字节、或将Unicode字符串编码/解码为字节，使用字节字符串（@seclink["bytestrings"]{byte strings}）。