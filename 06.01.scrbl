;06.01.scrbl
;6.1 模块基础知识
#lang scribble/doc
@(require scribble/manual 
          scribble/eval 
          "guide-utils.rkt"
          "module-hier.rkt"
          (for-label setup/dirs
                     setup/link
                     racket/date))

@title[#:tag "module-basics"]{模块基础知识}

每个Racket模块通常驻留在自己的文件中。例如，假设文件@filepath{cake.rkt}包含以下模块：

@racketmod[
 #:file "cake.rkt"
 racket

 (provide print-cake)

 (code:comment @#,t{用@racket[n]支蜡烛做蛋糕。})
 (define (print-cake n)
   (show "   ~a   " n #\.)
   (show " .-~a-. " n #\|)
   (show " | ~a | " n #\space)
   (show "---~a---" n #\-))

 (define (show fmt n ch)
   (printf fmt (make-string n ch))
   (newline))
 ]

然后，其他模块可以导入@filepath{cake.rkt}以使用@racket[print-cake]的函数，因为@filepath{cake.rkt}的 @racket[provide]行明确导出了@racket[print-cake]的定义。@racket[show]函数对@filepath{cake.rkt}是私有的（即它不能从其他模块被使用），因为@racket[show]没有被导出。

下面的@filepath{random-cake.rkt}模块导入@filepath{cake.rkt}：

@racketmod[
#:file "random-cake.rkt"
racket

(require "cake.rkt")

(print-cake (random 30))
]

相对在导入@racket[(require "cake.rkt")]内的引用@racket["cake.rkt"]的运行来说，如果@filepath{cake.rkt}和@filepath{random-cake.rkt}模块在同一个目录里。UNIX样式的相对路径用于所有平台上的相对模块引用，就像HTML页面中的相对的URL一样。

@;------------------------------------------------------------------
@include-section["06.01.01.scrbl"]
@include-section["06.01.02.scrbl"]
@include-section["06.01.03.scrbl"]
@include-section["06.01.04.scrbl"]