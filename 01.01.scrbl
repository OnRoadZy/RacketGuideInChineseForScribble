;01.01.scrbl
;1.1 与Racket语言交互
#lang scribble/doc
@(require scribble/manual scribble/eval scribble/bnf "guide-utils.rkt"
          (only-in scribble/core link-element)
          (for-label racket/enter))

@;(define piece-eval (make-base-eval))

@title{与Racket语言交互}
DrRacket底部的文本区和@exec{racket}的命令行程序（启动时没有选择）作为一种计算器。你打出一个racket的表达式，按下回车键，答案就打印出来了。在Racket的术语里，这种计算器叫做@idefterm{读取求值打印（read-eval-print）}循环或@deftech{REPL}。

一个数字本身就是一个表达式，而答案就是数字：

@interaction[5]

字符串也是一个求值的表达式。字符串在字符串的开始和结尾使用双引号：

@interaction["Hello, world!"]

Racket使用圆括号包装较大的表达式——几乎任何一种表达式，而不是简单的常数。例如，函数调用被写入：大括号，函数名，参数表达式，闭括号。下面的表达式用参数调用@racket["the boy out of the country"]、@racket[4]和@racket[7]调用内置函数@racket[substring]：

@interaction[(substring "the boy out of the country" 4 7)]