;06.01.01.scrbl
;6.1.1 组织模块
#lang scribble/doc
@(require scribble/manual 
          scribble/eval 
          "guide-utils.rkt"
          "module-hier.rkt"
          (for-label setup/dirs
                     setup/link
                     racket/date))
@section[#:tag "module-org"]{组织模块}

@filepath{cake.rkt}和@filepath{random-cake.rkt}示例演示如何组织一个程序模块的最常用的方法：把所有的模块文件在一个目录（也许是子目录），然后有模块通过相对路径相互引用。模块目录可以作为一个项目，因为它可以在文件系统上移动或复制到其它机器上，而相对路径则保存模块之间的连接。

另一个例子，如果你正在开发一个糖果分类程序，你可能有一个主要的@filepath{sort.rkt}模块，使用其他模块访问糖果数据库和控制分拣机。如果糖果数据库模块本身被组织成子模块以处理条码和厂家信息，那么数据库模块可以是@filepath{db/lookup.rkt}，它使用辅助模块@filepath{db/barcodes.rkt}和@filepath{db/makers.rkt}。同样，分拣机驱动程序@filepath{machine/control.rkt}可能会使用辅助模块@filepath{machine/sensors.rkt}和@filepath{machine/actuators.rkt}。

@centerline[module-hierarchy]

@filepath{sort.rkt}模块使用相对路径@filepath{db/lookup.rkt}和@filepath{machine/control.rkt}从数据库和机器控制库导入：

@racketmod[
#:file "sort.rkt"
racket
(require "db/lookup.rkt" "machine/control.rkt")
....]

@filepath{db/lookup.rkt}模块类似地使用相对路径给它自己的源码以访问@filepath{db/barcodes.rkt}和@filepath{db/makers.rkt}模块：

@racketmod[
#:file "db/lookup.rkt"
racket
(require "barcode.rkt" "makers.rkt")
....]

同上，@filepath{machine/control.rkt}：

@racketmod[
#:file "machine/control.rkt"
racket
(require "sensors.rkt" "actuators.rkt")
....]

Racket工具所有运行都自动使用相对路径。例如，

@commandline{racket sort.rkt}

在命令行运行@filepath{sort.rkt}程序和自动加载并编译所需的模块。对于一个足够大的程序，从源码编译可能需要很长时间，所以使用

@commandline{raco make sort.rkt}

编译@filepath{sort.rkt}及其所有依赖成为字节码文件。如果字节码文件存在，运行@exec{racket sort.rkt}，将自动使用字节码文件。