;08.03.scrbl
;08.3 读写Racket数据
#lang scribble/doc
@(require scribble/manual
          scribble/struct
          scribble/eval
          racket/system
          "guide-utils.rkt"
          (for-label racket/tcp
                     racket/serialize
                     racket/port))

@(define io-eval (make-base-eval))

@(define (threecolumn a b c)
   (make-table #f
     (list (list (make-flow (list a))
                 (make-flow (list (make-paragraph (list (hspace 1)))))
                 (make-flow (list b))
                 (make-flow (list (make-paragraph (list (hspace 1)))))
                 (make-flow (list c))))))
@(interaction-eval #:eval io-eval (print-hash-table #t))

@title[#:tag "read-write"]{读写Racket数据}

就像在《@secref["datatypes"]》中提到的，Racket提供三种方式打印内建值类型的实例：

@itemize[

 @item{@racket[print], 以在@tech{REPL}环境下的结果打印其值；}
 @item{@racket[write], 以在输出上调用@racket[read]反向产生打印值；}
 @item{@racket[display], 缩小待输出值，至少对以字符或字节为主的数据类型——仅保留字符或字节部分，否则行为等同于@racket[write]。}
 ]

这里有一些每个使用的例子：

@threecolumn[

@interaction[
(print 1/2)
(print #\x)
(print "hello")
(print #"goodbye")
(print '|pea pod|)
(print '("i" pod))
(print write)
]

@interaction[
(write 1/2)
(write #\x)
(write "hello")
(write #"goodbye")
(write '|pea pod|)
(write '("i" pod))
(write write)
]

@interaction[
(display 1/2)
(display #\x)
(display "hello")
(display #"goodbye")
(display '|pea pod|)
(display '("i" pod))
(display write)
]

]

总的来说，@racket[print]对应Racket语法的表达层，@racket[write]对应阅读层，@racket[display]大致对应字符层。

@racket[printf]支持数据与文本的简单格式。在@racket[printf]支持的格式字符串中，@litchar{~a}  @racket[display]下一个参数，@litchar{~s} @racket[write]下一个参数，而@litchar{~v} @racket[print]下一个参数。

@defexamples[
#:eval io-eval
(define (deliver who when what)
  (printf "Items ~a for shopper ~s: ~v" who when what))
(deliver '("list") '("John") '("milk"))
]

使用@racket[write]后，与@racket[display]或@racket[print]不同的是，许多类型的数据可以经由@racket[read]重新读入。相同类型经@racket[print]处理的值也能够被@racket[read]解析，但是结果包含额外的引号表，因为经print表意味着类似于表达式那样读入。

@examples[
#:eval io-eval
(define-values (in out) (make-pipe))
(write "hello" out)
(read in)
(write '("alphabet" soup) out)
(read in)
(write #hash((a . "apple") (b . "banana")) out)
(read in)
(print '("alphabet" soup) out)
(read in)
(display '("alphabet" soup) out)
(read in)
]