;06.02.04.scrbl
;6.2.4 main和test子模块
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "guide-utils.rkt"
          (for-label rackunit))

@title[#:tag "main-and-test"]{main和test子模块}

下面@filepath{cake.rkt}的变体包括一个@racket[main]子模块，它调用@racket[print-cake]：

@racketmod[
#:file "cake.rkt"
racket

(define (print-cake n)
  (show "   ~a   " n #\.)
  (show " .-~a-. " n #\|)
  (show " | ~a | " n #\space)
  (show "---~a---" n #\-))

(define (show fmt n ch)
  (printf fmt (make-string n ch))
  (newline))

(module* main #f
  (print-cake 10))
]

运行一个模块不会运行@racket[module*]定义的子模块。尽管如此，还是可以通过@exec{racket}或DrRacket运行上面的模块打印一个带10支蜡烛的蛋糕，因为@racket[main]@tech{子模块（submodule）}是一个特殊情况。

当一个模块作为一个可执行程序的名称提供给@exec{racket}在DrRacket中直接运行或执行在，如果模块有一个@as-index{@racket[main]子模块}，@racket[main]子模块会在其外围模块之后运行。当一个模块直接运行时，声明一个@racket[main]子模块从而指定额外的行为去被执行，以代替@racket[require]作为在一个较大程序里的一个库。

一个@racket[main]子模块不必用@racket[module*]声明。如果@racket[main]模块不需要使用其外围模块的绑定，则可以用@racket[module]声明它。更通常的是，@racket[main]使用@racket[module+]声明：

@specform[
(module+ name-id
  decl ...)
]

用@racket[module+]申明的一个子模块就像一个由@racket[module*]用@racket[#f]代替@racket[_initial-module-path]申明的模块。此外，多个@racket[module+]表可以指定相同的子模块名称，在这种情况下，@racket[module+]表的主体被组合起来以创建一个单独的子模块。

@racket[module+]的组合行为对定义一个@racket[test]子模块是非常有用的，它可以方便地使用@exec{raco test}运行，用同样的方式@racket[main]也可以方便地使用@exec{racket}运行。例如，下面的@filepath{physics.rkt}模块输出@racket[drop]和@racket[to-energy]函数，它定义了一个@racket[test]模块支持单元测试：
 
@racketmod[
#:file "physics.rkt"
racket
(module+ test
  (require rackunit)
  (define ε 1e-10))

(provide drop
         to-energy)

(define (drop t)
  (* 1/2 9.8 t t))

(module+ test
  (check-= (drop 0) 0 ε)
  (check-= (drop 10) 490 ε))

(define (to-energy m)
  (* m (expt 299792458.0 2)))

(module+ test
  (check-= (to-energy 0) 0 ε)
  (check-= (to-energy 1) 9e+16 1e+15))
]

引入@filepath{physics.rkt}到一个更大的程序不会运行@racket[drop]和@racket[to-energy]测试——即使引发这个测试代码的加载，如果模块被编译——但在运行@exec{raco test physics.rkt}的时候会同时运行这个测试。

上述@filepath{physics.rkt}模块相当于使用@racket[module*]：

@racketmod[
#:file "physics.rkt"
racket

(provide drop
         to-energy)

(define (drop t)
  (* 1/2 #e9.8 t t))

(define (to-energy m)
  (* m (expt 299792458 2)))

(module* test #f
  (require rackunit)
  (define ε 1e-10)
  (check-= (drop 0) 0 ε)
  (check-= (drop 10) 490 ε)
  (check-= (to-energy 0) 0 ε)
  (check-= (to-energy 1) 9e+16 1e+15))
]

使用@racket[module+]代替@racket[module*]允许测试与函数定义交叉。

 @racket[module+]的组合行为有时对@racket[main]模块也有帮助。即使组合是不需要的，@racket[(module+ main ....)]仍是首选，因为它比@racket[(module* main #f ....)]更具可读性。