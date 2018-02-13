;08.02.scrbl
;08.2 默认端口
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

@title[#:tag "default-ports"]{默认端口}

对于大多数简单IO函数，目标端口是一可选参数，默认值为@defterm{当前的输入端口（current input port）}。此外，错误信息被写入@defterm{当前错误端口（current error port）}，这也是一个@defterm{输出端口（current output port）}。@racket[current-input-port]、@racket[current-output-port]和@racket[current-error-port]返回当前相关端口。

@examples[
#:eval io-eval
(display "Hi")
(code:line (display "Hi" (current-output-port)) (code:comment @#,t{the same}))
]

如果你通过终端打开@exec{racket}程序，当前输入、输出和错误端口会连接至终端。更一般地，它们会连接到系统级的stdin、stdout和stderr。在本指引中，例子将输出以紫色显示，错误信息以红色斜体显示。

@defexamples[
#:eval io-eval
(define (swing-hammer)
  (display "Ouch!" (current-error-port)))
(swing-hammer)
]

当前端口这类函数实际上是 @tech{参数（parameters）}，代表它们的值能够通过@racket[parameterize]设置。

@examples[
#:eval io-eval
(let ([s (open-output-string)])
  (parameterize ([current-error-port s])
    (swing-hammer)
    (swing-hammer)
    (swing-hammer))
  (get-output-string s))
]