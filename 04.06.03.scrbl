;04.06.03.scrbl
;4.6.3 递归绑定：letrec
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "guide-utils.rkt")

@title[#:tag "recursive-binding-letrec"]{递归绑定：letrec}

@racket[letrec]的语法也和@racket[let]相同：

@specform[(letrec ([id expr] ...) body ...+)]{}

而@racket[let]使其其绑定只在@racket[_body]内被提供，@racket[let*]使其绑定提供给任何后来的绑定@racket[_expr]， @racket[letrec]使其绑定提供给所有其它@racket[_expr]，甚至更早的。换句话说，@racket[letrec]绑定是递归的。

在一个@racket[letrec]表中的@racket[letrec]经常大都是递归或互相递归的@racket[lambda]表函数：

@interaction[
(letrec ([swing
          (lambda (t)
            (if (eq? (car t) 'tarzan)
                (cons 'vine
                      (cons 'tarzan (cddr t)))
                (cons (car t)
                      (swing (cdr t)))))])
  (swing '(vine tarzan vine vine)))
]

@interaction[
(letrec ([tarzan-near-top-of-tree?
          (lambda (name path depth)
            (or (equal? name "tarzan")
                (and (directory-exists? path)
                     (tarzan-in-directory? path depth))))]
         [tarzan-in-directory?
          (lambda (dir depth)
            (cond
              [(zero? depth) #f]
              [else
               (ormap
                (λ (elem)
                  (tarzan-near-top-of-tree? (path-element->string elem)
                                            (build-path dir elem)
                                            (- depth 1)))
                (directory-list dir))]))])
  (tarzan-near-top-of-tree? "tmp" 
                            (find-system-path 'temp-dir)
                            4))
]

而一个@racket[letrec]表的@racket[_expr]是典型的@racket[lambda]表达式，它们可以是任何表达式。表达式按顺序求值，在获得每个值之后，它立即与相应的@racket[_id]相关联。如果@racket[_id]在其值准备就绪之前被引用，则会引发一个错误，就像内部定义一样。

@interaction[
(letrec ([quicksand quicksand])
  quicksand)
]
