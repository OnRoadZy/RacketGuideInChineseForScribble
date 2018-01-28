;04.08.scrbl
;4.8 排序
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "guide-utils.rkt")

@title{排序}

Racket程序员喜欢编写尽可能少的带副作用的程序，因为纯粹的函数代码更容易测试和组成更大的程序。然而，与外部环境的交互需要进行排序，例如在向显示器写入、打开图形窗口或在磁盘上操作文件时。

@include-section["04.08.01.scrbl"]
@include-section["04.08.02.scrbl"]
@include-section["04.08.03.scrbl"]