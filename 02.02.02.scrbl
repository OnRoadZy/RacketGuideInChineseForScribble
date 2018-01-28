;02.02.02.scrbl
;2.2.2 代码缩进
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          scribble/bnf
          "guide-utils.rkt")

@title{代码缩进}

换行和缩进对于解析Racket程序来说并不重要，但大多数Racket程序员使用一套标准的约定来使代码更易读。例如，定义的主体通常在定义的第一行下缩进。标识符是在一个没有额外空格的括号内立即写出来的，而闭括号则从不自己独立一行。

DrRacket会根据标准风格自动缩进，当你输入一个程序或@tech{REPL}表达式。例如，如果你点击进入后输入 @litchar{(define (greet name)}，那么DrRacket自动为下一行插入两个空格。如果你改变了代码区域，你可以在DrRacket打Tab选择它，并且DrRacket将重新缩进代码（没有插入任何换行）。象Emacs这样的编辑器提供Racket或Scheme类似的缩进模式。

重新缩进不仅使代码更易于阅读，它还会以你希望的方式给你更多的反馈，象你的括号是否匹配等等。例如，如果在函数的最后一个参数之后省略一个结束括号，则自动缩进在第一个参数下开始下一行，而不是在@racket{define}关键字下：

@racketblock[
 (define (halfbake flavor
                   (string-append flavor " creme brulee")))]

在这种情况下，缩进有助于突出错误。在其他情况下，在缩进可能是正常的，一个开括号没有匹配的闭括号，@exec{racket}和DrRacket都在源程序的缩进中提示括号丢失。