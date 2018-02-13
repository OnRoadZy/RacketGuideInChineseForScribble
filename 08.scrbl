;08.scrbl
;8 输入和输出
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

@title[#:tag "i/o" #:style 'toc]{输入和输出}

Racket端口对应Unix中流的概念（不要与@racketmodname[racket/stream]中的流混淆）

一个Racket@deftech{端口（port）}代表一个数据源或数据池，例如一个文件、一个终端、一个TCP连接或者一个内存中字符串。端口提供顺序的访问，在那里数据能够被分批次地读或写，而不需要数据被一次性接受或生成。更具体地，一个@defterm{输入端口（input port）}代表一个程序能从中读取数据的源，一个@defterm{输出端口（output
port）}代表一个程序能够向其中输出的数据池。

@;--------------------------------------------------
@local-table-of-contents[]

@;--------------------------------------------------
@include-section["08.01.scrbl"]
@include-section["08.02.scrbl"]
@include-section["08.03.scrbl"]
@include-section["08.04.scrbl"]
@include-section["08.05.scrbl"]
@include-section["08.06.scrbl"]

@;--------------------------------------------------
@close-eval[io-eval]