;09.scrbl
;9 正则表达式
#lang scribble/doc
@(require scribble/manual scribble/eval scribble/core "guide-utils.rkt")

@(define rx-eval (make-base-eval))

@title[#:tag "regexp" #:style 'toc]{正则表达式}

一个@deftech{正则表达式（regexp）}值封装一个模式，描述的是一个字符串或@tech{字节字符串（byte string）}。当你调用像@racket[regexp-match]函数时，正则表达式匹配器尝试对另一个字符串或字节字符串（一部分）匹配这种模式，我们将其称为@deftech{文本字符串（text string）}。文本字符串被视为原始文本，而不是模式。

@;---------------------------------------------------------------
@local-table-of-contents[]

@; 9.1 写regexp模式----------------------------------------
@section[#:tag "regexp-intro"]{写regexp模式}

一个字符串或@tech{字节字符串（byte string）}可以直接用作一个@tech{正则表达式（regexp）}模式，也可以@litchar{#rx}形成字面上的正则表达式值。例如，@racket[#rx"abc"]是一个基于@tech{正则表达式（regexp）}值的字符串，并且@racket[#rx"abc"]是一个基于@tech{正则表达式（regexp）}值的@tech{字节字符串（byte
string）}。或者，一个字符串或字节字符串可以以@litchar{#px}做前缀，如在@racket[#px"abc"]中一样，稍微扩展字符串中模式的语法。

在一个@tech{正则表达式（regexp）}模式的大多数角色都是相匹配的@tech{文本字符串（text string）}中出现的自己。因此，该模式@racket[#rx"abc"]匹配在演替中的一个字符串中包含的字符@litchar{a}、@litchar{b}和@litchar{c}。其它角色扮演的@deftech{元字符（metacharacters）}和字符序列作为@deftech{元序列（metasequences）}。也就是说，它们指定的东西不是字面上的自我。例如，在模@racket[#rx"a.c"]，字符@litchar{a}和@litchar{c}代表它们自己，但@tech{元字符（metacharacter）}@litchar{.}可以匹配任何字符。因此，该模式@racket[#rx"a.c"]在继承中匹配一个@litchar{a}、任意字符和@litchar{c}。

如果我们需要匹配字符@litchar{.}本身，我们可以在它前面加上一个@litchar{\}。字符序列@litchar{\.}结果就是一个@tech{元序列（metasequence）}，因为它不匹配它本身而只是@litchar{.}。所以，在继承里匹配@litchar{a}、@litchar{.}和@litchar{c}，我们使用正则表达式模@racket[#rx"a\\.c"]。双 @litchar{\}字符是一个Racket字符串神器，它不是@tech{正则表达式（regexp）}模式自己的。

@racket[regexp-quote]函数接受一个字符串或字节字符串并产生一个@tech{正则表达式（regexp）}值。当你使用@racket[regexp]构建模式以匹配多个字符串，因为一个模式在它可以被使用在一个匹配之前被编译成了一个@tech{正则表达式（regexp）}值。这个@racket[pregexp]函数就像@racket[regexp]，但使用扩展语法。尽管当它们可读，作为带@litchar{#rx}或@litchar{#px}的字面形式的正则表达式值被编译一次。

@racket[regexp-quote]函数接受任意的字符串并返回一个模式匹配原始字符串。特别是，在输入字符串中的字符，可以作为正则表达式元字符用一个反斜杠转义，所以只有它们自己使他们安全地匹配。

@interaction[
#:eval rx-eval
(regexp-quote "cons")
(regexp-quote "list?")
]

@racket[regexp-quote]函数在从一个混合的@tech{正则表达式（regexp）}字符串和字面的字符串构建一个完整的@tech{正则表达式（regexp）}是有用的。

@; 9.2 匹配正则表达式模式----------------------------------------
@section[#:tag "regexp-match"]{匹配正则表达式模式}

@racket[regexp-match-positions]函数接受一个@tech{正则表达（regexp）}模式和一个@tech{文本字符串（text string）}，如果正则表达式匹配（某部分）@tech{文本字符串（text string）}则返回一个匹配，或如果正则表达式不匹配字符串则返回@racket[#f]。成功匹配生成一个@deftech{索引配对（index pairs）}列表。

@examples[
#:eval rx-eval
(regexp-match-positions #rx"brain" "bird")
(regexp-match-positions #rx"needle" "hay needle stack")
]

在第二个例子中，整数@racket[4]和@racket[10]确定匹配的子串。@racket[4]是起始（包含）索引，@racket[10]是匹配子字符串的结尾（不包含）索引：

@interaction[
#:eval rx-eval
(substring "hay needle stack" 4 10)
]

第一个例子中，@racket[regexp-match-positions]的返回列表只包含一个索引对，和这索引对代表由正则表达式匹配整个字符串。当我们论述了@tech{子模式（subpatterns）}后，我们将看到一个匹配操作可以产生一个列表的@tech{子匹配（submatch）}。

@racket[regexp-match-positions]函数需要可选第三和第四个参数指定的@tech{文本字符串（text string）}的匹配应该发生的指标。

@interaction[
#:eval rx-eval
(regexp-match-positions 
 #rx"needle" 
 "his needle stack -- my needle stack -- her needle stack"
 20 39)
]


注意，返回的索引仍然与全@tech{文字符串（text string）}相对应。

@racket[regexp-match]函数类似于@racket[regexp-match-positions]，但它不是返回索引对，它返回匹配的子字符串：

@interaction[
#:eval rx-eval
(regexp-match #rx"brain" "bird")
(regexp-match #rx"needle" "hay needle stack")
]

当@racket[regexp-match]使用字节字符串表达式，结果是一个匹配的字节串：

@interaction[
#:eval rx-eval
(regexp-match #rx#"needle" #"hay needle stack")
]

如果在端口中有数据，则无需首先将其读取到字符串中。像@racket[regexp-match]函数可以直接匹配端口：

@interaction[
(define-values (i o) (make-pipe))
(write "hay needle stack" o)
(close-output-port o)
(regexp-match #rx#"needle" i)
]

@racket[regexp-match?]函数类似于@racket[regexp-match-positions]，但只简单地返回一个布尔值，以指示是否匹配成功：

@interaction[
#:eval rx-eval
(regexp-match? #rx"brain" "bird")
(regexp-match? #rx"needle" "hay needle stack")
]

@racket[regexp-split]函数有两个参数，一个@tech{正则表达式（regexp）}模式和一个文本字符串，并返回一个文本字符串的子串列表；这个模式识别分隔子字符串的分隔符。

@interaction[
#:eval rx-eval
(regexp-split #rx":" "/bin:/usr/bin:/usr/bin/X11:/usr/local/bin")
(regexp-split #rx" " "pea soup")
]

如果第一个参数匹配空字符串，那么返回所有的单个字符的子字符串列表。

@interaction[
#:eval rx-eval
(regexp-split #rx"" "smithereens")
]

因此，确定一个或多个空格作为分隔符，请注意使用正则表达@racket[#rx"\u20+"]，而不是@racket[#rx"\u20*"]。

@interaction[
#:eval rx-eval
(regexp-split #rx" +" "split pea     soup")
(regexp-split #rx" *" "split pea     soup")
]

@racket[regexp-replace]函数用另一个字符串替换文本字符串匹配的部分。第一个参数是模式，第二个参数是文本字符串，第三个参数是要插入的字符串，或者一个将匹配转换为插入字符串的过程。

@interaction[
#:eval rx-eval
(regexp-replace #rx"te" "liberte" "ty") 
(regexp-replace #rx"." "racket" string-upcase)
]

如果该模式没有出现在这个文本字符串中，返回的字符串与文本字符串相同。

@interaction[
#:eval rx-eval
(regexp-replace* #rx"te" "liberte egalite fraternite" "ty")
(regexp-replace* #rx"[ds]" "drracket" string-upcase)
]

@; 9.3 基本申明----------------------------------------
@section[#:tag "regexp-assert"]{基本申明}

论断@deftech{assertions} @litchar{^}和@litchar{$}分别标识文本字符串的开头和结尾，它们确保对它们临近的一个或其它文本字符串的结束正则表达式匹配：

@interaction[
#:eval rx-eval
(regexp-match-positions #rx"^contact" "first contact")
]

以上@tech{正则表达式（regexp）}匹配失败是因为@litchar{contact}没有出现在文本字符串的开始。在

@interaction[
#:eval rx-eval
(regexp-match-positions #rx"laugh$" "laugh laugh laugh laugh")
]

中，正则表达式匹配的@emph{最后（last）}的@litchar{laugh}。

元序列@litchar{\b}坚称一个字的范围存在，但这元序列只能与@litchar{#px}语法一起工作。在

@interaction[
#:eval rx-eval
(regexp-match-positions #px"yack\\b" "yackety yack")
]

里，@litchar{yackety}中的@litchar{yack}不在字边界结束，所以不匹配。第二@litchar{yack}在字边界结束，所以匹配。

元序列@litchar{\B}（也只有@litchar{#px}）对@litchar{\b}有相反的影响；它断言字边界不存在。在

@interaction[
#:eval rx-eval
(regexp-match-positions #px"an\\B" "an analysis")
]

里，@litchar{an}不在字边界结束，是匹配的。

@; 9.4 字符和字符类----------------------------------------
@section[#:tag "regexp-chars"]{字符和字符类}

通常，在正则表达式中的字符匹配相同文本字符串中的字符。有时使用正则表达式@tech{元序列（metasequence）}引用单个字符是有必要的或方便的。例如，元序列@litchar{\.}匹配句点字符。

@tech{元字符（metacharacter）}@litchar{.}匹配@emph{任意（any）}字符（除了在@tech{多行模式（multi-line mode）}中换行，参见《@secref["regexp-cloister"]》（Cloisters））：

@interaction[
#:eval rx-eval
(regexp-match #rx"p.t" "pet")
]

上面的模式也匹配@litchar{pat}、@litchar{pit}、@litchar{pot}、@litchar{put}和@litchar{p8t}，但不匹配@litchar{peat}或@litchar{pfffft}。

@deftech{字符类（character class）}匹配来自于一组字符中的任何一个字符。一个典型的格式，这是@deftech{括号字符类（bracketed
character class）}@litchar{[}...@litchar{]}，它匹配任何一个来自包含在括号内的非空序列的字符。因此，@racket[#rx"p[aeiou]t"]匹配@litchar{pat}、@litchar{pet}、@litchar{pit}、@litchar{pot}、@litchar{put}，别的都不匹配。

在括号内，一个@litchar{-}介于两个字符之间指定字符之间的Unicode范围。例如，@racket[#rx"ta[b-dgn-p]"]匹配@litchar{tab}、@litchar{tac}、@litchar{tad}、@litchar{tag}、@litchar{tan}、@litchar{tao}和@litchar{tap}。

在左括号后一个初始的@litchar{^}将通过剩下的内容反转指定的集合；@emph{也就是说}，它指定识别在括号内字符集以外的字符集。例如，@racket[#rx"do[^g]"]匹配所有以 @litchar{do}开始但不是@litchar{dog}的三字符序列。

注意括号内的@tech{元字符（metacharacter）}@litchar{^}，它在括号里边的意义与在外边的意义截然不同。大多数其它的@tech{元字符（metacharacters）}（@litchar{.}、@litchar{*}、@litchar{+}、@litchar{?}，等等）当在括号内的时候不再是@tech{元字符（metacharacters）}，即使你一直不予承认以求得内心平静。一个@litchar{-}是一个@tech{元字符（metacharacter）}，仅当它在括号内并且当它既不是括号之间的第一个字符也不是最后一个字符时。

括号内的字符类不能包含其它括号字符类（虽然它们包含字符类的某些其它类型，见下）。因此，在一个括号内的字符类里的一个@litchar{[}不必是一个元字符；它可以代表自身。比如，@racket[#rx"[a[b]"]匹配@litchar{a}、@litchar{[}和@litchar{b}。

此外，由于空括号字符类是不允许的，一个@litchar{]}在开左括号后立即出现也不比是一个元字符。比如，@racket[#rx"[]ab]"]匹配@litchar{]}、@litchar{a}和@litchar{b}。

@; 9.4.1 常用的字符类----------------------------------
@subsection[#:tag "some-frequently-used-character-classes"]{常用的字符类}

在@litchar{#px}语法里，一些标准的字符类可以方便地表示为元序列以代替明确的括号内的表达式：@litchar{\d}匹配一个数字（与@litchar{[0-9]}同样）；@litchar{\s}匹配一个ASCII空白字符；而@litchar{\w}匹配一个可以是“字（word）”的一部分的字符。

这些元序列的大写版本代表相应的字符类的反转：@litchar{\D}匹配一个非数字，@litchar{\S}匹配一个非空格字符，而@litchar{\W}匹配一个非“字（word）”字符。

在把这些元序列放进一个Racket字符串里时，记得要包含一个双反斜杠：

@interaction[
#:eval rx-eval
(regexp-match #px"\\d\\d" 
 "0 dear, 1 have 2 read catch 22 before 9")
]

这些字符类可以在括号表达式中使用。比如，@racket[#px"[a-z\\d]"]匹配一个小写字母或数字。

@; 9.4.2 POSIX字符类-------------------------------------
@subsection[#:tag "POSIX-character-classes"]{POSIX字符类}

一个@deftech{POSIX（可移植性操作系统接口）字符类（character class）}是一种特殊的表@litchar{[:}...@litchar{:]}的@tech{元序列（metasequence）}，它只能用在 @litchar{#px}语法中的一个括号表达式内。POSIX类支持

@itemize[#:style (make-style "compact" null)

 @item{@litchar{[:alnum:]} --- ASCII letters and digits}

 @item{@litchar{[:alpha:]} --- ASCII letters}

 @item{@litchar{[:ascii:]} --- ASCII characters}

 @item{@litchar{[:blank:]} --- ASCII widthful whitespace: space and tab}

 @item{@litchar{[:cntrl:]} --- ``control'' characters: ASCII 0 to 32}

 @item{@litchar{[:digit:]} --- ASCII digits, same as @litchar{\d}}

 @item{@litchar{[:graph:]} --- ASCII characters that use ink}

 @item{@litchar{[:lower:]} --- ASCII lower-case letters}

 @item{@litchar{[:print:]} --- ASCII ink-users plus widthful whitespace}

 @item{@litchar{[:space:]} --- ASCII whitespace, same as @litchar{\s}}

 @item{@litchar{[:upper:]} --- ASCII upper-case letters}

 @item{@litchar{[:word:]} --- ASCII letters and @litchar{_}, same as @litchar{\w}}

 @item{@litchar{[:xdigit:]} --- ASCII hex digits}

]

例如，@racket[#px"[[:alpha:]_]"]匹配一个字母或下划线

@interaction[
#:eval rx-eval
(regexp-match #px"[[:alpha:]_]" "--x--")
(regexp-match #px"[[:alpha:]_]" "--_--")
(regexp-match #px"[[:alpha:]_]" "--:--")
]

POSIX类符号@emph{只（only）}适用于在括号表达式内。例如，@litchar{[:alpha:]}，当不在括号表达式内时，不会被当做字母类读取。确切地说，它是（从以前的原则）包含字符:@litchar{:}、@litchar{a}、@litchar{l}、@litchar{p}、@litchar{h}的字符类。

@interaction[
#:eval rx-eval
(regexp-match #px"[:alpha:]" "--a--")
(regexp-match #px"[:alpha:]" "--x--")
]

@; 9.5 量词----------------------------------------
@section[#:tag "regexp-quant"]{量词}

@deftech{量词（quantifier）} @litchar{*}、 @litchar{+}和 @litchar{?}分别匹配：前面的子模式的零个或多个，一个或多个以及零个或一个实例。

@interaction[
#:eval rx-eval
(regexp-match-positions #rx"c[ad]*r" "cadaddadddr")
(regexp-match-positions #rx"c[ad]*r" "cr")

(regexp-match-positions #rx"c[ad]+r" "cadaddadddr")
(regexp-match-positions #rx"c[ad]+r" "cr")

(regexp-match-positions #rx"c[ad]?r" "cadaddadddr")
(regexp-match-positions #rx"c[ad]?r" "cr")
(regexp-match-positions #rx"c[ad]?r" "car")
]

在@litchar{#px}语法里，你可以使用括号指定比@litchar{*}、@litchar{+}、@litchar{?}更精细的调整量：

@itemize[
 @item{量词@litchar["{"]@math{m}@litchar["}"]@emph{精确（exactly）}匹配前面@tech{子模式(subpattern)}的@math{m}实例；@math{m}必须是一个非负整数。}

@item{量词@litchar["{"]@math{m}@litchar{,}@math{n}@litchar["}"]匹配至少@math{m}并至多@math{n}个实例。@litchar{m}和@litchar{n}是非负整数，@math{m}小于或等于@math{n}。你可以省略一个或两个都省略，在这种情况下@math{m}默认为@math{0}，@math{n}到无穷大。}
]

很明显，@litchar{+}和@litchar{?}是@litchar{{1,}}和@litchar{{0,1}}的缩写，@litchar{*}是@litchar{{,}}的缩写，这和@litchar{{0,}}一样。

@interaction[
#:eval rx-eval
(regexp-match #px"[aeiou]{3}" "vacuous")
(regexp-match #px"[aeiou]{3}" "evolve")
(regexp-match #px"[aeiou]{2,3}" "evolve")
(regexp-match #px"[aeiou]{2,3}" "zeugma")
]

迄今为止所描述的量词都是@deftech{贪婪的（greedy）}：它们匹配最大的实例数，还会导致对整个模式的总体匹配。

@interaction[
#:eval rx-eval
(regexp-match #rx"<.*>" "<tag1> <tag2> <tag3>")
]

为了使这些量词为@deftech{非贪婪的（non-greedy）}，给它们追加@litchar{?}。非贪婪量词匹配满足需要的最小实例数，以确保整体匹配。

@interaction[
#:eval rx-eval
(regexp-match #rx"<.*?>" "<tag1> <tag2> <tag3>")
]

非贪婪量词分别为：@litchar{*?}、@litchar{+?}、@litchar{??}、@litchar["{"]@math{m}@litchar["}?"]、@litchar["{"]@math{m}@litchar{,}@math{n}@litchar["}?"]。注意匹配字符@litchar{?}的这两种使用。

@; 9.6 聚类----------------------------------------
@section[#:tag "regexp-clusters"]{聚类}

@deftech{聚类（Clustering）}——文内的括号@litchar{(}...@litchar{)}——确定封闭@deftech{子模式（subpattern）}作为一个单一的实体。它使匹配去捕获@deftech{子匹配项（submatch）}，或字符串的一部分匹配子模式，除了整体匹配之外：

@interaction[
#:eval rx-eval
(regexp-match #rx"([a-z]+) ([0-9]+), ([0-9]+)" "jan 1, 1970")
]

聚类也导致以下量词对待整个封闭的模式作为一个实体：

@interaction[
#:eval rx-eval
(regexp-match #rx"(pu )*" "pu pu platter")
]

返回的匹配项数量总是等于指定的正则表达式子模式的数量，即使一个特定的子模式恰好匹配多个子字符串或根本没有子串。

@interaction[
#:eval rx-eval
(regexp-match #rx"([a-z ]+;)*" "lather; rinse; repeat;")
]

在这里，@litchar{*}量化子模式匹配的三次，但这是返回的最后一个匹配项。

对一个量化的模式来说不匹配也是可能的，甚至是对整个模式匹配。在这种情况下，失败的匹配项通过@racket[#f]体现。

@interaction[
#:eval rx-eval
(define date-re
  (code:comment @#,t{match `month year' or `month day, year';})
  (code:comment @#,t{subpattern matches day, if present})
  #rx"([a-z]+) +([0-9]+,)? *([0-9]+)")
(regexp-match date-re "jan 1, 1970")
(regexp-match date-re "jan 1970")
]

@; 9.6.1 后向引用-----------------------------------------------
@subsection[#:tag "backreferences"]{后向引用}

@tech{子匹配（Submatch）}可用于插入字符串参数的@racket[regexp-replace]和@racket[regexp-replace*]程序。插入的字符串可以使用@litchar{\}@math{n}为@deftech{后向引用（backreference）}返回第@math{n}个匹配项，这是子字符串，它匹配第@math{n}个子模式。一个@litchar{\0}引用整个匹配，它也可以指定为@litchar{\&}。

@interaction[
#:eval rx-eval
(regexp-replace #rx"_(.+?)_" 
  "the _nina_, the _pinta_, and the _santa maria_"
  "*\\1*")
(regexp-replace* #rx"_(.+?)_" 
  "the _nina_, the _pinta_, and the _santa maria_"
  "*\\1*")

(regexp-replace #px"(\\S+) (\\S+) (\\S+)"
  "eat to live"
  "\\3 \\2 \\1")
]

使用@litchar{\\}在插入字符串指定转义符。同时，@litchar{\$}代表空字符串，并且对从紧随其后的数字分离后向引用@litchar{\}@math{n}是有用的。

反向引用也可以用@litchar{#px}模式以返回模式中的一个已经匹配的子模式。@litchar{\}@math{n}代表第@math{n}个子匹配的精确重复。注意这个@litchar{\0}，它在插入字符串是有用的，在regexp模式内没有道理，因为整个正则表达式不匹配而无法回到它。

@interaction[
#:eval rx-eval
(regexp-match #px"([a-z]+) and \\1"
              "billions and billions")
]

注意，@tech{后向引用（backreference）}不是简单地重复以前的子模式。而这是一个特别的被子模式所匹配的子串的重复 。

在上面的例子中，@tech{后向引用（backreference）}只能匹配@litchar{billions}。它不会匹配@litchar{millions}，即使子模式追溯到——@litchar{([a-z]+)}——这样做会没有问题：

@interaction[
#:eval rx-eval
(regexp-match #px"([a-z]+) and \\1"
              "billions and millions")
]

下面的示例标记数字字符串中所有立即重复的模式：

@interaction[
#:eval rx-eval
(regexp-replace* #px"(\\d+)\\1"
  "123340983242432420980980234"
  "{\\1,\\1}")
]

下面的示例修正了两个字：

@interaction[
#:eval rx-eval
(regexp-replace* #px"\\b(\\S+) \\1\\b"
  (string-append "now is the the time for all good men to "
                 "to come to the aid of of the party")
  "\\1")
]

@; 9.6.2 非捕捉簇---------------------------------------
@subsection[#:tag "non-capturing-clusters"]{非捕捉簇}

它通常需要指定一个簇（通常为量化）但不触发@tech{子匹配（submatch）}项的信息捕捉。这种簇称为@deftech{非捕捉（non-capturing）}。要创建非簇，请使用@litchar{(?:}以代替@litchar{(}作为簇开启器。

在下面的例子中，一个非簇消除了“目录”部分的一个给定的UNIX路径名，并获取簇标识。

@interaction[
#:eval rx-eval
(regexp-match #rx"^(?:[a-z]*/)*([a-z]+)$" 
              "/usr/local/bin/racket")
]

@; 9.6.3 回廊--------------------------------------------------
@subsection[#:tag "regexp-cloister"]{回廊}

一个非捕捉簇@litchar{?}和@litchar{:}之间的位置称为@deftech{回廊（cloister）}。你可以把修饰符放在这儿，有可能会使簇@tech{子模式（subpattern）}被特别处理。这个修饰符@litchar{i}使子模式匹配时不区分大小写：

@interaction[
#:eval rx-eval
(regexp-match #rx"(?i:hearth)" "HeartH")
]

修饰符@litchar{m}使@tech{子模式subpattern）}在@deftech{多行模式（multi-line mode）}匹配，在@litchar{.}的位置不匹配换行符，@litchar{^}仅在一个新行后可以匹配，而@litchar{$}仅在一个新行前可以匹配。

@interaction[
#:eval rx-eval
(regexp-match #rx"." "\na\n")
(regexp-match #rx"(?m:.)" "\na\n")
(regexp-match #rx"^A plan$" "A man\nA plan\nA canal")
(regexp-match #rx"(?m:^A plan$)" "A man\nA plan\nA canal")
]

你可以在回廊里放置多个修饰符：

@interaction[
#:eval rx-eval
(regexp-match #rx"(?mi:^A Plan$)" "a man\na plan\na canal")
]

在修饰符前的一个减号反转它的意思。因此，你可以在@deftech{子类（subcluster）}中使用@litchar{-i}以翻转案例不由封闭簇造导致。

@interaction[
#:eval rx-eval
(regexp-match #rx"(?i:the (?-i:TeX)book)"
              "The TeXbook")
]

上述正表达式将允许任何针对@litchar{the}和@litchar{book}的外壳，但它坚持认为@litchar{TeX}有不同的包装。

@; 9.7 替代----------------------------------------
@section[#:tag "regexp-alternation"]{替代}

你可以通过用@litchar{|}分隔它们来指定@emph{替代（alternate）}@tech{子模式（subpatterns）}的列表。在最近的封闭簇里@litchar{|}分隔@tech{子模式（subpatterns）}（或在整个模式字符串里，假如没有封闭括号）。

@interaction[
#:eval rx-eval
(regexp-match #rx"f(ee|i|o|um)" "a small, final fee")
(regexp-replace* #rx"([yi])s(e[sdr]?|ing|ation)"
                 (string-append
                  "analyse an energising organisation"
                  " pulsing with noisy organisms")
                 "\\1z\\2")
]

不过注意，如果你想使用簇仅仅是指定替代子模式列表，却不想指定匹配项，那么使用@litchar{(?:}代替@litchar{(}。

@interaction[
#:eval rx-eval
(regexp-match #rx"f(?:ee|i|o|um)" "fun for all")
]

注意替代的一个重要事情是，最左匹配替代不管长短 。因此，如果一个替代是后一个替代的前缀，后者可能没有机会匹配。

@interaction[
#:eval rx-eval
(regexp-match #rx"call|call-with-current-continuation" 
              "call-with-current-continuation")
]

为了让较长的替代在匹配中有一个镜头，把它放在较短的一个之前：

@interaction[
#:eval rx-eval
(regexp-match #rx"call-with-current-continuation|call"
              "call-with-current-continuation")
]

在任何情况下，对于整个正则表达式的整体匹配总是倾向于整体的不匹配。在下面这里，较长的替代仍然更好，因为它的较短的前缀不能产生整体匹配。

@interaction[
#:eval rx-eval
(regexp-match
 #rx"(?:call|call-with-current-continuation) constrained"
 "call-with-current-continuation constrained")
]

@; 9.8 回溯----------------------------------------
@section[#:tag "Backtracking"]{回溯}

我们已经明白贪婪的量词匹配的次数最多，但压倒一切的优先级才是整体匹配的成功。考虑以下内容

@interaction[
#:eval rx-eval
(regexp-match #rx"a*a" "aaaa")
]

这个正则表达式包括两个子正则表达式：@litchar{a*}，其次是@litchar{a}。子正则表达式@litchar{a*}不允许匹配文本字符串@racket[aaaa]里的所有的四个@litchar{a}，即使@litchar{*}是一个贪婪量词也一样。它可能仅匹配前面的三个，剩下最后一个给第二子正则表达式。这确保了完整的正则表达式匹配成功。

正则表达式匹配器通过一个称为@deftech{回溯（backtracking）}的过程实现来这个。匹配器暂时允许贪婪量词匹配所有四个@litchar{a}，但当整体匹配处于岌岌可危的状态变得清晰时，它@emph{回溯（backtracks）}到一个不那么贪婪的三个@litchar{a}的匹配。如果这也失败了，与以下调用一样

@interaction[
#:eval rx-eval
(regexp-match #rx"a*aa" "aaaa")
]

匹配器回溯甚至更进一步。只有当所有可能的回溯尝试都没有成功时，整体失败才被承认。

回溯并不局限于贪婪量词。非贪婪量词匹配尽可能少的情况下，为了达到整体匹配，逐步回溯会有越来越多的实例。这里替代的回溯也更有向右替代的倾向，当局部成功的向左替代一旦失败则会产生一个整体的匹配。

有时禁用回溯是有效的。例如，我们可能希望作出选择，或者我们知道尝试替代是徒劳的。一个非回溯正则表达式在@litchar{(?>}...@litchar{)}里是封闭的。

@interaction[
#:eval rx-eval
(regexp-match #rx"(?>a+)." "aaaa")
]

在这个调用里，子正则表达式@litchar{?>a+}贪婪地匹配所有四个@litchar{a}，并且回溯的机会被拒绝。因此，整体匹配被拒绝。这个正则表达式的效果因此对一个或多个@litchar{a}的匹配被某些明确@litchar{非a（non-a）}的予以继承。

@; 9.9 前后查找----------------------------------------
@section[#:tag "looking-ahead-and-behind"]{前后查找}

在你的模式里你可以有判断，@emph{前面（ahead）}或@emph{后面（behind）}查找以确认子模式是否出现。这些“围绕查找”的判断通过设置子模式检查一个簇，它的主要字符是：@litchar{?=}（正向前查找），@litchar{?!}（负向前查找），@litchar{?<=}（正向后查找），@litchar{?<!}（负向后查找）。注意，认定的子模式没有在最终结果里生成一个匹配；它只允许或不允许剩余的匹配。

@; 9.9.1 向前查找--------------------------------------------
@subsection[#:tag "Lookahead"]{向前查找}

用@litchar{?=}正向前查找窥探以提前确保其子模式能够匹配。

@interaction[
#:eval rx-eval
(regexp-match-positions #rx"grey(?=hound)" 
  "i left my grey socks at the greyhound") 
]

正则表达式@racket[#rx"grey(?=hound)"]匹配@litchar{grey}，但@emph{仅仅}如果它后面紧跟着@litchar{hound}时成立。因此，文本字符串中的第一个@litchar{grey}不匹配。

用@litchar{?!}反向前查找窥探以提前确保其子模式@emph{不可能}匹配。

@interaction[
#:eval rx-eval
(regexp-match-positions #rx"grey(?!hound)"
  "the gray greyhound ate the grey socks") 
]

正则表达式@racket[#rx"grey(?!hound)"]匹配@litchar{grey}，但只有@litchar{hound}@emph{不}跟着它才行。因此@litchar{grey}仅仅在@litchar{socks}之前才匹配。

@; 9.9.2 向后查找-----------------------------
@subsection[#:tag "lookbehind"]{向后查找}

用@litchar{?<=}正向后查找检查其子模式@emph{可以}立即向文本字符串的当前位置左侧匹配。

@interaction[
#:eval rx-eval
(regexp-match-positions #rx"(?<=grey)hound"
  "the hound in the picture is not a greyhound") 
]

正则表达式@racket[#rx"(?<=grey)hound"]匹配@litchar{hound}，但前提是它是先于@litchar{grey}的。

用@litchar{?<!}负向后查找检查它的子模式不可能立即匹配左侧。

@interaction[
#:eval rx-eval
(regexp-match-positions #rx"(?<!grey)hound"
  "the greyhound in the picture is not a hound")
]

正则表达式@racket[#rx"(?<!grey)hound"]匹配@litchar{hound}，但前提是它@emph{不是}先于@litchar{grey}的。

向前查找和向后查找在它们不混淆时可以是实用的。

@; 9.10 一个扩展示例----------------------------------------
@section[#:tag "an-extended-example"]{一个扩展示例}

@(define ex-eval (make-base-eval))

这是一个从@italic{《Friedl’s Mastering Regular Expressions》}（189页）来的扩展的例子，涵盖了本章中介绍的许多特征。问题是要修饰一个正则表达式，它将匹配任何且唯一的IP地址或@emph{点缀四周（dotted quads）}：四个数字被三个点分开，每个数字在0和255之间。

首先，我们定义了一个子正则表达式@racket[n0-255]以匹配0到255：

@interaction[
#:eval ex-eval
(define n0-255
  (string-append
   "(?:"
   "\\d|"        (code:comment @#,t{  0 through   9})
   "\\d\\d|"     (code:comment @#,t{ 00 through  99})
   "[01]\\d\\d|" (code:comment @#,t{000 through 199})
   "2[0-4]\\d|"  (code:comment @#,t{200 through 249})
   "25[0-5]"     (code:comment @#,t{250 through 255})
   ")"))
]

前两个替代只得到所有的一位数和两位数。因为0-padding是允许的，我们要匹配1和01。我们当得到3位数字时要小心，因为数字255以上必须排除。因此，我们的修饰替代，得到000至199，然后200至249，最后250至255。

IP地址是一个字符串，包括四个@racket[n0-255]用三个点分隔。

@interaction[
#:eval ex-eval
(define ip-re1
  (string-append
   "^"        (code:comment @#,t{前面什么都没有})
   n0-255     (code:comment @#,t{第一个@racket[n0-255],})
   "(?:"      (code:comment @#,t{接着是子模式})
   "\\."      (code:comment @#,t{被一个点跟着})
   n0-255     (code:comment @#,t{一个 @racket[n0-255],})
   ")"        (code:comment @#,t{它被})
   "{3}"      (code:comment @#,t{恰好重复三遍})
   "$"))      (code:comment @#,t{后边什么也没有})
]

让我们试试看：

@interaction[
#:eval ex-eval
(regexp-match (pregexp ip-re1) "1.2.3.4")
(regexp-match (pregexp ip-re1) "55.155.255.265")
]

这很好，除此之外我们还有

@interaction[
#:eval ex-eval
(regexp-match (pregexp ip-re1) "0.00.000.00")
]

所有的零序列都不是有效的IP地址！用向前查找救援。在开始匹配@racket[ip-re1]之前，我们向前查找以确保我们没有零。我们可以用正向前查找以确保@emph{是}一个非零的数字。

@interaction[
#:eval ex-eval
(define ip-re
  (pregexp
   (string-append
     "(?=.*[1-9])" (code:comment @#,t{ensure there's a non-0 digit})
     ip-re1)))
]

或者我们可以用负前查找确保前面不是@emph{只}由零和点组成。

@interaction[
#:eval ex-eval
(define ip-re
  (pregexp
   (string-append
     "(?![0.]*$)" (code:comment @#,t{not just zeros and dots})
                  (code:comment @#,t{(note: @litchar{.} is not metachar inside @litchar{[}...@litchar{]})})
     ip-re1)))
]

正则表达式@racket[ip-re]会匹配所有的并且唯一的IP地址。

@interaction[
#:eval ex-eval
(regexp-match ip-re "1.2.3.4")
(regexp-match ip-re "0.0.0.0")
]

@close-eval[ex-eval]
@close-eval[rx-eval]