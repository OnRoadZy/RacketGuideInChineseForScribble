;04.07.scrbl
;4.7 条件分支
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "guide-utils.rkt")

@title[#:tag "conditionals"]{条件分支}

大多数函数都可用于分支，如@racket[<]和@racket[string?]，结果要么产生@racket[#t]要么产生@racket[#f]。Racket的分支表，无论什么情况，对待任何非@racket[#f]值为真。我们说一个@defterm{真值（true value）}意味着其它为任何非@racket[#f]值。

本约定的“真值（true value）”在@racket[#f]能够代替故障或表明不提供一个可选的值的地方与协议完全吻合 。（谨防过度使用这一技巧，记住一个异常通常是一个更好的机制来报告故障。）

例如，@racket[member]函数具有双重职责；它可以用来查找从一个特定项目开始的列表的尾部，或者它可以用来简单地检查一个项目是否存在于列表中：

@interaction[
(member "Groucho" '("Harpo" "Zeppo"))
(member "Groucho" '("Harpo" "Groucho" "Zeppo"))
(if (member "Groucho" '("Harpo" "Zeppo"))
    'yep
    'nope)
(if (member "Groucho" '("Harpo" "Groucho" "Zeppo"))
    'yep
    'nope)
]

@include-section["04.07.01.scrbl"]
@include-section["04.07.02.scrbl"]
@include-section["04.07.03.scrbl"]