;07.05.01.scrbl
;7.5.1 对特定值的确保
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "guide-utils.rkt"
          "utils.rkt"
          (for-label racket/contract))

@title[#:tag "single-struct"]{对特定值的确保}

如果你的模块定义了一个变量为一个结构，那么你可以使用@racket[struct/c]指定结构的形态：

@racketmod[
racket
(require lang/posn)
  
(define origin (make-posn 0 0))

(provide (contract-out
          [origin (struct/c posn zero? zero?)]))
]

在这个例子中，该模块导入一个代表位置的库，它导出了一个@racket[posn]结构。其中的@racket[posn]创建并导出所代表的网格起点，即@tt{(0,0)}。