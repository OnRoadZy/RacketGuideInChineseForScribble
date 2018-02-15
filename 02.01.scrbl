;02.1 简单的值
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "guide-utils.rkt")

@title[#:tag "simple-values"]{简单的值}

Racket值包括数字、布尔值、字符串和字节字符串。DrRacket和文档示例中(当你在着色状态下阅读文档时)，值表达式显示为绿色。

@defterm{数值（Numbers）}
数值书写为惯常的方式，包括分数和虚数：

@racketblock[
1       3.14
1/2     6.02e+23
1+2i    9999999999999999999999]

@defterm{布尔值（Booleans）}
布尔值用@racket[#t]表示真，@racket[#f]表示假。但是，在条件表达式里，所有的非@racket[#f]值都被当做真。

@defterm{字符串（Strings）}
字符串写在双引号（""）之间。在一个字符串中，反斜杠（/）是一个转义字符；例如,一个反斜杠之后的双引号为包括文字双引号的字符串。除了一个保留的双引号或反斜杠，任何Unicode字符都可以在字符串常量中出现。

@racketblock[
"Hello, world!"
"Benjamin \"Bugsy\" Siegel"
"\u03BBx:(\u03BC\u03B1.\u03B1u2192\u03B1).xx"]

当一个常量在@tech{REPL}中被求值，通常它的打印结果与输入的语法相同。在某些情况下，打印格式是输入语法的标准化版本。在文档和DrRacket的@tech{REPL}中，结果打印为蓝色而不是绿色以强调打印结果与输入表达式之间的区别。

@examples[
         (eval:alts
          (unsyntax
           (racketvalfont "1.0000"))
          1.0000)
         
         (eval:alts
          (unsyntax
           (racketvalfont
            "\"Bugs \\u0022Figaro\\u0022 Bunny\""))
          "Bugs \u0022Figaro\u0022 Bunny")]