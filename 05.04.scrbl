;05.04.scrbl
;5.4 不透明结构类型与透明结构类型对比
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          scribble/bnf
          "guide-utils.rkt"
          (for-label racket/dict racket/serialize))

@(define posn-eval (make-base-eval))

@title[#:tag "trans-struct"]{不透明结构类型与透明结构类型对比}

具有以下结构类型定义：

@racketblock[
(struct posn (x y))
]

结构类型的实例以不显示字段值的任何信息的方式打印。也就是说，默认的结构类型是@deftech{不透明的（opaque）}。如果结构类型的访问器和修改器对一个模块保持私有，再没有其它的模块可以依赖这个类型实例的表示。

让结构类型@deftech{透明（transparent）}，在字段序列后面使用@racket[#:transparent]关键字：

@def+int[
#:eval posn-eval
(struct posn (x y)
        #:transparent)
(posn 1 2)
]

一个透明结构类型的实例像调用构造函数一样打印，因此它显示了结构字段值。透明结构类型也允许反射操作，比如@racket[struct?]和@racket[struct-info]，在其实例中使用（参见《@secref["reflection"]》）。

默认情况下，结构类型是不透明的，因为不透明的结构实例提供了更多的封装保证。也就是说，一个库可以使用不透明的结构来封装数据，而库中的客户机除了在库中被允许之外，也不能操纵结构中的数据。

@close-eval[posn-eval]