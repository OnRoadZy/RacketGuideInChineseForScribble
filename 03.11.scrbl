;03.11.scrbl
;3.11 格子（Box）
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "guide-utils.rkt")

@title{格子（Box）}

一个 @deftech{格子（box）}是一个单元素向量。它可以打印成一个引用@litchar{#&}后边跟随这个格子值的打印表。一个@litchar{#&}表也可以用来作为一种表达，但由于作为结果的格子是常量，它实际上没有使用。

@examples[
(define b (box "apple"))
b
(unbox b)
(set-box! b '(banana boat))
b
]