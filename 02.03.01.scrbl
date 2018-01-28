;02.03.01.scrbl
;2.3.1 预定义列表循环
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          scribble/bnf
          racket/list
          "guide-utils.rkt"
          (for-label racket/list))

@title{预定义列表循环}

除了像@racket[append]这样的简单的操作，Racket还包括遍历列表元素的函数。这些迭代函数作用类似于java、Racket及其它语言里的 @racket[for]。Racket迭代的主体被打包成一个应用于每个元素的函数，所以@racket[lambda]表在与迭代函数的组合中变得特别方便。

不同的列表迭代函数以不同的方式组合迭代结果。@racket[map]函数使用每个元素结果创建一个新的列表：

@interaction[
 (map sqrt (list 1 4 9 16))
 (map (lambda (i)
        (string-append i "!"))
      (list "peanuts" "popcorn" "crackerjack"))]

@racket[andmap]和@racket[ormap]函数相结合，结果通过@racket[and]或@racket[or]决定：

@interaction[
 (andmap string? (list "a" "b" "c"))
 (andmap string? (list "a" "b" 6))
 (ormap number? (list "a" "b" 6))]
 @racket[map]、 @racket[andmap]和@racket[ormap]函数都可以处理多个列表，而不只是一个单一的列表。列表必须具有相同的长度，并且给定的函数必须接受每个列表元素作为参数：
 
@interaction[
 (map (lambda (s n) (substring s 0 n))
      (list "peanuts" "popcorn" "crackerjack")
      (list 6 3 7))]

@racket[filter]函数保持函数体结果是真的元素，并忽略是@racket[#f]的元素：
 
@interaction[
 (filter string? (list "a" "b" 6))
 (filter positive? (list 1 -2 6 7 0))]

@racket[foldl]函数包含某些迭代函数。它使用每个元素函数处理一个元素并将其与“当前”值相结合，因此每个元素函数接受额外的第一个参数。另外，在列表之前必须提供一个开始的“当前”值：

@interaction[
 (foldl (lambda (elem v)
          (+ v (* elem elem)))
        0
        '(1 2 3))]

尽管有其共性， @racket[foldl]不是像其它函数一样受欢迎。一个原因是@racket[map]、 @racket[ormap]、@racket[andmap]和@racket[filter]覆盖最常见的列表迭代。

Racket为列表提供了一个通用的@defterm{列表解析（list comprehension）}表@racket[for/list]，它通过迭代@defterm{序列（sequences）}建立一个列表。列表解析和相关迭代表将在《迭代和解析》（Iterations and Comprehensions）部分解释。