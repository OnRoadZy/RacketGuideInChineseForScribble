;07.07.01.scrbl
;7.7.1 客户管理器的组成
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "utils.rkt"
          (for-label racket/contract
                     racket/gui))

@title{客户管理器的组成}

第一个模块包含一个独立模块中的一些结构定义，以便更好地跟踪bug。

@external-file[1]

这个模块包含使用上面的程序。

@external-file[1b]

测试：

@external-file[1-test]