;06.01.02.scrbl
;6.1.2 库集合
#lang scribble/doc
@(require scribble/manual 
          scribble/eval 
          "guide-utils.rkt"
          "module-hier.rkt"
          (for-label setup/dirs
                     setup/link
                     racket/date))

@title{库集合}

一个 @deftech{集合（collection）}是已安装的库模块的按等级划分的组。一个@deftech{集合}中的模块通过一个引号引用，无后缀路径。例如，下面的模块引用@filepath{date.rkt}库，它是部分@filepath{racket}@deftech{集合}的一部分：

@racketmod[
racket

(require racket/date)

(printf "Today is ~s\n"
        (date->string (seconds->date (current-seconds))))
]

当搜索在线Racket文档时，搜索结果显示提供每个绑定的模块。或者，如果通过单击超链接到达绑定文档，则可以在绑定名称上悬停以查找哪些模块提供了它。

一个模块的引用，像@racketmodname[racket/date]，看起来像一个标识符，但它并不是和@racket[printf]或@racket[date->string]相同的方式对待。相反，当@racket[require]发现一个被引号包括的模块的引用，它转化这个引用为基于集合的路径：

@itemlist[
 @item{首先，如果这个引用路径不包含@litchar{/}，那么@racket[require]自动添加一个@filepath{/main}给参考。例如，@racket[(require
       @#,racketmodname[slideshow])]相当于@racket[(require
       slideshow/main)]。}

@item{其次，@racket[require]隐式添加@filepath{.rkt}后缀给路径。}

@item{最后，@racket[require]通过在已安装的@deftech{集合}中搜索路径来决定路径，而不是将路径处理为相对于封闭模块的路径。}
]

作为一个最近似情况，@deftech{集合}作为文件系统目录实现。例如，@filepath{racket}集合大多位于Racket安装的@filepath{collects}目录中的@filepath{racket}目录中，如以下报告：

@racketmod[
racket

(require setup/dirs)

(build-path (find-collects-dir) (code:comment @#,t{main collection directory})
            "racket")
]

然而，Racket安装的@filepath{collects}目录仅仅是一个@racket[require]寻找目录集合的地方。其它地方包括用户指定的通过@racket[(find-user-collects-dir)]报告的目录以及通过@envvar{PLTCOLLECTS}搜索路径配置的目录。最后，最典型的是，通过安装@tech{包（packages）}找到集合。