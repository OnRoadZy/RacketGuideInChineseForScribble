;03.12.scrbl
;3.12 空值（Void）和未定义值（Undefined）
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "guide-utils.rkt"
          (for-label racket/undefined
                     racket/shared))

@title{空值（Void）和未定义值（Undefined）}

某些过程或表达式形式不需要结果值。例如，@racket[display]程序仅调用输出的副作用。在这样的情况下，得到的值通常是一个特殊的常量，打印为@|void-const|。当一个表达式的结果是简单的@|void-const|，@tech{REPL}不打印任何东西。

@racket[void]程序接受任意数量的参数并返回@|void-const|。（即，@racketidfont{void}标识符绑定到一个返回@|void-const|的过程，而不是直接绑定到@|void-const|。）

@examples[
(void)
(void 1 2 3)
(list (void))
]

@racket[undefined]常量，它打印为@|undefined-const|，有时是作为一个参考的结果，其值是不可用的。在Racket以前的版本（6.1以前的版本），过早参照一个局部绑定会产生@|undefined-const|；而不是像太早的参照现在会引发一个异常。

@def+int[
(define (fails)
  (define x x)
  x)
(fails)
]