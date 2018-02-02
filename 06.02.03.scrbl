;06.02.03.scrbl
;6.2.3 子模块
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "guide-utils.rkt"
          (for-label rackunit))

@title[#:tag "submodules"]{子模块}

一个@racket[module]表可以被嵌套在一个模块内，在这种情况下，这个嵌套@racket[module]表声明一个@deftech{子模块（submodule）}。子模块可以通过外围模块使用一个引用名称直接引用。下面的例子通过从@racket[zoo]子模块导入@racket[tiger]打印@racket["Tony"]：

@racketmod[
  #:file "park.rkt"
  racket

  (module zoo racket
    (provide tiger)
    (define tiger "Tony"))

  (require 'zoo)

  tiger
]

运行一个模块不是必须运行子模块。在上面的例子中，运行@filepath{park.rkt}运行它的子模块@racket[zoo]仅因为@filepath{park.rkt}模块@racket[require]了这个@racket[zoo]子模块。否则，一个模块及其子模块可以独立运行。此外，如果@filepath{park.rkt}被编译成字节码文件（通过@exec{raco make}），那么@filepath{park.rkt}代码或@racket[zoo]代码可以独立下载。

子模块可以嵌套子模块，而且子模块可以被一个模块通过使用@elemref["submod"]{子模块路径（submodule path）}直接引用，不同于它的外围模块。

 一个@racket[module*]表类似于一个嵌套的@racket[module]表：
 
@specform[
(module* name-id initial-module-path-or-#f
  decl ...)
]

@racket[module*]表不同于@racket[module]，它反转这个对于子模块和外围模块的参考的可能性：

@itemlist[

@item{用@racket[module]申明的一个子模块模块可通过其外围模块@racket[require]，但子模块不能@racket[require]外围模块或在词法上参考外围模块的绑定。}

@item{用@racket[module*]申明的一个子模块可以@racket[require]其外围模块，但外围模块不能@racket[require]子模块。}

]

此外，一个@racket[module*]表可以在@racket[_initial-module-path]的位置指定@racket[#f]，在这种情况下，所有外围模块的绑定对子模块可见——包括没有使用@racket[provide]输出的绑定。

用@racket[module*]和@racket[#f]申明的子模块的一个应用是通过子模块输出附加绑定，那不是通常的从模块输出：

@racketmod[
#:file "cake.rkt"
racket

(provide print-cake)

(define (print-cake n)
  (show "   ~a   " n #\.)
  (show " .-~a-. " n #\|)
  (show " | ~a | " n #\space)
  (show "---~a---" n #\-))

(define (show fmt n ch)
  (printf fmt (make-string n ch))
  (newline))

(module* extras #f
  (provide show))
]

在这个修订的@filepath{cake.rkt}模块，@racket[show]不是被一个模块输入，它采用@racket[(require "cake.rkt")]，因为大部分@filepath{cake.rkt}的用户不想要那些额外的函数。一个模块可以要求@racket[extra]@tech{子模块（submodule）}使用@racket[(require (submod "cake.rkt" extras))]访问另外的隐藏的@racket[show]函数。