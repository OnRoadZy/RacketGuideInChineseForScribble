;06.scrbl
;6 模块
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "guide-utils.rkt")

@title[#:tag "modules" #:style 'toc]{模块}

模块让你把Racket代码组织成多个文件和可重用的库。

@local-table-of-contents[]

@include-section["06.01.scrbl"]

6.1 模块基础知识
    6.1.1 组织模块
    6.1.2 库集合
    6.1.3 包和集合
    6.1.4 添加集合
  6.2 模块的语法
    6.2.1 module表
    6.2.2 #lang速记法
    6.2.3 子模块
    6.2.4 主要的和测试的子模块
  6.3 模块的路径
  6.4 输入：require
  6.5 输出：provide
6.6 赋值和重定义