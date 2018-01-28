;03.09.scrbl
;3.9 向量（Vector）
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "guide-utils.rkt")

@title{向量（Vector）}

一个@deftech{向量（vector）}是任意值的固定长度数组。与列表不同，向量支持常量时间访问和元素更新。

向量打印类似列表——作为其元素的括号序列——但向量要在@litchar{'}之后加前缀@litchar{#}，或如果某个元素不能用引号则使用@racketresult[vector]表示。

向量作为表达式，可以提供可选长度。同时，一个向量作为一个隐式@racket[quote]（引用）的表表达的内容，这意味着在一个矢量常数标识符和括号表表示的符号和列表。

@examples[
(eval:alts @#,racketvalfont{#("a" "b" "c")} #("a" "b" "c"))
(eval:alts @#,racketvalfont{#(name (that tune))} #(name (that tune)))
(eval:alts @#,racketvalfont{#4(baldwin bruce)} #4(baldwin bruce))
(vector-ref #("a" "b" "c") 1)
(vector-ref #(name (that tune)) 1)
]

像字符串一样，向量要么是可变的，要么是不可变的，直接作为表达式编写的向量是不可变的。

向量可以通过@racket[vector->list]和@racket[list->vector]转换成列表，反之亦然。这种转换与列表中预定义的程序相结合特别有用。当分配额外的列表似乎太昂贵时，考虑使用像@racket[for/fold]的循环形式，它像列表一样识别向量。

@examples[
(list->vector (map string-titlecase
                   (vector->list #("three" "blind" "mice"))))
]