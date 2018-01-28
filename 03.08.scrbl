;03.08.scrbl
;3.8 配对（Pair）和列表（List）
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "guide-utils.rkt")

@title{配对（Pair）和列表（List）}

一个@deftech{配对（pair）}把两个任意值结合。@racket[cons]过程构建配对，@racket[car]和@racket[cdr]过程分别提取配对的第一和第二个成员。@racket[pair?]判断确认配对。

一些配对通过圆括号包围两个配对元素的打印表来打印，在开始位置放置@litchar{'}，在元素之间放置@litchar{.}。

@examples[
(cons 1 2)
(cons (cons 1 2) 3)
(car (cons 1 2))
(cdr (cons 1 2))
(pair? (cons 1 2))
]

一个@deftech{列表（list）}是创建链表的配对的组合。更确切地说，一个列表要么是空列表@racket[null]，要么是个配对（其第一个元素是列表元素，第二个元素是一个列表）。@racket[list?]判断识别列表。@racket[null?]判断识别空列表。

一个列表通常打印为一个@litchar{'}后跟一对括号括在列表元素周围。

@examples[
null
(cons 0 (cons 1 (cons 2 null)))
(list? null)
(list? (cons 1 (cons 2 null)))
(list? (cons 1 2))
]

当一个列表或配对的一个元素不能写成一个@racket[quote]（引用）值时，使用@racketresult[list]或@racketresult[cons]打印。例如，一个用@racket[srcloc]构建的值不能使用@racket[quote]来写，应该使用@racketresult[srcloc]来写：

@interaction[
(srcloc "file.rkt" 1 0 1 (+ 4 4))
(list 'here (srcloc "file.rkt" 1 0 1 8) 'there)
(cons 1 (srcloc "file.rkt" 1 0 1 8))
(cons 1 (cons 2 (srcloc "file.rkt" 1 0 1 8)))
]

如最后一个例子所示，@racketresult[list*]是用来缩略一系列的不能使用@racketresult[list]缩略的@racketresult[cons]。

@racket[write]和@racket[display]函数不带前导@litchar{'}、@racketresult[cons]、@racketresult[list]或@racketresult[list*]打印一个配对或一个列表。一个配对或列表的@racket[write]和@racket[display]没有区别，除非它们运用于列表元素：

@examples[
(write (cons 1 2))
(display (cons 1 2))
(write null)
(display null)
(write (list 1 2 "3"))
(display (list 1 2 "3"))
]

列表中最重要的预定义程序是遍历列表元素的那些程序：

@interaction[
(map (lambda (i) (/ 1 i))
     '(1 2 3))
(andmap (lambda (i) (i . < . 3))
       '(1 2 3))
(ormap (lambda (i) (i . < . 3))
       '(1 2 3))
(filter (lambda (i) (i . < . 3))
        '(1 2 3))
(foldl (lambda (v i) (+ v i))
       10
       '(1 2 3))
(for-each (lambda (i) (display i))
          '(1 2 3))
(member "Keys"
        '("Florida" "Keys" "U.S.A."))
(assoc 'where
       '((when "3:30") (where "Florida") (who "Mickey")))
]

配对是不可变的（与Lisp传统相反），@racket[pair?]、@racket[list?]仅识别不可变的配对和列表。@racket[mcons]过程创建一个可变的配对，用@racket[set-mcar!]和@racket[set-mcdr!]，及@racket[mcar]和@racket[mcdr]进行操作。一个可变的配对用@racketresult[mcons]打印，而@racket[write]和@racket[display]使用@litchar["{"]和@litchar["}"]打印可变配对：

@examples[
(define p (mcons 1 2))
p
(pair? p)
(mpair? p)
(set-mcar! p 0)
p
(write p)
]