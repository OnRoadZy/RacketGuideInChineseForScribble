;07.09.05.scrbl
;7.9.5 混合set!和contract-out
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          racket/sandbox
          "utils.rkt"
          (for-label racket/base
                     racket/contract))

@title{混合@racket[set!]和@racket[contract-out]}

合约库假定变量通过@racket[contract-out]导出没有被分配到，但没有强制执行。因此，如果您尝试@racket[set!]这些变量，你可能会感到惊讶。考虑下面的例子：

@interaction[
(module server racket
  (define (inc-x!) (set! x (+ x 1)))
  (define x 0)
  (provide (contract-out [inc-x! (-> void?)]
                         [x integer?])))

(module client racket
  (require 'server)

  (define (print-latest) (printf "x is ~s\n" x))

  (print-latest)
  (inc-x!)
  (print-latest))

(require 'client)
]

两个调用@racket[print-latest]打印@racket[0]，即使@racket[x]的值已经增加（并且在模块@racket[x]内可见）。

为了解决这个问题，导出访问函数，而不是直接导出变量，像这样：

@racketmod[
racket

(define (get-x) x)
(define (inc-x!) (set! x (+ x 1)))
(define x 0)
(provide (contract-out [inc-x! (-> void?)]
                       [get-x (-> integer?)]))
]

经验：这是一个我们将在以后的版本中讨论的bug。