;1.4 给有LISP/Scheme经验的读者的一个说明
#lang scribble/doc
@(require scribble/manual scribble/eval scribble/bnf "guide-utils.rkt"
          (only-in scribble/core link-element)
          (for-label racket/enter))

@(define piece-eval (make-base-eval))

@title[#:tag "use-module"]{给有LISP/Scheme经验的读者的一个说明}

如果你已经知道一些关于Scheme或Lisp的东西，你可能会试图这样将

@racketblock[
(define (extract str)
  (substring str 4 7))]
  
放入@filepath{extract.rkt}并且如下运行@exec{racket}

@interaction[
             #:eval piece-eval
 (eval:alts (load "extract.rktl") (void))
 (extract "the dog out")]

这将起作用，因为@exec{racket}会模仿传统的Lisp环境，但我们强烈建议不要在模块之外使用@racket[load]或编写程序。

在模块之外编写定义会导致糟糕的错误消息、差的性能和笨拙的脚本来组合和运行程序。这些问题并不是特别针对@exec{racket}，它们是传统顶层环境的根本限制，Scheme和Lisp实现在历史上与临时命令行标志、编译器指令和构建工具进行了斗争。模块系统的设计是为了避免这些问题，所以以@hash-lang[]开始，你会在长期工作中与Racket更愉快。

@close-eval[piece-eval]