;01.02.scrbl
;1.2 定义和交互
#lang scribble/doc
@(require scribble/manual scribble/eval scribble/bnf "guide-utils.rkt"
          (only-in scribble/core link-element)
          (for-label racket/enter))

@(define piece-eval (make-base-eval))

@title{定义和交互}

你可以通过使用@racket[define]表像@racket[substring]那样定义自己的函数，像这样：

@def+int[
         #:eval piece-eval
         (define (extract str)
           (substring str 4 7))
 (extract "the boy out of the country")
 (extract "the country out of the boy")
]

虽然你可以在@tech{REPL}求值这个@racket[define]表，但定义通常是你要保持并今后使用一个程序的一部分。所以，在DrRacket中，你通常会把定义放在顶部的文本区——被称作@deftech{定义区域（definitions area）}——随着@hash-lang[]前缀一起：

@racketmod[
racket
code:blank
 (define (extract str)
   (substring str 4 7))]

如果调用@racket[(extract "the boy")]是程序的主要行为的一部分，那么它也将进入@deftech{定义区域（definitions area）}。但如果这只是一个例子，你用来测试@racket[extract]，那么你会更容易如上面那样离开定义区域，点击@onscreen{运行（Run）}，然后将在@tech{REPL}中求值@racket[(extract "the boy")]。

当使用命令行的@exec{racket}代替DrRacket，你会在一个文件中用你喜欢的编辑器保存上面的文本。如果你将它保存为@filepath{extract.rkt}，然后在同一目录开始@exec{racket}，你会对以下序列求值：

@interaction[
             #:eval piece-eval
 (eval:alts (enter! "extract.rkt") (void))
 (extract "the gal out of the city")]

@racket[enter!]表加载代码和开关的求值语境到模块里面，就像DrRacket的@onscreen{运行（Run）}按钮一样。