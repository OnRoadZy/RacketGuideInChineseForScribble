;06.03.scrbl
;6.3 模块的路径
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "guide-utils.rkt")

@title[#:tag "module-paths"]{模块的路径}

@deftech{模块路径（module path）}是对模块的引用，作为@racket[require]的使用，或者作为@racket[module]表中的@racket[_initial-module-path]。它可以是几种形式中的任意一种：

@;-------------------------------------------------------------------
@specsubform[#:literals (quote) (#,(racket quote) id)]{

引用标识符的@tech{模块路径（module path）}指的是使用标识符的非文件@racket[module]声明。这种模块引用形式做多的场景是在@tech{REPL}。

@examples[
(module m racket
  (provide color)
  (define color "blue"))
(module n racket
  (require 'm)
  (printf "my favorite color is ~a\n" color))
(require 'n)
]}

@;-------------------------------------------------------------------
@specsubform[rel-string]{

字符串@tech{模块路径（module path）}是使用UNIX样式约定的相对路径：@litchar{/}是路径分隔符，@litchar{..}指父目录，@litchar{.}指同一目录。@racket[rel-string]不必以路径分隔符开始或结束。如果路径没有后缀，@filepath{.rkt}会自动添加。

路径是相对于封闭文件，如果有的话，或者是相对于当前目录。（更确切地说，路径是相对于 @racket[(current-load-relative-directory)]的值），这是在加载文件时设置的。

《@secref["module-basics"]（Module Basics）》使用相对路径显示了示例。

如果一个相对路径以@filepath{.ss}后缀结尾，它会被转换成@filepath{.rkt}。如果实现引用模块的文件实际上以@filepath{.ss}结束，当试图加载文件（但@filepath{.rkt}后缀优先）时后缀将被改回来。这种双向转换提供了与Racket旧版本的兼容。}

@;-------------------------------------------------------------------
@specsubform[id]{

一个@tech{模块路径（module path）}是一个引用标识符，引用一个已经安装的库。@racket[id]约束只包含ASCII字母、ASCII数字、@litchar{+}、@litchar{-}、@litchar{_}和@litchar{/}，@litchar{/}分隔标识符内的路径元素。元素指的是@tech{集合（collection）}和@tech{子集合（sub-collection）}，而不是目录和子目录。

这种形式的一个例子是@racket[racket/date]。它是指模块的源是@filepath{racket}集合中的@filepath{date.rkt}文件，它被安装为Racket的一部分。@filepath{.rkt}后缀被自动添加。

这种形式的另一个例子是@racketmodname[racket]，在初始引入时它通常被使用。路径@racketmodname[racket]是对@racket[racket/main]的简写；当一个@racket[id]没有@litchar{/}，那么@racket[/main]自动被添加到结尾。因此，@racketmodname[racket]或@racket[racket/main]是指其源是@filepath{racket}集合里的@filepath{main.rkt}文件的模块。

@examples[
(module m racket
  (require racket/date)

  (printf "Today is ~s\n"
          (date->string (seconds->date (current-seconds)))))
(require 'm)
]

当一个模块的完整路径以@filepath{.rkt}结束，如果没有这样的文件存在但有一个@filepath{.ss}后缀的文件存在，那么这个@filepath{.ss}后缀是是自动替代的。这种转换提供了与旧版本的Racket的兼容。}

@;-------------------------------------------------------------------
@specsubform[#:literals (lib)
             (lib rel-string)]{

像一个不带引号的标识符的路径，但表示为一个字符串而不是标识符。另外，@racket[rel-string]可以以一个文件的后缀结束，在这种情况下，@filepath{.rkt}不是自动添加的。

这种形式的例子包括@racket[(lib "racket/date.rkt")]和@racket[(lib "racket/date")]，这是相当于@racket[racket/date]。其它的例子包括@racket[(lib "racket")]、@racket[(lib "racket/main")]和@racket[(lib "racket/main.rkt")]，都相当于@racketmodname[racket]。

@examples[
(module m (lib "racket")
  (require (lib "racket/date.rkt"))

  (printf "Today is ~s\n"
          (date->string (seconds->date (current-seconds)))))
(require 'm)
]}

@;-------------------------------------------------------------------
@specsubform[#:literals (planet)
             (planet id)]{

访问通过@|PLaneT|服务器分发的第三方库。首先需要下载库，然后使用本地副本。

@racket[id]编码了用@litchar{/}分隔的几条信息：包所有者，然后是可选的版本信息的包名，以及一个特定的库与包的可选路径。像@racket[id]作为一个 @racket[lib]路径的简写，一个@filepath{.rkt}后缀被自动添加，并且当子路径没有提供时@racketidfont{/main}用作路径。

@examples[
(eval:alts
 (module m (lib "racket")
   (code:comment @#,t{Use @filepath{schematics}'s @filepath{random.plt} 1.0, file @filepath{random.rkt}:})
   (require (planet schematics/random:1/random))
   (display (random-gaussian)))
 (void))
(eval:alts
 (require 'm)
 (display 0.9050686838895684))
]

与其它形式，一个用 @filepath{.ss}作为文件结尾的实现可以自动取代如果没有用@filepath{.rkt}执行文件结尾存在。}

@;-------------------------------------------------------------------
@specsubform[#:literals (planet)
             (planet package-string)]{

就像@racket[planet]的符号形式，但使用的是字符串而不是标识符。另外，@racket[package-string]可以一个文件的后缀结束，在这种情况下，@filepath{.rkt}不添加。

与其他形式一样，当以@filepath{.ss}文件结尾的实现可以自动取代时，如果没有以@filepath{.rkt}执行文件结尾存在，@filepath{.ss}扩展为@filepath{.rkt}。}

@;-------------------------------------------------------------------
@specsubform/subs[#:literals (planet = + -)
                  (planet rel-string (user-string pkg-string vers ...))
                  ([vers nat
                         (nat nat)
                         (= nat)
                         (+ nat)
                         (- nat)])]{

从@|PLaneT|服务器访问库的更一般形式。在这种一般形式中，@|PLaneT|引用开始时像一个相对路径的@racket[库（lib）]引用，但路径后面是关于库的生产者、包和版本的信息。指定的包是按需下载和安装的。

@racket[vers]在包的可接受版本中指定了一个约束，其中版本号是非负整数序列，约束确定序列中每个元素的允许值。如果没有为特定元素提供约束，则允许任何版本；特别是，省略所有@racket[vers]意味着任何版本都可以接受。至少指定一个@racket[vers]用于强烈推荐。

对于版本约束，普通@racket[nat]与@racket[(+ nat)]相同，对应于版本号的相应元素的@racket[nat]或更高的@racket[nat]。@racket[(_start-nat
_end-nat)]匹配范围内的任何@racket[_start-nat]到@racket[_end-nat]，包括，一个@racket[(= nat)]完全匹配@racket[nat]。一个@racket[(- nat)]匹配@racket[nat]或更低。

@examples[
(eval:alts
 (module m (lib "racket")
   (require (planet "random.rkt" ("schematics" "random.plt" 1 0)))
   (display (random-gaussian)))
 (void))
(eval:alts
 (require 'm)
 (display 0.9050686838895684))
]

自动的@filepath{.ss}和@filepath{.rkt}转换作为其它表添加。}

@;-------------------------------------------------------------------
@specsubform[#:literals (file)
             (file string)]{

指定一个文件，其@racket[string]是一个使用当前平台的约定的相对或绝对路径。此表单不可移植，并且@italic{不应当（not）}使用一个扁平的、轻便的@racket[rel-string]满足使用。

自动的@filepath{.ss}和@filepath{.rkt}转换作为其它表添加。}

@;-------------------------------------------------------------------
@specsubform/subs[#:literals (submod)
                  (@#,elemtag["submod"]{@racket[submod]} base element ...+)
                  ([base module-path
                         "."
                         ".."]
                   [element id
                            ".."])]{

是指一个@racket[base]子模块。@racket[element]序列在@racket[submod]指定了一个子模块名称的路径以到达最终的子模块之间。

@examples[
  (module zoo racket
    (module monkey-house racket
      (provide monkey)
      (define monkey "Curious George")))
  (require (submod 'zoo monkey-house))
  monkey
]

使用@racket["."]作为@racket[base]在@racket[submod]代表的外围模块之间。使用@racket[".."]作为@racket[base]相当于使用@racket["."]后跟一个额外的@racket[".."]。当一个路径的表@racket[(#,(racket quote) id)]是指一个子模块，它相当于@racket[(submod "."  id)]。

使用@racket[".."]作为一种@racket[element]取消一个子模块的步骤，有效指定外围模块。例如，@racket[(submod "..")]是指封闭的子模块的模块，路径出现在其中。

@examples[
  (module zoo racket
    (module monkey-house racket
      (provide monkey)
      (define monkey "Curious George"))
    (module crocodile-house racket
      (require (submod ".." monkey-house))
      (provide dinner)
      (define dinner monkey)))
  (require (submod 'zoo crocodile-house))
  dinner
]}