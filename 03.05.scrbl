;03.05.scrbl
;3.5 字节（Byte）和字节字符串（Byte String）
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "guide-utils.rkt")

@title[#:tag "bytestrings"]{字节（Byte）和字节字符串（Byte String）}

@deftech{字节（byte）}是包含@racket[0]到@racket[255]之间的精确整数。@racket[byte?]判断表示字节的数字。

@examples[
(byte? 0)
(byte? 256)]

@deftech{字节字符串（byte string）}类似于字符串——参见《字符串（Unicode）》（@secref["strings"]）部分，但它的内容是字节序列而不是字符。字节字符串可用于处理纯ASCII而不是Unicode文本的应用程序中。一个字节的字符串打印形式特别支持这样的用途，因为一个字节的字符串打印的ASCII的字节字符串解码，但有一个@litchar{#}前缀。在字节字符串不可打印的ASCII字符或非ASCII字节用八进制表示法。

@examples[
#"Apple"
(bytes-ref #"Apple" 0)
(make-bytes 3 65)
(define b (make-bytes 2 0))
b
(bytes-set! b 0 1)
(bytes-set! b 1 255)
b]

一个字节字符串的@racket[display]表写入其原始字节的电流输出端口（看《输入和输出》（@secref["i/o"]）部分）。从技术上讲，一个正常的@racket[display]（即，字符编码的字符串）字符串打印到当前输出端口的UTF-8，因为产出的最终依据字节的定义；然而一个字节字符串的@racket[display]，没有编码写入原始字节。同样，当这个文件显示输出，技术上显示输出的utf-8编码格式。

@examples[
(display #"Apple")
(eval:alts (code:line (display @#,racketvalfont{"\316\273"})  (code:comment @#,t{same as @racket["\316\273"]}))
           (display "\316\273"))
(code:line (display #"\316\273") (code:comment @#,t{UTF-8 encoding of @elem["\u03BB"]}))]

字符串和字节字符串之间的显式转换，Racket直接支持三种编码：UTF-8，Latin-1，和当前的本地编码。字节到字节的通用转换器（特别是从UTF-8）弥合了支持任意字符串编码的差异分歧。

@examples[
 (bytes->string/utf-8 #"\316\273")
 (bytes->string/latin-1 #"\316\273")
 (code:line
  (parameterize ([current-locale "C"])  (code:comment @#,elem{C locale supports ASCII,})
    (bytes->string/locale #"\316\273")) (code:comment @#,elem{only, so...}))
 (let ([cvt (bytes-open-converter "cp1253" (code:comment @#,elem{Greek code page})
                                  "UTF-8")]
       [dest (make-bytes 2)])
   (bytes-convert cvt #"\353" 0 1 dest)
   (bytes-close-converter cvt)
   (bytes->string/utf-8 dest))]