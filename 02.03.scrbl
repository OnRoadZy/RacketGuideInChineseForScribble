;02.03.scrbl
;2.3 列表、迭代和递归
#lang scribble/doc
@(require scribble/manual scribble/eval scribble/bnf racket/list
          "guide-utils.rkt"
          (for-label racket/list))

@title{列表、迭代和递归}

Racket语言是Lisp的一种方言，名字来自于“LISt Processor”。内置的列表数据类型保持了这种语言的一个显著特征。

@racket[list]函数接受任意数量的值并返回包含值的列表：

@interaction[(list "red" "green" "blue")
             (list 1 2 3 4 5)]

你可以看到，一个列表的结果是作为引用（@litchar{'}）打印在@tech{REPL}中，并且采用一对圆括号包围的列表元素的打印表。这里有一个容易混淆的地方，因为两个表达式都使用圆括号，比如@racket[(list "red" "green" "blue")]，那么打印结果为@racketresult['("red" "green" "blue")]。除了引用，括号中的结果在文档中和DrRacket中打印为蓝色的，而表达式的括号是棕色的。

在列表方面有许多预定义的函数操作。下面是几个例子：

@interaction[
 (code:line (length (list "hop" "skip" "jump"))
            (code:comment @#,t{计算元素个数}))
 
 (code:line (list-ref (list "hop" "skip" "jump") 0)
            (code:comment @#,t{按位置提取}))
 (list-ref (list "hop" "skip" "jump") 1)
 
 (code:line (append (list "hop" "skip") (list "jump"))
            (code:comment @#,t{结合列表}))
 
 (code:line (reverse (list "hop" "skip" "jump"))
            (code:comment @#,t{颠倒顺序}))
 
 (code:line (member "fall" (list "hop" "skip" "jump"))
            (code:comment @#,t{检查一个元素}))]

@include-section["02.03.01.scrbl"]
@include-section["02.03.02.scrbl"]
@include-section["02.03.03.scrbl"]
@include-section["02.03.04.scrbl"]