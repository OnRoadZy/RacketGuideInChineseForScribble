;08.06.scrbl
;08.6 IO模式
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

@title[#:tag "io-patterns"]{IO模式}

@(begin
  (define port-eval (make-base-eval))
  (interaction-eval #:eval port-eval (require racket/port)))

如果你想处理文件中独立的各行，你可以伴随@racket[in-lines]使用@racket[for]：

@interaction[
(define (upcase-all in)
  (for ([l (in-lines in)])
    (display (string-upcase l))
    (newline)))
(upcase-all (open-input-string
             (string-append
              "Hello, World!\n"
              "Can you hear me, now?")))
]

如果你想确定“hello”是否在文件中存在，你可以搜索独立各行，但是更简便的方法是对流应用一正则表达式（查看《@secref["regexp"]》）：

@interaction[
(define (has-hello? in)
  (regexp-match? #rx"hello" in))
(has-hello? (open-input-string "hello"))
(has-hello? (open-input-string "goodbye"))
]

如果你想将一个端口拷贝至另一个，使用来自@racketmodname[racket/port]的@racket[copy-port]，它能够在很多的数据可用时有效传输大的块，也能够在小的块全部就绪时立刻传输：

@interaction[
#:eval port-eval
(define o (open-output-string))
(copy-port (open-input-string "broom") o)
(get-output-string o)
]

@close-eval[port-eval]