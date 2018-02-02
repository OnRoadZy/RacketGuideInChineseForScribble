;06.02.01.scrbl
;6.2.1 module表
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "guide-utils.rkt"
          (for-label rackunit))

@(define cake-eval (make-base-eval))

@title[#:tag "module-syntax"]{@racket[module]表}

一个模块声明的普通写法形式，既可在@tech{REPL}又可在一个文件中执行的是

@specform[
(module name-id initial-module-path
  decl ...)
]

其中的@racket[_name-id]是一个模块名，@racket[_initial-module-path]是一个初始的导入口，每个@racket[_decl]是一个导入口、导出口、定义或表达式。在文件的情况下，@racket[_name-id]通常与包含文件的名称相匹配，减去其目录路径或文件扩展名，但在模块通过其文件路径@racket[require]时@racket[_name-id]被忽略。

@racket[_initial-module-path]是必需的，因为即使是@racket[require]表必须导入，以便在模块主体中进一步使用。换句话说，@racket[_initial-module-path]导入在主体内可供使用的引导语法。最常用的@racket[_initial-module-path]是@racketmodname[racket]，它提供了本指南中描述的大部分绑定，包括@racket[require]、@racket[define]和@racket[provide]。另一种常用的@racket[_initial-module-path]是@racketmodname[racket/base]，它提供了较少的函数，但仍然是大多数最常用的函数和语法。

例如，@seclink["module-basics"]{前面一节}里的@filepath{cake.rkt}例子可以写为

@racketblock+eval[
#:eval cake-eval
(module cake racket
  (provide print-cake)

  (define (print-cake n)
    (show "   ~a   " n #\.)
    (show " .-~a-. " n #\|)
    (show " | ~a | " n #\space)
    (show "---~a---" n #\-))

  (define (show fmt n ch)
    (printf fmt (make-string n ch))
    (newline)))
]

此外，@racket[module]表可以在@tech{REPL}中求值以申明一个@racket[cake]模块，不与任何文件相关联。为指向是这样一个独立模块，这样引用模块名称：

@examples[
#:eval cake-eval
(require 'cake)
(eval:alts (print-cake 3) (eval '(print-cake 3)))
]

声明模块不会立即求值这个模块的主体定义和表达式。这个模块必须在顶层明确地被@racket[require]以来触发求值。在求值被触发一次之后，后续的@racket[require]不会重新对模块主体求值。

@examples[
(module hi racket
  (printf "Hello\n"))
(require 'hi)
(require 'hi)
]