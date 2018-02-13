;08.04.scrbl
;08.4 数据类型和序列化
#lang scribble/doc
@(require scribble/manual
          scribble/struct
          scribble/eval
          racket/system
          "guide-utils.rkt"
          (for-label racket/tcp
                     racket/serialize
                     racket/port))

@(define io-eval (make-base-eval))

@(define (threecolumn a b c)
   (make-table #f
     (list (list (make-flow (list a))
                 (make-flow (list (make-paragraph (list (hspace 1)))))
                 (make-flow (list b))
                 (make-flow (list (make-paragraph (list (hspace 1)))))
                 (make-flow (list c))))))
@(interaction-eval #:eval io-eval (print-hash-table #t))

@title[#:tag "serialization"]{数据类型和序列化}

@tech{Prefab}类型（查看《@secref["prefab-struct"]》）自动支持@deftech{序列化（serialization）}：它们可被写入输出流，其副本可被由输入流读入：

@interaction[
(define-values (in out) (make-pipe))
(write #s(sprout bean) out)
(read in)
]

使用@racket[struct]创建的其它结构类型，提供较@tech{prefab}类型更多的抽象，通常@racket[write]既使用@racketresultfont{#<....>}记号（对于不透明结构类型）也使用@racketresultfont{#(....)}矢量记号（对于透明结构类型）作为输出。两种的输出结果都不能以结构类型反向读入。

@interaction[
(struct posn (x y))
(write (posn 1 2))
(define-values (in out) (make-pipe))
(write (posn 1 2) out)
(read in)
]

@interaction[
(struct posn (x y) #:transparent)
(write (posn 1 2))
(define-values (in out) (make-pipe))
(write (posn 1 2) out)
(define v (read in))
v
(posn? v)
(vector? v)
]

@racket[serializable-struct]表定义了一个结构类型，它能够被@racket[序列化（serialize）]为一个值，这个值可使用@racket[write]打印和供@racket[read]读入。@racket[序列化（serialize）]的结果可被@racket[反序列化（deserialize）]为原始结构类的实例。序列化表与函数由@racketmodname[racket/serialize]库提供。

@examples[
(require racket/serialize)
(serializable-struct posn (x y) #:transparent)
(deserialize (serialize (posn 1 2)))
(write (serialize (posn 1 2)))
(define-values (in out) (make-pipe))
(write (serialize (posn 1 2)) out)
(deserialize (read in))
]

除了@racket[struct]绑定的名字外，@racket[serializable-struct]绑定具有反序列化信息的标识符，并且会自动由模块上下文@racket[提供（provide）]反序列化标识符。当值被反序列化时，反序列化标识符会经由反射访问。