;12.scrbl
;12 模式匹配
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "guide-utils.rkt"
          (for-label racket/match))

@(begin
  (define match-eval (make-base-eval))
  (interaction-eval #:eval match-eval (require racket/match)))

@title[#:tag "match"]{模式匹配}

@racket[match]表支持对任意Racket值的模式匹配，而不是像@racket[regexp-match]那样的函数，将正则表达式与字符及字节序列比较（参见《@secref["regexp"]》（Regular Expressions））。

@specform[
(match target-expr
  [pattern expr ...+] ...)
]

@racket[match]表获取@racket[target-expr]的结果并试图按顺序匹配每个@racket[_pattern]。一旦它找到一个匹配，对相应的@racket[_expr]序列求值以得到@racket[匹配（match）]表的结果。如果@racket[_pattern]包括@deftech{模式变量（pattern variables）}，他们被当作通配符，并且在@racket[_expr]里的每个变量被绑定给的被匹配的输入片段。

大多数Racket的字面表达式可以用作模式：

@interaction[
#:eval match-eval
(match 2
  [1 'one]
  [2 'two]
  [3 'three])
(match #f
  [#t 'yes]
  [#f 'no])
(match "apple"
  ['apple 'symbol]
  ["apple" 'string]
  [#f 'boolean])
]

像@racket[cons]、@racket[list]和@racket[vector]这样的构造器，可以用于创建模式，以匹配pairs、lists和vectors：

@interaction[
#:eval match-eval
(match '(1 2)
  [(list 0 1) 'one]
  [(list 1 2) 'two])
(match '(1 . 2)
  [(list 1 2) 'list]
  [(cons 1 2) 'pair])
(match #(1 2)
  [(list 1 2) 'list]
  [(vector 1 2) 'vector])
]

用@racket[struct]绑定的构造器也可以用作一个模式构造器：

@interaction[
#:eval match-eval
(struct shoe (size color))
(struct hat (size style))
(match (hat 23 'bowler)
 [(shoe 10 'white) "bottom"]
 [(hat 23 'bowler) "top"])
]

不带引号的，在一个模式中的非构造器标识符是@tech{模式变量（pattern
variables）}，它在结果表达式中被绑定，除了@racket[_]，它不绑定（因此，这通常是作为一个泛称）：

@interaction[
#:eval match-eval
(match '(1)
  [(list x) (+ x 1)]
  [(list x y) (+ x y)])
(match '(1 2)
  [(list x) (+ x 1)]
  [(list x y) (+ x y)])
(match (hat 23 'bowler)
  [(shoe sz col) sz] 
  [(hat sz stl) sz])
(match (hat 11 'cowboy)
  [(shoe sz 'black) 'a-good-shoe] 
  [(hat sz 'bowler) 'a-good-hat]
  [_ 'something-else])
]

省略号，写作@litchar{...}就像在一个列表或向量模式中的一个Kleene star：前面的子模式可以用于对列表或向量元素的任意数量的连续元素的任意次匹配。如果后跟省略号的子模式包含一个模式变量，这个变量会匹配多次，并在结果表达式里被绑定到一个匹配列表中：

@interaction[
#:eval match-eval
(match '(1 1 1)
  [(list 1 ...) 'ones]
  [_ 'other])
(match '(1 1 2)
  [(list 1 ...) 'ones]
  [_ 'other])
(match '(1 2 3 4)
  [(list 1 x ... 4) x])
(match (list (hat 23 'bowler) (hat 22 'pork-pie))
  [(list (hat sz styl) ...) (apply + sz)])
]

省略号可以嵌套以匹配嵌套的重复，在这种情况下，模式变量可以绑定到匹配列表中：

@interaction[
#:eval match-eval
(match '((! 1) (! 2 2) (! 3 3 3))
  [(list (list '! x ...) ...) x])
]

@racket[quasiquote]表（见《@secref["qq"]》获取更多关于它的信息）还可以用来建立模式。而一个通常的quasiquote表的unquoted部分意味着普通的racket求值，这里unquoted部分意味着回到普通模式匹配。

因此，在下面的例子中，with表达模式是模式并且它被改写成应用表达式，在第一个例子里用quasiquote作为一个模式，在第二个例子里quasiquote构建一个表达式。

@interaction[
#:eval match-eval
(match `{with {x 1} {+ x 1}}
  [`{with {,id ,rhs} ,body}
   `{{lambda {,id} ,body} ,rhs}])
]

有关更多模式表的信息，请参见《@racketmodname[racket/match]》。

像@racket[match-let]表和@racket[match-lambda]表支持位置模式，否则必须是标识符。例如，@racket[match-let]概括@racket[let]给一个@as-index{破坏绑定（destructing
bind）}：

@interaction[
#:eval match-eval
(match-let ([(list x y z) '(1 2 3)])
  (list z y x))
]

有关这些附加表的信息，请参见《@racketmodname[racket/match]》。

@refdetails["match"]{模式匹配}

@close-eval[match-eval]