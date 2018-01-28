;06.01.03.scrbl
;6.1.3 包和集合
#lang scribble/doc
@(require scribble/manual 
          scribble/eval 
          "guide-utils.rkt"
          "module-hier.rkt"
          (for-label setup/dirs
                     setup/link
                     racket/date))

@section[#:tag "packages-and-collections"]{包和集合}

一个@deftech{包（package）}是通过Racket包管理器安装的一组库（或者预先安装在Racket分发中）。例如，@racketmodname[racket/gui]库是由@filepath{gui}包提供的，而@racketmodname[parser-tools/lex]是由@filepath{parser-tools}库提供的。

Racket程序不直接针对@tech{包}。相反，程序通过@tech{集合（collections）}针对库，添加或删除一个包会改变可用的基于集合的库集。单个包可以为多个集合提供库，两个不同的包可以在同一集合中提供库（但不是同一个库，并且包管理器确保安装的包在该层级不冲突）。

有关包的更多信息，请参阅《@other-manual['(lib
"pkg/scribblings/pkg.scrbl")]》。