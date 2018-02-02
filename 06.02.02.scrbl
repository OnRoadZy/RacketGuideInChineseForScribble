;06.02.02.scrbl
;6.2.2 #lang简写
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "guide-utils.rkt"
          (for-label rackunit))

@title[#:tag "hash-lang"]{ @racketmodfont{#lang}简写}

@racketmodfont{#lang}简写的主体没有特定的语法，因为语法是由如下@racketmodfont{#lang}语言名称确定的。

在@racketmodfont{#lang} @racketmodname[racket]的情况下，语法为：

@racketmod[
racket
_decl ...]

其读作如下同一内容：

@racketblock[
(module _name racket
  _decl ...)
]

这里的@racket[_name]是来自包含@racketmodfont{#lang}表的文件名称。

@racketmodfont{#lang} @racketmodname[racket/base]表具有和@racketmodfont{#lang} @racketmodname[racket]同样的语法，除了普通写法的扩展使用@racketmodname[racket/base]而不是@racketmodname[racket]。@racketmodfont{#lang} @racketmodname[scribble/manual]表相反，有一个完全不同的语法，甚至看起来不像Racket，在这个指南里我们不准备去描述。

除非另有规定，一个模块是一个文档，它作为“语言”使用@racketmodfont{#lang}标记法表示将以和@racketmodfont{#lang}
@racketmodname[racket]同样的方式扩大到@racket[module]中。文档的语言名也可以直接使用@racket[module]或@racket[require]。