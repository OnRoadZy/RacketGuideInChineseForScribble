;06.04.scrbl
;6.4 导入：require
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "guide-utils.rkt")

@title[#:tag "module-require"]{导入：@racket[require]}

从另一个模块导入@racket[require]表。一个@racket[require]表可以出现在一个模块中，在这种情况下，它将指定模块的绑定引入到导入的模块中。一个@racket[require]表也可以出现在顶层，在这种情况下，既导入绑定也 @deftech{实例化（instantiates）}指定的模块；即，它对指定模块的主体和表达式求值，如果他们还没有被求值。

单个的@racket[require]可以同时指定多个导入：

@specform[(require require-spec ...)]{}

在一个单一的@racket[require]表里指定多个@racket[_require-spec]，从本质上与使用多个@racket[require]，每个单独包含一个单一的@racket[_require-spec]是相同的。区别很小，且局限于顶层：一个独立的@racket[require]可以导入一个给定标识符最多一次，而一个单独的@racket[require]可以代替以前@racket[require]的绑定（都是只局限于顶层，在一个模块之外）。

@racket[_require-spec]的允许形态是递归定义的：

@;------------------------------------------------------------------------
@specspecsubform[module-path]{

在最简单的形式中，一个@racket[_require-spec]是一个@racket[module-path]（如前一节《@secref["module-paths"]》（Module Paths）中定义的）。在这种情况下，@racket[require]所引入的绑定通过@racket[provide]声明来确定，其中在每个模块通过各个@racket[module-path]引用。

@examples[
(module m racket
  (provide color)
  (define color "blue"))
(module n racket
  (provide size)
  (define size 17))
(require 'm 'n)
(eval:alts (list color size) (eval '(list color size)))
]

}

@;------------------------------------------------------------------------
@specspecsubform/subs[#:literals (only-in)
                      (only-in require-spec id-maybe-renamed ...)
                      ([id-maybe-renamed id
                                         [orig-id bind-id]])]{

一个@racket[only-in]表限制绑定设置，它将通过@racket[require-spec]引入。此外，@racket[only-in]选择重命名每个绑定，它被保护：在@racket[[orig-id
bind-id]]表里，@racket[orig-id]是指一个被@racket[require-spec]隐含的绑定，并且@racket[bind-id]是这个在导入上下文中将被绑定的名称，以代替@racket[orig-id]。

@examples[
(module m (lib "racket")
  (provide tastes-great?
           less-filling?)
  (define tastes-great? #t)
  (define less-filling? #t))
(require (only-in 'm tastes-great?))
(eval:alts tastes-great? (eval 'tastes-great?))
less-filling?
(require (only-in 'm [less-filling? lite?]))
(eval:alts lite? (eval 'lite?))
]}

@;------------------------------------------------------------------------
@specspecsubform[#:literals (except-in)
                 (except-in require-spec id ...)]{

这个表是 @racket[only-in]的补充：它从以@racket[require-spec]指定的集合中排除指定的绑定。}

@;------------------------------------------------------------------------
@specspecsubform[#:literals (rename-in)
                 (rename-in require-spec [orig-id bind-id] ...)]{

这种形式支持类似于@racket[only-in]的重命名，但从@racket[require-spec]中分离单独的标识符，它们没有作为一个@racket[orig-id]提交。}

@;------------------------------------------------------------------------
@specspecsubform[#:literals (prefix-in)
                 (prefix-in prefix-id require-spec)]{

这是一个重命名的简写，@racket[prefix-id]添加到用@racket[require-spec]指定的每个标识符的前面。}

除了@racket[only-in]、@racket[except-in]、@racket[rename-in]2和@racket[prefix-in]表可以嵌套以实现更复杂的导入绑定操作。例如,

@racketblock[(require (prefix-in m: (except-in 'm ghost)))]

导入@racket[m]输出的所有绑定，除@racket[ghost]绑定之外，并带用@racket[m:]前缀的局部名字：

等价地，@racket[prefix-in]可以被应用在@racket[except-in]之前，只是带@racket[except-in]的省略是用@racket[m:]前缀指定：

@racketblock[(require (except-in (prefix-in m: 'm) m:ghost))]