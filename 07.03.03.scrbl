;07.03.03.scrbl
;7.3.3 关键字参数
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "utils.rkt"
          (for-label framework/framework
                     racket/contract
                     racket/gui))

@title[#:tag "keywords"]{关键字参数}

原来@racket[->]合约构造函数也包含对关键字参数的支持。例如，考虑这个函数，它创建一个简单的GUI并向用户询问一个“yes-or-no”的问题：

@racketmod[
racket/gui

(define (ask-yes-or-no-question question 
                                #:default answer
                                #:title title
                                #:width w
                                #:height h)
  (define d (new dialog% [label title] [width w] [height h]))
  (define msg (new message% [label question] [parent d]))
  (define (yes) (set! answer #t) (send d show #f))
  (define (no) (set! answer #f) (send d show #f))
  (define yes-b (new button% 
                     [label "Yes"] [parent d] 
                     [callback (λ (x y) (yes))]
                     [style (if answer '(border) '())]))
  (define no-b (new button% 
                    [label "No"] [parent d] 
                    [callback (λ (x y) (no))]
                    [style (if answer '() '(border))]))
  (send d show #t)
  answer)

(provide (contract-out
          [ask-yes-or-no-question
           (-> string?
               #:default boolean?
               #:title string?
               #:width exact-integer?
               #:height exact-integer?
               boolean?)]))
]

@racket[ask-yes-or-no-question]的合同使用@racket[->]，同样的方式，@racket[lambda]（或基于@racket[define]的函数）允许关键字在函数正式参数之前，@racket[->]允许关键字先于函数合约的参数合约。在这种情况下，合约表明@racket[ask-yes-or-no-question]必须得到四个关键字参数，各个关键字为：@racket[#:default]、@racket[#:title]、@racket[#:width]和@racket[#:height]。在函数定义中，函数中的关键字之间的@racket[->]相对顺序对函数的客户机并不重要；只有没有关键字的参数合约的相对顺序。 