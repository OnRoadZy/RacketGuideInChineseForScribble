;06.02.scrbl
;6.2 模块语法
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "guide-utils.rkt"
          (for-label rackunit))

@title[#:tag "module-syntax"]{模块语法}


@litchar{#lang}在一个模块文件的开始，它开始一个对@racket[module]表的简写，就像@litchar{'}是一种对@racket[quote]表的简写。不同于@litchar{'}，@litchar{#lang}简写在@tech{REPL}内不能正常执行，部分是因为它必须由end-of-file（文件结束）终止，也因为@litchar{#lang}的普通写法依赖于封闭文件的名称。

@;--------------------------------------------------------------
@include-section["06.02.01.scrbl"]
@include-section["06.02.02.scrbl"]
@include-section["06.02.03.scrbl"]
@include-section["06.02.04.scrbl"]