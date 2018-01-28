;06.01.04.scrbl
;6.1.4 添加集合
#lang scribble/doc
@(require scribble/manual 
          scribble/eval 
          "guide-utils.rkt"
          "module-hier.rkt"
          (for-label setup/dirs
                     setup/link
                     racket/date))

@section[#:tag "link-collection"]{添加集合}

回顾《@secref["module-org"]》部分的糖果排序示例，假设@filepath{db/}和@filepath{machine/}中的模块需要一组常见的助手函数集。辅助函数可以放在一个@filepath{utils/}目录，同时模块@filepath{db/}或@filepath{machine/}可以以开始于@filepath{../utils/}的相对路径访问公用模块。只要一组模块在一个项目中协同工作，最好保持相对路径。程序员可以在不知道你的Racket配置的情况下跟踪相关路径的引用。

有些库是用于跨多个项目的，因此将库的源码保存在目录中使用是没有意义的。在这种情况下，最好的选择是添加一个新的集合。有了在一个集合中的库后，它可以通过一个封闭路径引用，就像是包括了Racket发行库的库一样。

你可以通过将文件放置在Racket安装包里或通过@racket[(get-collects-search-dirs)]报告的一个目录下添加一个新的集合。或者，你可以通过设置@envvar{PLTCOLLECTS}环境变量添加到搜索目录列表。但最好的选择，是添加一个@tech{包}。

创建包@emph{并不}意味着您必须注册一个包服务器，或者执行一个将源代码复制到归档格式中的绑定步骤。创建包只意味着使用包管理器将你的库的本地访问作为当前源码位置的集合。

例如，假设你有一个目录@filepath{/usr/molly/bakery}，它包含@filepath{cake.rkt}模块（来自于本节的@seclink["module-basics"]{开始}部分）和其它相关模块。为了使模块可以作为一个@filepath{bakery}集合获取，或者

@itemlist[

 @item{使用@exec{raco pkg}命令行工具：

@commandline{raco pkg install --link /usr/molly/bakery}

当所提供的路径包含目录分隔符时，实际上不需要@DFlag{link}标记。}

@item{从@onscreen{File}（文件）菜单使用DrRacket的DrRacket的@onscreen{Package Manager}（包管理器）项。在@onscreen{Do What I Mean}面板，点击@onscreen{Browse...}（浏览），选择@filepath{/usr/molly/bakery}目录，然后单击@onscreen{Install}（安装）。}
]

后来，@racket[(require bakery/cake)]从任何模块将从@filepath{/usr/molly/bakery/cake.rkt}输入@racket[print-cake]函数。

默认情况下，你安装的目录的名称既用作@tech{包}名称，又用作包提供的@tech{集合}。而且，包管理器通常默认只为当前用户安装，而不是在Racket安装的所有用户。有关更多信息，请参阅《Racket中的包管理》（@other-manual['(lib
"pkg/scribblings/pkg.scrbl")]）。

如果打算将库分发给其他人，请仔细选择集合和包名称。集合名称空间是分层的，但顶级集合名是全局的，包名称空间是扁平的。考虑将一次性库放在一些顶级名称，像@filepath{molly}这种标识制造者。在制作烘焙食品库的最终集合时，使用像@filepath{bakery}这样的集合名。

在你的库之后被放入一个@tech{集合}，你仍然可以使用@exec{raco make}以编译库源，但更好而且更方便的是使用@exec{raco setup}。@exec{raco setup}命令取得一个集合名（而不是文件名）并编译集合内所有的库。此外，@exec{raco setup}可以建立文档，并收集和添加文档到文档的索引，通过集合中的一个@filepath{info.rkt}模块做详细说明。有关@exec{raco setup}的详细信息请看《raco setup：安装管理器》（@secref[#:doc '(lib "scribblings/raco/raco.scrbl") "setup"]）。