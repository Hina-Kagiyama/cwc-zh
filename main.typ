#import "ruby.typ": ruby
#import "align-marker-with-baseline.typ": *
#show: align-list-marker-with-baseline
#show: align-enum-marker-with-baseline

#show heading: it => {
    set text(weight: "regular")
    v(2em, weak: true) + it + line(length: measure(it).width, start: (0%, -1%))
}

// header

#set text(font: ("Georgia", "FangSong"))
#set par(first-line-indent: (amount: 2em, all: true))
#set heading(numbering: "1.1.")
#set page(margin: 2em, paper: "a4")

#align(center)[#text(size: 2em)[CPS]]
#align(right)[_Last Update: #datetime.today().display()_]
#line(length: 100%)

#set page(numbering: "1 / 1")
#counter(page).update(1)

#{
  set page(numbering: "i")
  show heading.where(level: 1): it => {
    set align(center)
    set text(font: "Georgia")
    it + line(length: 100%) + v(1em)
  }
  outline() + v(1em) + line(length: 100%)
}

// document here

#counter(heading).update(0)

#{
show heading.where(level: 1): it => {
  set align(center)
  set text(font: ("Georgia", "Noto Serif CJK SC"))
  counter(figure.where(kind: image)).update(0)
  counter(figure.where(kind: table)).update(0)
  pagebreak(weak: true) + counter(heading).display("一、") + it.body + line(length: 100%) + v(0.1em)
}
[

#{ set heading(numbering: none); [= Acknowledgement<ack>] }

#counter(page).update(1)

本书@appel1992compiling 所描述的编译器——New Jersey 版本的 Standard
ML（SML/NJ）——是众多开发者共同努力的成果。David B. MacQueen 和我于 1986
年开始了这一项目，最初的计划是在大约一年的时间内开发一个 Standard ML
的前端，以作为进一步研究的工具。David
主要负责类型检查器和模块系统的开发；我们共同完成了解析器、抽象语法、静态环境机制以及语义分析的工作。而我则主要关注动态语义、中间表示、优化、代码生成以及运行时系统的设计与实现。

当然，最终我们在这个项目上的投入远超最初的预期，耗时超过五年。这是因为项目的目标变得更加宏大：构建一个完整、健壮、高效且可移植的
Standard ML
编程环境。如果没有众多才华横溢的开发者的帮助，我们不可能完成这一工作。按照字母顺序，他们是：

*Bruce F. Duba* 协助改进了模式匹配编译器、CPS
常量折叠阶段、内联展开阶段、寄存器溢出处理阶段以及编译器的许多其他部分。此外，他还参与了 `call with current continuation` 机制的设计。

*Adam T. Dingle* 实现了调试器的 Emacs 模式。

*Lal George* 为代码生成器添加了对浮点寄存器的支持，并显著提升了浮点运算的性能。此外，他还修复了由我和其他人引入的一些棘手的错误。

*Trevor Jim* 参与了 CPS
表示的设计，并实现了模式匹配编译器和闭包转换阶段，以及最初的浮点函数库和外部原始函数的汇编语言实现。

*James S. Mattson* 实现了用于构建编译器的首个词法分析器生成器。

*James W. O’Toole* 实现了 NS32032 代码生成器。

*Norman Ramsey* 实现了 MIPS 代码生成器。

*John H. Reppy* 对运行时系统进行了多次改进和重写。他实现了信号处理机制，优化了 `call with current continuation` 机制，设计了当前用于调用
C
语言函数的机制，并实现了一套先进的新垃圾回收器，使运行时系统更加健壮。此外，他还实现了
SPARC 代码生成器。

*Nick Rothwell* 协助实现了独立编译机制。

*Zhong Shao* 实现了#ruby[公共子表达式消除][Common Subexpression Elimination]，并设计了使用#ruby[多寄存器续延][multiple-register continuations]以加速过程调用的#ruby[被调用者保存][callee-save]约定。

*David R. Tarditi* 改进了词法分析器生成器，并实现了用于构建前端部分的解析器生成器；他还协助实现了调试器使用的类型重构算法。此外，他与
*Anurag Acharya* 和 *Peter Lee* 共同实现了 ML 到 C 的翻译器。

*Mads Tofte* 协助实现了#ruby[分离编译机制][separate compilation mechanism]。

*Andrew P. Tolmach* 实现了 SML/NJ
调试器。此外，他还以更加函数式的风格重写了静态环境（符号表）。

*Peter Weinberger* 实现了首个版本的#ruby[复制式垃圾回收器][copying garbage collector]。

最后，我要感谢那些在本书早期草稿阶段提供了宝贵意见的同行：*Ron Cytron*、*Mary
Fernandez*、*Lal George*、*Peter Lee*、*Greg Morrisett*、*Zhong Shao*、*David
Tarditi* 和 *Andrew Tolmach*。

= 总览

ML 是一种#ruby[严格求值][strict]、#ruby[高阶][higher-order]的函数式编程语言，具有#ruby[静态检查的多态类型][statically checked polymorphic types]、#ruby[垃圾回收][garbage collection]机制，并且拥有完整的#ruby[形式化语义][formally defined semantics]。

_Standard ML of New Jersey_（SML/NJ）是 ML
语言的一个优化编译器和运行时系统。它在优化和代码生成过程中使用的一种中间表示——_续延传递风格（Continuation-Passing
Style, CPS）_，不仅适用于 ML
语言的编译，还广泛适用于许多现代编程语言的编译。本书的主题正是基于续延传递风格的编译技术。

事先了解 ML 语言对于阅读本书有所帮助，但并非必需。由于 _Standard ML of New Jersey_ 编译器本身是用
ML 语言编写的，我们会在许多示例中使用 ML
语法。不过，我们仅使用该语言的一个简单子集进行说明，并在讲解过程中逐步解释相关符号。完全不熟悉
ML 的读者可以参考附录 A 中的介绍。

== 续延传递风格（CPS）<sec1.1>

FORTRAN
的优雅之处——也是它相较于汇编语言的一个重要进步——在于它让程序员无需为中间结果命名。例如，我们可以直接写：

$ x = (a + b) times (c + d) $

而不必使用汇编语言的形式：

$
  r_1 &<- a + b \
  r_2 &<- c + d \
  x   &<- r_1 times r_2
$

这一简单的单行表达式比三行汇编代码更易读、更易理解，因为像 $r_1$ 和 $r_2$ 这样的中间变量名称并没有真正帮助我们理解计算过程。此外，汇编代码明确指定了计算的求值顺序：先计算 $a + b$，然后计算 $c + d$。但在多数情况下，这一细节并非我们真正需要关心的内容。

#ruby[_λ-演算_][lambda calculus]在处理函数值时也提供了与 FORTRAN
类似的优势。我们可以直接写：

$ f(λ x. x + 1) $

而不必像 Pascal 语言那样显式定义一个命名的函数：

#figure[```pascal
function g(x: integer): integer;
    begin g := x+1 end;
    . . . f(g) . . .
```]

在 Pascal 中，我们被迫为这个函数赋予一个名称（`g`），但这个名称（以及随之而来的冗长定义）未必能真正帮助我们理解程序的逻辑。

此外，_λ-演算_还能使我们摆脱对求值顺序的过度关注，即使在函数调用的边界之间也是如此。这种特性在简化程序表达的同时，也增强了灵活性。

这些便利性对于人类编写程序来说是非常合适的，但对于编译器处理程序时，可能恰恰相反。编译器通常希望为程序中的每个中间值赋予一个唯一的名称，以便利用这些名称进行表查找、值集合的操作、寄存器分配、指令调度等优化工作。

_续延传递风格（CPS）_ 是一种程序表示方式，它使得控制流和数据流的每个细节都变得显式可见。此外，CPS
还具有一个重要优势：它与 _#ruby[丘奇][Church]λ-演算_ 密切相关，而
λ-演算本身具有明确且公认的数学语义。

我们可以用一个示例来非正式地说明 _CPS_。先从以下源程序开始：

#figure[```sml
fun prodprimes(n) =
    if n = 1
    then 1
    else if isprime(n)
         then n * prodprimes(n - 1)
         else prodprimes(n - 1)
```]

这是一个 ML 程序，它计算小于或等于正整数 $n$ 的所有素数的乘积。关键字 `fun` 用于引入函数定义；等号右侧的表达式是函数体。`if-then-else` 语句和算术表达式的表示方式应当对大多数读者而言是熟悉的。

现在，这个程序的控制流中有几个值得命名的关键点。例如，当 `isprime` 函数被调用时，它会被传递一个返回地址，我们称其为 $k$。`isprime` 将返回一个布尔值，我们称其为 $b$。在 `then` 分支中的第一次 `prodprimes` 调用会返回到某个位置 $j$，并带有一个整数 $p$；而 `else` 分支中的第二次 `prodprimes` 调用会返回到位置 $h$，并带有整数 $q$。第一次计算 $n - 1$ 的结果会存储在变量 $m$ 中，而第二次计算的结果存入变量 $i$，依此类推。

我们还应提到，当 `prodprimes` 被调用时，它会被传递一个返回地址，我们可以称其为 $c$，并将其视为该函数的一个参数（形式参数）。然后，当函数需要返回时，我们可以使用 $c$ 来继续执行后续操作。

我们可以使用_续延_来表达这一点。#ruby[_续延_][continuation]是一个表示#quote[下一步该做什么]的函数。例如，我们可以说 `prodprimes` 作为参数之一接收一个续延 $c$，并且当 `prodprimes` 计算出其结果 $a$ 时，它将通过将 $c$ 应用于 $a$ 来继续执行。因此，函数返回的过程看起来就像是一次函数调用！

以下程序是上述程序的_续延传递风格（CPS）_版本，使用 ML 编写。对于不熟悉 ML
的读者，这里需要解释 `let ... in ... end` 结构：其中 `let` 声明函数、整数等局部值，其作用域包含 `in` 后的表达式，而 `let` 结构的最终结果就是该表达式的结果。`fun` 语句用于声明一个带有形式参数的函数，而 `val` 语句（在这个简单的示例中）用于将变量绑定到一个值。

#figure[```sml
fun prodprimes (n, c) =
  if n = 1
  then c(1)
  else let fun k (b) =
               if b = true
               then let fun j (p) =
                            let val a = n * p
                            in c(a) end
                        val m = n - 1
                     in prodprimes (m, j) end
               else let fun h(q) = c(q)
                        val i = n - 1
                     in prodprimes (i, h) end
        in isprime (n, k) end
```]

可以注意到，之前讨论的所有控制点 $c$、$k$、$j$、$h$ 都只是续延函数，而所有的数据标识符 $b$、$p$、$a$、$m$、$q$、$i$ 仅仅是变量。为了使用续延传递风格（CPS），我们并不需要大幅修改原有的表示方式；我们只是使用了该语言的一种受限形式。关于
CPS 的完整解释将在第 2 章和第 3 章中给出。

CPS 表示易于优化编译器进行操作和转换。例如，我们希望执行尾递归消除：如果函数 $f$ 在其执行的最后一步调用了函数 $g$，那么与其将 $g$ 的返回地址设为 $f$ 内部的某个地址，不如直接将 $f$ 从其调用者那里接收到的返回地址传递给 $g$。这样，当 $g$ 返回时，它会直接返回到 $f$ 的调用者，而无需额外的中间跳转。

如果我们回顾 `prodprimes` 的原始版本，会发现其中有一个尾递归调用（即 `prodprimes` 的最后一次递归调用）。在
CPS 版本中，这种尾递归的特性表现为续延函数 `h` 是平凡的，即：

#figure[```sml
fun h(q) = c(q)
```]

当我们有一个像 `h` 这样的函数，它只是简单地调用另一个函数 `c` 并传递相同的参数时，我们可以认为 `h` 等价于 `c`，因此可以直接用 `c` 替换 `h`。这样，我们可以进行如下转换：

#{
  let a = figure[```sml
          let fun h(q) = c(q)
              val i = n - 1
            in prodprimes(i, h)
          end
          ```]
  let b = figure[```sml
          let val i = n - 1
            in prodprimes(i, c)
          end
          ```]
  figure(
    align(
      center, table(columns: 2, stroke: 0.5pt, column-gutter: 10%, table.header("转换前", "转换后"), a, b),
    ),
  )
}

这样，我们就干净利落地完成了尾递归消除。

== CPS 的优势

使用续延传递风格（CPS）作为编译和优化的框架有许多理由。在本讨论中，我们将其与几种替代方案进行比较：

- λ：λ-演算（不包含显式的续延）。对于像 ML 和 Scheme 这样“基于
  λ-演算”的语言来说，λ-演算可能是一个合适的理论工具，用于推理其行为。
- QUAD：寄存器传输（或“四元式”），大致对应于极简冯·诺伊曼机器的指令集。
- PDG：程序依赖图（Program Dependence
  Graphs），能够在尽可能减少耦合的情况下同时表示控制流和数据流。
- SSA：静态单赋值形式（Static Single Assignment, SSA @bib34，特别适用于高效实现某些数据流分析算法。在
  SSA
  中，每个变量仅被赋值一次；当控制流路径合并时，使用显式的传输函数来维持单赋值的假象。SSA
  和 CPS 在某些重要方面是相似的，因为 CPS 也具有某种单赋值特性。

这些中间表示（IRs）的设计目标各不相同，以便支持不同类型的代码转换和优化。接下来，我们将考察几种不同类型的优化，并分析在每种表示方式下，它们的实现难度如何。

=== 内联展开（In-line Expansion）

λ-演算的变量绑定和作用域规则特别适用于 #ruby[β-归约][β-reduction]，即函数的内联展开：函数体被替换为函数调用的具体实现，并且实际参数替换形式参数。

然而，使用 λ-演算 来表达#ruby[严格求值][strict call-by-value]语言（如
ML、Pascal、Lisp、Scheme、Smalltalk
等）的行为存在一些问题。在这些编程语言中，函数参数应当在函数体执行之前求值，但在
λ-演算中并不需要遵守这一规则。

按照 λ-演算的
β-归约规则，实际参数会直接替换函数体中的形式参数，但这可能会导致以下问题：

- 一个本应进入无限循环的程序（在严格求值语义下）可能会终止。
- 在原始程序中本应仅被求值一次的实际参数，可能会被求值多次（如果函数体内多次使用该参数）。
- 在具有副作用的语言（如 ML、Pascal、Lisp 等）中，实际参数的副作用可能会：
  - 发生在函数体的部分副作用之后，
  - 完全不发生，
  - 发生多次。

在 CPS
中，执行参数替换同样很容易，但它不会遇到上述问题。所有函数的实际参数都是变量或常量，不会是复杂的子表达式。因此，实际参数替换形式参数（以及随之发生的参数“移动”到函数体内部）不会引发意外行为。

至于其他表示方式：
- QUAD、PDG、SSA 主要关注单个函数体的表示，而不太关注跨函数边界的优化。
- 在这些框架中，仍然可以实现内联展开，但需要额外机制来表示函数参数和调用序列。
- 但是，它们仍然需要解决终止性问题和副作用的乱序执行问题。

=== 闭包表示（Closure Representations）

在具有#ruby[块结构][block structure]或#ruby[嵌套函数][nested functions]的语言（如
Pascal、Scheme、ML）中，一个函数 `f` 可能嵌套在函数 `g` 内，而 `g` 又可能嵌套在另一个函数 `h` 内。在这种情况下，`f` 不仅可以访问自己的形式参数和局部变量，还可以访问 `g` 和 `h` 的形式参数和局部变量。

编译器的一个重要任务是高效地实现这种变量访问。

由于 λ-演算 和 CPS
都允许函数具有嵌套作用域，编译器可以更容易地操作这些函数及其表示形式，以计算非局部变量的高效访问方法。

相比之下，QUAD、PDG 和 SSA
主要关注单个函数体内的控制流和数据流，因此它们不易直接解决跨作用域的变量访问问题。

=== 数据流分析（Dataflow Analysis）

数据流分析涉及静态地传播值（更准确地说，是编译时标记，代表运行时的值）沿着控制流图进行计算。它能够回答诸如“变量的这个定义是否能到达那个使用点？”的问题，这对于某些优化非常有用。

由于续延传递风格（CPS）能够较为准确地表示控制流图，因此数据流分析在 CPS
中和在更传统的表示方式（如 QUAD）中一样容易进行。

静态单赋值形式（SSA）的设计使得前向数据流分析特别高效，因为它能轻松确定变量的任何使用点对应的唯一赋值点——即，每个变量仅被赋值一次。我们将在后续讨论中看到，CPS
具有类似于单赋值的特性。

另一方面，λ-演算 并不太适用于数据流分析。

=== 寄存器分配（Register Allocation）

在将程序中的变量分配到机器寄存器时，使用一种能够清晰表示变量的生命周期（创建和销毁）的表示方式是十分有用的。这种#ruby[活跃性分析][liveness analysis]本质上是一种数据流分析，因此前面关于数据流分析的讨论同样适用于寄存器分配。

特别值得注意的是，在 CPS-为基础的编译器的某些阶段，CPS
表达式中的变量与目标机器的寄存器有着非常紧密的对应关系。

=== 向量化（Vectorizing）

程序依赖图（PDG）
尤其适用于优化，例如将普通循环转换为向量指令的优化。在其他中间表示（IRs）中，仍然可以实现类似的优化，但通常需要额外的数据结构来完成
PDG 所提供的功能。

=== 指令调度（Instruction Scheduling）

现代的深度流水线计算机要求编译器在后端阶段进行指令调度，以避免运行时的#ruby[流水线互锁][pipeline interlocks]。指令调度涉及对单个指令的操作，并需要详细了解它们的大小、执行时间和资源需求。本章讨论的中间表示（IRs）可能过于抽象，并不直接适用于编译器的指令调度阶段。

=== 结论

本章介绍的中间表示（IRs） 具有许多相似之处：

- 静态单赋值形式（SSA） 只是 四元式（QUAD） 的一种受限形式。
- 续延传递风格（CPS） 只是 λ-演算 的一种受限形式。
- SSA 和 CPS 之间也存在许多相似性，因为 CPS 变量具有#ruby[单一绑定][single-binding]属性。

通过#ruby[续延][continuations]，我们既可以获得 λ-演算
的清晰替换操作，又可以实现适用于冯·诺伊曼机器的数据流分析和寄存器分析。

== ML 语言简介

本书将展示如何在实际编译器中使用续延进行编译和优化。

我们的编译器——Standard ML of New Jersey（SML/NJ）——用于编译 ML
语言；但续延传递风格（CPS） 并不局限于 ML，它已被应用于多种语言的编译器中@bib52。

ML 编程语言最初于 1970 年代末被开发，作为 爱丁堡可计算函数逻辑（LCF） 定理证明系统的元语言（Meta-Language） @bib42。 在 1980 年代初，人们逐渐认识到 ML 本身是一种有用的编程语言（即使对于不从事定理证明的人而言也是如此），并实现了一个独立的 ML 系统 @bib26。 自那以来，Standard ML 语言 被正式定义 @bib64，其形式语义也得到了书写 @bib65，并且已经有多个编译器 可用 @bib13 @bib63。目前，在众多机构和场所，已有数百名程序员积极使用 该语言。

ML 作为一种实用的编程语言，具有以下优势：

- ML 是#ruby[严格求值][strict]的——即，函数的参数在函数调用之前被求值。这与 Pascal、C、Lisp 和 Scheme 相同，但不同于 Miranda 和 Haskell，后者是#ruby[惰性求值][lazy]的。- ML 支持#ruby[高阶函数][higher-order functions]，即一个函数可以作为参数传递，也可以作为另一个函数的返回值。这类似于 Scheme、C 和 Haskell，但不同于 Pascal 和 Lisp。然而，与 C 不同，ML 还支持#ruby[嵌套函数][nested functions]（Scheme 和 Haskell 也支持），这使得高阶函数更加有用。- ML 具有#ruby[参数化多态][parametric polymorphic]类型，即一个函数可以应用于多个不同类型的参数，只要它对参数执行的操作与类型无关。Lisp、Scheme 和 Haskell 也支持参数化多态，而 Pascal 和 C 不支持。参数化多态不同于#ruby[重载][overloading]，后者要求针对不同类型提供不同的函数实现。- ML 采用#ruby[静态类型检查][statically checked types]，即类型检查在编译时完成，因此运行时不需要类型检查（这也能在程序运行前发现许多错误）。其他静态类型检查的语言包括 Pascal、C、Ada 和 Haskell；而 Lisp、Scheme 和 Smalltalk 则在运行时进行动态类型检查。然而，ML（与 Haskell 类似）具有#ruby[类型推导][type inference]，程序员无需显式声明大多数类型。而在 Pascal、C、Ada 以及其他 Algol 系 语言中，程序员必须显式声明每个变量的类型。- ML 具有#ruby[垃圾回收][garbage collection]，能够自动回收不可达的存储空间。这是 Scheme 和 Haskell 等函数式语言的典型特性，但 Lisp 和 Smalltalk 也支持垃圾回收，而 Pascal、C 和 Ada 通常不支持。- ML 采用#ruby[静态作用域][lexical scoping]——在程序文本中，变量的声明位置决定了其作用范围。这与 Pascal、C 和 Scheme 相同，但不同于 Smalltalk，后者对函数采用#ruby[动态绑定][dynamic method lookup]。- ML 支持#ruby[副作用][side effects]，包括输入/输出以及可变#ruby[引用变量][reference variables]，可以执行赋值和更新操作。在这一点上，它与 Pascal、C、Smalltalk、Lisp 和 Scheme 等语言相同，但不同于 Haskell 这类纯函数式语言。不过，在 ML 中，可变变量和数据结构受到静态类型系统的约束，并且在编译时可静态识别。在典型的 ML 程序中，绝大多数变量和数据结构都是不可变的。- ML 具有完整的#ruby[形式语义][formally defined semantics] @bib65，保证了：  - 所有合法程序的执行结果是#ruby[确定的][deterministic]。
  - 所有非法程序都能被编译器识别为非法。  这与 Ada 形成对比——尽管 Ada 也有形式化语义，但它并不完整，因为某些“错误的”程序仍然必须被编译器接受。此外，Pascal 存在“歧义和不安全性” @bib95，而 C 则因指针的不安全操作，很容易让程序员误修改运行时环境的任意部分。Lisp 和 Scheme 在这方面表现较好——原则上，“错误的”程序会在编译时或运行时检测到，但某些行为（如参数的求值顺序）仍未明确规定 @bib69。

从上述总结可以看出，我们的编译器需要处理的问题以及 ML 语言的特性，与其他编程语言的编译器所面临的挑战有许多相似之处。然而，“现代”语言（如 ML） 的编译器必须在多个方面与#quote[传统]语言（如 C）的编译器有所不同：

- #ruby[高阶函数][higher-order functions]（如 ML、Scheme、Smalltalk 等）要求编译器在运行时引入数据结构来表示这些函数的自由变量。由于这些#ruby[闭包][closures]的生命周期通常无法在编译时确定，因此必须使用某种形式的#ruby[垃圾回收][garbage collection]。- 垃圾回收的存在要求所有运行时数据结构 采用垃圾回收器可理解的格式；此外，编译后的代码所使用的机器寄存器 和 其他临时变量 也必须对回收器可访问且可解析。- ML 鼓励“函数式”编程风格，即旧数据很少被更新，而是不断创建新数据。因此，垃圾回收器必须特别高效。在某些较早的 Lisp 系统，以及一些支持垃圾回收的 Algol 系语言 中，垃圾回收的负担较轻，因为新对象的分配频率较低。- 控制流主要通过源语言中的函数调用表示（而非 `while` 或 `repeat` 之类的内建控制结构）。因此，编译器必须确保函数调用（尤其是尾递归调用） 的开销极低。- ML 不提供“#ruby[宏][macro]”功能。在 C 和 Lisp 中，宏通常用于对频繁执行的代码片段进行#ruby[内联展开][in-line expansion]。对于不支持宏的语言，一个优秀的编译器 应当自动进行函数的内联展开，这是一种更安全的优化方式，并且可以提供类似的性能提升。

ML 具有一个独特的特性，这是其他常见编程语言所不具备的：大多数数据结构在创建后是#ruby[不可变的][immutable]。也就是说，一旦一个变量、#ruby[列表单元][list cell]或堆上的#ruby[记录体][record]被创建并初始化，它就不能被修改。
当然，每次调用函数时，函数的局部变量都会被重新实例化，并赋予不同的值；堆上的列表单元最终会变成垃圾（因为没有局部变量再指向它们），而新的单元会不断创建。但由于列表单元是不可修改的，因此#ruby[别名][aliasing]问题变得微不足道。
在传统编程语言的编译过程中，以下语句不能交换执行顺序：
$
a &<- \#1(p);\
\#1(q) &<- b
$

（其中 $\#1(x)$ 表示 $x$ 指向的记录体的第一个字段），因为 $p$ 和 $q$ 可能是别名，即它们可能指向同一个对象。
同样，以下语句不能交换，除非对 $f$ 的行为有足够的了解：
$
a &<- \#1(p);\
b &<- f(x)
$

在 ML 中，#ruby[可变变量][mutable variables]和可变数据结构（即在创建后可以被修改的对象）具有与#ruby[不可变对象][immutable ones]不同的静态类型。换句话说，它们在编译器的类型检查阶段就已经被区分开来。在典型的 ML 程序中，绝大多数变量和数据结构都是不可变的。
因此，#ruby[别名][aliasing]问题在 ML 中基本上消失了：如果 `p` 是一个不可变变量（通常如此），那么从 `p` 读取数据的操作几乎可以与任何其他操作交换顺序而不影响结果。我们的编译器在多个方面利用了这一特性。
#ruby[惰性][lazy]语言（如 Haskell）在原则上也具有不可变变量，但实际上，当一个变量被更新（即用求值后的结果替换原先的 #ruby[惰性求值单元][thunk]）时，对于编译器和运行时系统的某些部分而言，这种操作看起来仍然类似于一次变量修改。
最后，ML 拥有高度抽象的#ruby[形式语义][formal semantics]，这在许多方面都极为有用。任何不会改变可计算函数本质的优化或表示变换都是合法的。
相比之下，C 语言没有正式的形式语义。即使我们可以对 C 语言的行为形成一个合理的非正式理解，这种“语义”仍然高度依赖于底层机器的表示。此外，许多 C 程序违反了语言规范，但仍然被认为应该能在“合理的”编译器上运行。
在这样的情况下，C 编译器对程序转换的自由度非常有限。

== 编译器组织结构（Compiler Organization）

Standard ML of New Jersey（SML/NJ）@bib13 是一个 ML 语言的编译器，并且它本身是用 ML 语言编写的。它是一个#ruby[多遍][multipass]编译器，通过一系列#ruby[阶段][phases] 将源程序转换为机器语言程序。其主要过程如下：

1. #ruby[词法分析][lexical analysis]、#ruby[解析][parsing]、#ruby[类型检查][type checking]，并生成带注释的#ruby[抽象语法树][AST]。2. 转换为#ruby[类似λ-演算][λ-calculus-like]的中间表示（详见第 4 章）。3. 转换为#ruby[续延传递风格][CPS]（详见第 5 章）。4. 优化 CPS 表达式，生成更优的 CPS 表达式（详见第 6–9 章）。5. #ruby[闭包转换][closure conversion]，生成一个#ruby[闭合][closed]的 CPS 表达式，即其中的每个函数都不含自由变量（详见第 10 章）。6. 消除嵌套作用域，生成仅包含一个全局#ruby[互递归][mutually recursive]函数集的 CPS 表达式，这些函数都是非嵌套定义的（详见第 10 章）。7. #ruby[寄存器溢出][register spilling]处理，确保任何 CPS 表达式中的子表达式 至多拥有 $n$ 个自由变量，其中 $n$ 受目标机器的寄存器数量限制（详见第 11 章）。8. 生成目标机器的“汇编语言”指令，但此时仍为抽象形式（非文本形式）（详见第 13 章）。9. #ruby[指令调度][instruction scheduling]、#ruby[跳转优化][jump-size optimization]、#ruby[回填][backpatching]，最终生成目标机器指令（详见第 14 章）。
本书的结构与编译器的架构基本相同，但不包括第一阶段，即ML 语言的前端处理。事实上，编译器的“前端”部分比“后端”要复杂得多，但本书的重点是如何使用#ruby[续延][continuations]进行优化和代码生成，而不是如何编译 ML。

= CPS 形式

最早使用#ruby[续延传递风格][CPS] 作为#ruby[中间语言][intermediate language]的编译器 [83, 54]，使用 Scheme @bib68 语法来表示 CPS——在这些编译器中，CPS 表达式 只是一个满足特定语法约束的 Scheme 程序。在 Standard ML of New Jersey 编译器（以及本书）中，我们采用了一种更专门化的表示方式。在我们的实现中，CPS 表达式树 由 ML #ruby[数据类型][datatype] 表示；这种 datatype 语法本身 能够自动保证大多数 Scheme 方法中仅作为约定的语法特性。此外，我们还做了如下改进：
- 每个函数都有一个名称，而不是匿名函数。
- 使用语法运算符来定义#ruby[互递归][mutually recursive]函数，而不仅仅依赖“外部”#ruby[不动点][fixed-point]函数。- 支持#ruby[n元组][n-tuple]运算符，使得#ruby[记录体][record]和#ruby[闭包][closure]的表示更加方便。
本章将介绍 CPS 作为程序中间表示（IR）的具体数据结构，并非正式地描述 CPS 的工作方式。
CPS 表达式的一个重要性质 是：函数（或原语操作符，如 $+$）的所有参数必须是 #ruby[原子值][atomic values]——即变量或常量。一个函数调用不能作为另一个调用的参数。
这一设计的原因是，CPS 语言的目标是模拟#ruby[冯·诺伊曼][von Neumann]机器的执行方式。在这种架构中，计算机一次只能执行一个操作，并且要求所有运算所需的参数事先已经准备好并存储在寄存器中。

== CPS 数据结构

我们直接在 ML 数据类型 `cexp`（续延表达式）中表达这些限制，如 @fig2.1 所示。

#figure(caption: "The CPS data type")[
```sml
signature CPS =
sig
  eqtype var
  datatype value =
    VAR of var
  | LABEL of var
  | INT of int
  | REAL of string
  | STRING of string
  datatype accesspath = OFFp of int | SELp of int * accesspath
  datatype primop =
    * | + | - | div | ~ | ieql | ineq | < | <= | > | >=
  | rangechk | ! | subscript | ordof | := | unboxedassign
  | update | unboxedupdate | store | makeref | makerefunboxed
  | alength | slength | gethdlr | sethdlr | boxed
  | fadd | fsub | fdiv | fmul | feql | fneq | fge | fgt | fle | flt
  | rshift | lshift | orb | andb | xorb | notb
  datatype cexp =
    RECORD of (value * accesspath) list * var * cexp
  | SELECT of int * value * var * cexp
  | OFFSET of int * value * var * cexp
  | APP of value * value list
  | FIX of (var * var list * cexp) list * cexp
  | SWITCH of value * cexp list
  | PRIMOP of primop * value list * var list * cexp list
end
```]<fig2.1>

对于不熟悉 ML 的读者，这里需要解释 `datatype` 关键字：它定义了一种 “#ruby[不相交联合][disjoint-union]”或“#ruby[变体记录体][variant-record]”类型（详见附录 A）。在 `cexp` 类型中，每个值都带有一个“标签”（#ruby[构造器][constructor]），例如 `RECORD`、`SELECT`、`OFFSET` 等。如果 `cexp` 的标签是 `SELECT`，那么它会包含四个字段，分别是 #ruby[整数][integer]、#ruby[值][value]、#ruby[变量][var]和#ruby[续延表达式][cexp]，依此类推。
每个#ruby[续延表达式][continuation expression]都会：- 接受 零个或多个#ruby[原子参数][atomic arguments]，- 绑定 零个或多个#ruby[结果][results]，- 继续执行 零个或多个#ruby[续延表达式][continuation expressions]。
例如，以下 ML 表达式表示整数加法：将变量 $a$ 和 $b$ 相加，得到结果 $c$，然后继续执行表达式 $e$：

#figure[```sml
PRIMOP(+, [VAR a, VAR b], [c], [e])
```]

（对于 ML 初学者：方括号 `[]` 表示#ruby[列表][list]，而 `VAR` 只是一个用户定义的 #ruby[值类型][datatype] 的构造器。因此，`PRIMOP` 的第二个参数是一个包含两个值的列表，第三个参数是一个包含一个变量的列表，依此类推。此外，$+$ 在这里是一个#ruby[标识符][identifier]，与 $a$ 或 `PRIMOP` 相同；通常，它被绑定到一个加法函数，但在这里，它被重新绑定为一个不带参数的数据类型构造器。整个 ML 表达式 `PRIMOP(...)` 仅仅是构造了一个数据结构，用于表示编译器可能需要操作的#ruby[续延表达式][continuation expression]。）

在 CPS 中，操作的参数必须是#ruby[原子值][atomic]，即它们可以是变量或常量，但不能是复杂的子表达式。这正是 #ruby[续延传递风格][CPS] 的核心思想。
例如，通常我们可以写出如下表达式：

#figure[```sml
e = (a + 1) * (3 + c)
```]

但在 CPS 中，必须为所有子表达式创建名称，从而将其分解为：

#figure[```sml
u = a + 1
v = 3 + c
e = u * v
```]

使用 CPS 数据类型 来表示这一计算过程，则可以写成：

#figure[```sml
PRIMOP( +, [VAR a, INT 1], [u], 
  [PRIMOP( +, [INT 3, VAR c], [v], 
    [PRIMOP( *, [VAR u, VAR v], [e], [M])])])
```]

其中，我们假设续延表达式 $M$ 在后续计算中使用了变量 $e$。

数据类型 `value` 是 CPS #ruby[操作符][operators] 可以接受的所有#ruby[原子参数][atomic arguments] 的 #ruby[联合][union]。
每个参数可以是：- 变量（VAR）- 整数常量（INT）- 字符串常量（STRING）- 浮点数常量（REAL）
关于 `LABEL` 的用法将在 @sec2.4 进行解释。

虽然数学表达式 $(a + 1) times (3 + c)$ 不 指定 $a + 1$ 和 $3 + c$ 哪个应先求值，但在转换为 续延传递风格（CPS） 时，必须在二者之间做出选择。
在前面的示例中，$a + 1$ 被设定为先求值。
这也是 CPS 的一个核心特性：许多控制流的决策在源语言转换为 CPS 时已经确定。
然而，这些决策并非不可逆。经过适当的分析，优化器仍然可以调整#ruby[续延表达式][continuation expression]，使得 $3 + c$ 先求值。

#ruby[续延][continuations]可以非常自然地表达控制流。整数比较运算符（`>`）接受两个整数参数（常量或变量），不返回结果，并在比较后选择两个续延表达式之一继续执行。例如，条件表达式 `if a > b then F else G` 在 CPS 中可表示为：

#figure[```sml
PRIMOP(>, [VAR a, VAR b], [ ], [F, G])
```]

其中 $F$ 和 $G$ 是续延表达式。
#ruby[多路分支][multiway branches]（即#ruby[索引跳转][indexed jumps]）可以通过 `SWITCH` 运算符表示，例如：

#figure[```sml
SWITCH(VAR i, [E0, E1, E3, E4])
```]

该表达式根据 $i$ 的值（$0$、$1$、$3$、$4$）决定继续执行 $E_0$、$E_1$、$E_3$ 或 $E_4$。如果 $i$ 的运行时值小于 $0$ 或超出列表索引范围，则会导致错误的求值行为。续延表达式还可以用于在堆上构造 #ruby[$n$ 元组][n-tuples]，并访问记录体的字段。例如：

#figure[```sml
RECORD([(VAR a, OFFp 0), (INT 2, OFFp 0), (VAR c, OFFp 0)], w, E)
```]

该表达式在堆上创建一个包含 $3$ 个字段的记录体，初始化为 $(a, 2, c)$，并将其地址绑定到变量 $w$，然后继续执行 $E$。其中 `OFFp 0` 的含义将在后续介绍。需要注意的是，所有 `RECORD` 创建的堆对象都是#ruby[不可变的][immutable]，即它们不能被修改或重新赋值。

表达式 `SELECT(i, v, w, E)` 取出记录体 $v$ 的第 $i$ 个字段，并将结果绑定到 $w$，然后继续执行 $E$。如果 $i$ 所指定的字段不存在，则该表达式没有意义。字段的编号从 $0$ 开始。在 CPS 语言中，变量可以指向一个记录体值，但它也可能指向记录体的中间某个字段。`OFFSET` 原语允许调整指针；如果变量 $v$ 指向记录体的第 $j$ 个字段（$j$ 可能等于 $0$），那么 `OFFSET(i, v, w, E)` 使 $w$ 指向记录体的第 $(j + i)$ 个字段，并继续执行 $E$。常量 $i$ 可以是负数，但 $j + i$ 必须为非负数。

互递归（mutually recursive）函数使用 `FIX` 运算符定义。表达式

#figure[```sml
FIX([(f1, [v11, v12, ..., v1m1], B1),
     (f2, [v21, v22, ..., v2m2], B2),
     ···
     (fk, [vk1, vk2, ..., vkmk], Bk)],
    E)
```]<fix-def>

定义了零个或多个函数 $f_1, ..., f_k$，这些函数可以在表达式 $E$ 中被调用，也可以在彼此的函数体 $B_1, ..., B_k$ 内相互调用。每个函数 $f_1, ..., f_k$ 的形式参数由变量 $v_(i j)$ 组成。执行 $"FIX"(arrow(f), E)$ 的效果是定义列表$arrow(f)$中的所有函数，然后执行 $E$。通常，$E$ 通过 $"APP"$ 运算符调用一个或多个 $f_i$，或者将 $f_i$ 作为参数传递给另一个函数，或者将某些 $f_i$ 存储在数据结构中。

在 #ruby[续延传递风格][CPS] 中，所有函数调用都是#ruby[尾调用][tail calls]，也就是说，它们不会返回到调用它的函数。这一点可以从 APP #ruby[续延表达式][continuation expression] 的形式看出，因为它不包含任何续延表达式作为子表达式。  

例如，表达式 `SELECT(3, v, w, SELECT(2, w, z, E))` 依次执行以下操作：
+ 取出 $v$ 的第三个字段，存入 $w$，  
+ 继续取出 $w$ 的第二个字段，存入 $z$，  
+ 然后继续执行 $E$。  

然而，APP 表达式 `APP(f, [a1, a2, ..., ak])` 仅执行函数调用 `f(a1, a2, ..., ak)`，并不执行其他任何操作。也就是说，函数 $f$ 的函数体 直接在新的求值环境中执行，实际参数 $a_i$ 被替换为 $f$ 的形式参数。

函数 $f$ 具有由 `FIX` 声明绑定的形式参数和函数体。当然，由于函数是#ruby[“第一类值”][first-class]，它们可以作为参数传递或存储到数据结构中，因此变量 $f$ 可能实际上是某个#ruby[静态封闭][statically enclosing]函数的形式参数，或者是 `SELECT` 操作的结果等。然而，无论 $f$ 以何种方式出现，它所引用的值最初必须由 `FIX` 运算符创建。

当然，在大多数编程语言中，函数是允许返回到调用者的！但是，回想@sec1.1) 中的示例，其中 `prodprimes` 的某次调用可以直接返回到其调用者的调用者。这是因为，无论 `prodprimes(n-1)` 返回什么值，该值都会直接作为 `prodprimes(n)` 的返回结果。 如果所有函数调用都是这样的，那么直到程序执行结束，所有函数才会最终返回。在这种情况下，就不再需要运行时维护返回地址（以及局部变量等） 的#ruby[栈][stack] 来记录体“应该返回到哪里”。

在 #ruby[续延传递风格][CPS] 编译器中，所有函数调用都必须被转换为#ruby[尾调用][tail calls]。这通过引入#ruby[续延函数][continuation functions] 来实现：续延表达的是被调用函数本应返回后，剩余的计算过程。续延函数使用普通的 `FIX` 运算符进行绑定，并作为参数传递给其他函数。引入续延函数的具体算法将在 @chp5 详细讲解。

一个简单的示例可以说明这一点。假设我们有如下源语言程序：

#figure[```sml
let fun f(x) = 2*x+1
 in f(a+b)*f(c+d)
end
```]

该程序可以（大部分）转换为#ruby[续延传递风格][CPS]，如下所示：

#figure[```sml
let fun f(x, k) = k(2x+1)
    fun k1(i) = let fun k2(j) = r(ij)
                 in f(c+d, k2)
                end
 in f(a+b, k1)
end
```]

其中，$r$ 代表计算的#ruby[“剩余部分”][rest of the computation]，即原始程序片段本应返回其计算结果的地方。在这个转换后的程序中，每个函数调用都是封闭函数执行的最后一步，因此它可以直接被转换为 CPS 语言：

#figure[```sml
FIX([(f, [x, k], PRIMOP( *, [INT 2, VAR x], [u], [
                 PRIMOP(+, [VAR u, INT 1], [v], [
                 APP (VAR k, [VAR v])])])),
     (k1, [i], FIX([(k2, [j], PRIMOP( *, [VAR i, VAR j], [w], [
                              APP (VAR r, [VAR w])]))],
               PRIMOP (+, [VAR c, VAR d], [m], [
               APP (VAR f, [VAR m, VAR k2])])))],
PRIMOP (+, [VAR a, VAR b], [n], [
APP (VAR f, [VAR n, VAR k1])]))
```]<example-of-page-15>

在这个转换中，$k_1$ 和 $k_2$ 被称为#ruby[续延][continuations]，它们分别表示 $f$ 的两次调用后的剩余计算。函数 $f$ 被重写，使得它不再以普通方式返回，而是调用其续延参数 $k$，从而执行“剩余计算”。这种执行方式类似于普通编程语言中函数返回后继续执行后续代码的效果。 在普通函数调用中，返回值通常会被保存并用于后续计算。而在 CPS 中，返回值仅仅是传递给续延函数的参数，如上例中 $k_1$ 和 $k_2$ 中的变量 $i$ 和 $j$，它们分别捕获了 $f$ 计算后的结果，并继续执行后续计算。

== 逃逸的函数

考虑以下两个程序：

#{
  let a = figure[```sml
                let fun f(a, b, c) = a + c
                in f(1, 2, 3)
                end
                ```]
  let b = figure[```sml
                let fun g(a, b, c) = a + c
                in (g, g(1, 2, 3))
                end
                ```]
  figure(
    align(
      center, table(columns: 2, stroke: 0.5pt, column-gutter: 10%, a, b),
    ),
  )
}

函数 $f$ 仅在局部使用，而 $g$ 既在局部使用，也被导出到外部；我们称 $g$ #ruby[逃逸][escapes]，而 $f$ 没有逃逸。
在 $f$ 的情况下，我们可以执行一个简单的程序变换，去除未使用的参数 $b$，前提是我们同时修改所有对 $f$ 的调用位置：

#figure[```sml
let fun f(a, c) = a + c
in f(1, 3)
end
```]

但对于 $g$，这种变换就不那么容易了，因为我们无法确定所有 $g$ 的调用位置。由于 $g$ 可能被存储在某个数据结构中，并在程序的任意位置被取出调用；更糟糕的是，它甚至可能被导出并用于某个完全未知的“编译单元”，因此，我们不能改变它的表示方式——它必须仍然被看作一个接受三个参数（而非两个参数）的函数。

在使用 CPS 编译某种特定的编程语言时，我们可能需要对#ruby[逃逸函数][escaping functions] 的行为施加一定的限制。这里我们以 ML 为例，其他编程语言可能会有完全不同的限制。对于不逃逸的函数（如上例中的 $f$），不需要任何限制，因为在任何可能需要分析其行为的调用点，函数体都可以通过语法轻松找到。在 ML 中，所有函数恰好接受一个参数。若需要多个参数，可以通过传递 #ruby[$n$ 元组][n-tuple] 来实现；由于 ML 允许对 $n$ 元组进行模式匹配，这种方式在语法上非常方便。在上例中，函数 $f$ 和 $g$ 实际上都是接受 $3$ 元组作为参数的单参数函数。当 ML 代码转换为 CPS 时，每个用户定义的单参数函数都会变成一个双参数函数：新增的参数是#ruby[续延函数][continuation function]。而这些续延函数本身仍然是单参数函数。

因此，在 ML 转换为 CPS 时，我们对#ruby[逃逸函数][escaping functions] 施加以下规则：

- 每个逃逸函数要么有一个参数，要么有两个参数。
- 如果一个逃逸函数有两个参数（即用户定义的函数），那么它的第二个参数始终是一个单参数的逃逸函数（即续延函数）。
- 当前的#ruby[异常处理程序][exception handler]#footnote[ML 语言的#ruby[异常机制][exception mechanism] 将会在本书中偶尔提及，并讨论其转换和优化。对于不熟悉 ML 异常 的读者，可以忽略这些内容，因为它们并非本书的核心主题。]（通过 `sethdlr` 原语操作 `primop` 设定）始终是一个单参数的逃逸函数，即续延函数。

由于 ML 代码在转换为 CPS 时会自然地建立这些#ruby[不变量][invariants]，因此我们可能希望#ruby[优化器][optimizer]能够利用这些不变量来推理逃逸函数的行为。由于逃逸函数可能来自不同的编译单元，我们无法直接通过检查其函数体 推导这些信息，但可以确保优化器在所有编译单元中保持这些不变量。

对于允许多个参数的编程语言（如大多数命令式语言），我们可以制定类似的约定；无论如何，这些语言中都会存在用户定义的函数和续延函数。另一方面，在 Prolog 这样的逻辑编程语言中，每个#ruby[谓词][predicate]可能需要两个#ruby[续延][continuations]，因此我们需要采用完全不同的约定。

== 作用域规则

CPS 运算符生成的结果会绑定到#ruby[词法作用域][lexical scope] 内的变量。在同一个#ruby[续延表达式][continuation expression] 内，任何变量都不能被多次绑定，并且变量不能在其#ruby[语法作用域][syntactic scope]之外被引用。CPS 的作用域规则简单且直接：

- 在表达式 `PRIMOP(p, vl, [w], [e1, e2, ...])` 中，变量 $w$ 的作用域 为 $e_1, e_2, ...$。
- 在表达式 `RECORD(vl, w, e)` 中，变量 $w$ 的作用域 仅限于 $e$。
- 在 `SELECT(i, v, w, e)` 或 `OFFSET(i, v, w, e)` 中，变量 $w$ 的作用域 仅限于 $e$。
- 在 `FIX([(v, [w1, w2, ...], b)], e)` 中，变量 $w_i$ 的作用域 仅限于 $b$，而 $v$ 的作用域 包含 $b$ 和 $e$。这一规则可以推广到#ruby[互递归函数][mutually recursive functions]的定义。例如，在@fix-def 中每个 $f_i$ 的作用域包含所有 $B_j$ 及 $E$，而 $v_(i j)$ 的作用域 仅限于 $B_i$。
- `APP`、`SWITCH` 以及某些 `PRIMOP`（当第三个参数为空时）不绑定变量，因此不需要作用域规则。

每个变量的#ruby[使用][use]（即作为 `value` 类型的一部分）必须位于其#ruby[绑定][binding]的作用域内。一旦变量被绑定，它在其整个作用域内都保持相同的值，不能被重新赋值。当然，CPS 代码片段可能会被多次执行（例如，当它是一个被多次调用的函数体时）；在这种情况下，每次执行变量绑定时，可能会绑定不同的值。

== 闭包转换 <sec2.4>

使用 CPS 作为编译器的#ruby[中间表示][IR] 的主要原因在于，它与#ruby[冯·诺伊曼][von Neumann]计算机的指令集非常接近。大多数 CPS 运算符（如 `PRIMOP(+,...)`） 都与机器指令高度对应。

然而，在 冯·诺伊曼计算机 上，函数定义的概念比 CPS 更原始。CPS 函数（类似于 #ruby[λ-演算][λ-calculus] 或 Pascal 的函数）可以包含#ruby[自由变量][free variables]，即表达式可以引用定义在最内层封闭函数之外的变量。例如，在 第 15 页 的示例中，函数 $k_2$ 引用了 $k_2$ 的形式参数 $j$，同时也引用了 $i$，而 $i$ 是定义在 $k_2$ 之外的变量。我们称 $j$ 为 $k_2$ 的#ruby[绑定变量][bound variable]，$i$ 为 $k_2$ 的#ruby[自由变量][free variable]。当然，每个变量最终都会在某处被绑定，例如 $i$ 是 $k_1$ 的绑定变量。

冯·诺伊曼计算机 仅通过机器代码地址来表示函数。这样的地址本身无法描述函数的自由变量的当前值。（至于函数的绑定变量，则不需要提前存储，因为这些变量只有在函数调用时才会获取值。）

通常，表示包含自由变量的函数的方法是#ruby[闭包][closure] @bib57，即一个包含机器代码指针和自由变量信息的#ruby[二元组][pair]。例如，在 $k_1$ 被调用并传递 `i = 7` 作为参数时，我们可以将 $k_2$ 表示为#ruby[记录体][record] `(L2, 7)`；其中 $L_2$ 是 $k_2$ 的机器代码地址，而 $7$ 是 $k_2$ 这一实例中的 $i$ 的值。

我们在 CPS 语言 中显式表示#ruby[闭包记录体][closure records]。将 CPS 程序转换为另一个没有#ruby[自由变量][free variables]的 CPS 程序，这一过程被称为 #ruby[“闭包转换][closure conversion]”。在闭包转换后，每个函数都会获得一个额外的参数，即#ruby[闭包记录体][closure record]。闭包记录体的第一个字段 是指向该函数本身的指针，其其余字段 存储该函数的自由变量的值。

当一个“函数”被作为参数传递 给另一个函数，或被存储到数据结构 中时，实际上是#ruby[闭包][closure] 被传递或存储。而当另一个函数需要调用该闭包时，执行以下步骤：

+ 调用闭包 $f$ 时，首先从 $f$ 的第一个字段 提取函数指针 $f'$。
+ 然后调用 $f'$，并将 $f$ 作为第一个参数传递（其余参数依次传递）。

一个重要的特性是：$f$ 的调用者无需知道 $f$ 的闭包记录体的具体格式，甚至不需要知道它的大小。调用者唯一需要了解的是如何提取函数的机器代码指针。而 $f'$（即 $f$ 的实际函数体）知道如何在闭包记录体中找到所需的自由变量。

我们使用 @example-of-page-15 的示例（包含 $f$、$k_1$ 和 $k_2$）来说明闭包转换，使用 ML 语法 代替 CPS 语法（为了简洁）：

#figure[```sml
let fun f'(f'', x, k) = let val k' = #1(k)
                         in k'(k,2x+1)
                        end
    val f = (f')
    fun k1'(k1'', i) = let fun k2'(k2'', j) =
                                let val r' = #1(r)
                                 in r'(r,#2(k2'')+j)
                                end
                           val k2 = (k2', i)
                        in f'(f, #2(k1'') + #3(k1''), k2)
                       end
    val k1 = (k1',c,d,f)
 in f'(f, a+b, k1)
end
```]

（此代码在 ML 中可能无法正确类型检查，但它的目的仅是示意。）

函数 $f$ 没有自由变量，因此它的#ruby[闭包][closure] 是最简单的：一个仅包含函数代码的单元素记录体。
但 $k_1$ 有三个自由变量 $c$、$d$ 和 $f$，因此它的闭包是一个四元素记录体，包含：

- 这三个自由变量，
- $k'_1$（$k_1$ 的转换版本），它被修改为期望一个闭包作为第一个参数。

一个关键点 是：在每个闭包中，实际的函数始终是记录体的第一个字段。这意味着，在不同上下文中调用闭包时，不需要知道其具体格式，只需提取第一个字段即可调用它。例如，在对 $r$ 的调用中，尽管 $r$ 的闭包可能包含多个字段，但调用它只需要提取第一个字段，并将整个闭包作为参数传递。在代码中：

- $f'$ 接收它的闭包作为参数 $f''$，
- $k'_1$ 接收它的闭包作为参数 $k''_1$，
- $k'_2$ 接收它的闭包作为参数 $k''_2$。
另外，为了简化代码，我们在两处直接引用 $f'$，而不是先从 $f$ 提取它。

#ruby[闭包转换][Closure Conversion] 阶段的输入是一个 CPS 表达式，它遵循上一节描述的#ruby[作用域规则][scope rules]。转换的输出仍然是一个 CPS 表达式，但额外满足一个新的规则：所有函数都不再包含#ruby[自由变量][free variables]。

更具体地说，在函数 $g$ 的函数体 中，唯一允许的自由变量 是：

- 函数 $g$ 的#ruby[形式参数][formal parameters]。
- 函数名——即，在 `FIX` 表达式中，作为 `(function, formals, body)` 三元组 的第一个元素 出现的那些函数名。

在#ruby[冯·诺伊曼][von Neumann]机器 的实现中，函数名（即函数的机器代码地址）实际上是常量。因此，它们可以作为自由变量 出现在其他函数中，而不需要通过#ruby[闭包][closure]来查找。在#ruby[闭包转换][closure conversion]的输出中，我们在 CPS 记法 中使用 `LABEL` 而不是 `VAR` 来引用这样的变量，以表明它们本质上是常量，并且不再被视为自由变量。

因此，闭包转换后的 CPS 代码必须遵循以下#ruby[自由变量规则][free-variable rule]：在一个互递归（mutually recursive） 函数定义中，表达式：

#figure[```sml
FIX([
(f1, [v11, v12, ..., v1m1], B1),
(f2, [v21, v22, ..., v2m2], B2),
···
(fn, [vn1, vn2, ..., vnmn], Bn)],
E)
```]

在 $B_i$ 的自由变量 中，只能包含：
+ 函数 $f_i$ 的形式参数 $v_(i k)$。
+ 所有 $f_j$（即 `FIX` 绑定的所有函数名）。

此外，所有对 $f_j$ 的引用（以及仅有的 `FIX` 绑定的函数变量引用），在 CPS 记法 中必须使用 `LABEL` 构造器，而不是 `VAR`。

使用 `LABEL` 的主要原因是简化#ruby[寄存器分配][register allocation]时的#ruby[自由变量][free-variable]计算。从#ruby[代码生成器][code generator]的角度来看：`VAR` 代表占用寄存器的变量，`LABEL` 代表不占用寄存器的常量。在#ruby[闭包转换][closure conversion] 完成后，所有函数都不再具有非平凡的自由变量，因此不再需要嵌套定义函数。我们可以将所有函数定义在顶层 `FIX` 作用域 中，使得整个#ruby[编译单元][compilation unit]的形式变为：

#figure[```sml
FIX([
(f1, [v11, v12, ..., v1m1], B1),
(f2, [v21, v22, ..., v2m2], B2),
···
(fn, [vn1, vn2, ..., vnmn], Bn)],
E)
```]

其中，$B_i$ 和 $E$ 都不再包含 `FIX` 操作符。

为了进一步简化，我们可以将 $E$ 的自由变量转换为 $E$ 的形式参数，从而得到：#footnote[译者注：在这个变换后，$f_0$ 作为新的主入口函数，其形式参数 $v_01, v_02, ..., v_(0 m_0)$ 是原本 $E$ 的自由变量，它们被显式传递，而不再依赖外部作用域。]

#figure[```sml
FIX([
(f0, [v01, v02, ..., v0m0], E),
(f1, [v11, v12, ..., v1m1], B1),
(f2, [v21, v22, ..., v2m2], B2),
· · ·
(fn, [vn1, vn2, ..., vnmn], Bn)],
APP(VAR f0, [VAR v01, VAR v02, ..., VAR v0m0])])
```]

编译器的后续阶段只需要处理形如 $(f_i, arrow(v)_i, B_i)$ 的三元组集合，而无需关注最终的 `APP` 表达式，因为它是#ruby[平凡的][trivial]，且不包含任何需要进一步分析的内容。

完整的#ruby[闭包转换][closure conversion]算法将在 @chp10 详细描述。然而，在此之前，我们有必要正式定义表达式的#ruby[自由变量][free variables]。我们引入辅助函数#ruby[$"fvl"$][free-variable list]，它计算值列表中的变量集合：

$
"fvl"(mono("nil")) &= emptyset \
"fvl"((mono("VAR") v)::l) &= {v} union "fvl"(l) \
"fvl"((mono("LABEL") v)::l) &= "fvl"(l) \
"fvl"((mono("INT") i)::l) &= "fvl"(l) \
"fvl"((mono("REAL") i)::l) &= "fvl"(l) \
"fvl"((mono("STRING") i)::l) &= "fvl"(l) \
$

基于 $"fvl"$，我们可以直接计算表达式的自由变量，这一过程非常直观：

$
"fv"(mono("APP")(v,l_a)) &= "fvl"(v::l_a) \
"fv"(mono("SWITCH")(v,[C_1,C_2,...])) &= "fvl"[v] union union.big_i "fv"(C_i) \
"fv"(mono("RECORD")([(v_1,p_1),(v_2,p_2),...],w,E)) &= "fvl"[v_1,v_2,...] union "fv"(E) - {w} \
"fv"(mono("SELECT")(i,v,w,E)) &= "fvl"[v] union "fv"(E) - {w} \
"fv"(mono("OFFSET")(i,v,w,E)) &= "fvl"[v] union "fv"(E) - {w} \
"fv"(mono("PRIMOP")(p,l_a,[w_1,...],[C_1,...])) &= "fvl"(l_a) union union.big_i "fv"(C_i) - union.big_j {w_j} \
"fv"(mono("FIX")([(f_1,[w_11,...,w_(1 m_1)], B_1), ...,\ (f_n,[w_(n 1),...,w_(n m_1)], B_n)], E)) &= ("fv"(E) union union.big_i ("fv"(B_i)-union.big_(j=1) ^m_i {w_(i j)})) - union.big_i {f_i} \
$

== 寄存器溢出（Spilling）

CPS 语言中的变量使用方式 在许多方面类似于#ruby[冯·诺伊曼][von Neumann]机器上的#ruby[寄存器][registers]。

- 算术运算符以变量（寄存器）作为操作数，并将结果存入变量（寄存器）。
- `SELECT`（内存读取）以变量（寄存器）和常量#ruby[偏移量][offset]作为输入，并将结果存入变量（寄存器）。
- 其他操作也遵循类似的模式。

然而，冯·诺伊曼机器的寄存器数量是固定的，而 CPS 表达式可以拥有任意数量的变量。为了弥合这一差距，我们需要将多个 CPS 变量映射到相同的寄存器。但有一个限制：只有在两个 CPS 变量不会同时#ruby[“存活”][live]时，它们才能共享同一个寄存器：即，在程序的后续计算中，只需要其中一个变量，而另一个变量已经不再被使用的时候。

在传统的#ruby[数据流分析][dataflow analysis] 中，一个变量在静态分析时被视为#ruby[“活跃变量”][live variable]的条件是：
该变量在某个点之后仍然被使用，但在该点之前没有#ruby[重新绑定][reassigned]。

在 CPS 语言 中，这一概念等价于#ruby[续延表达式][continuation expression]中的#ruby[自由变量][free variables]。自由变量就是活跃变量！这一等价关系的证明很简单：只需注意，前面定义的自由变量函数（$"fvl"$）的计算方式，与传统数据流分析中的变量活跃性算法（针对#ruby[有向无环图][directed acyclic graph]的计算）完全相同。

对于 CPS，有 *#ruby[有限寄存器规则][Finite-Register Rule]* 如下：

在 CPS 语言 中，针对具有 $k$ 个寄存器 的目标机器，编译必须满足以下规则：

#align(center, text(size: 1.2em)[CPS 代码中的任何子表达式的自由变量数量不得超过 $k$。])

在#ruby[闭包转换][closure conversion]阶段之后，#ruby[寄存器溢出][spilling]阶段会重写 CPS 代码，以确保满足该规则。

此外，某些编译阶段也受到有限寄存器规则的变体约束。例如，在#ruby[溢出阶段][spill phase]之前，代码必须满足：

#align(center, text(size: 1.2em)[针对具有 $k$ 个寄存器的目标机器，\ CPS 代码中的任何函数的#ruby[形式参数][formal parameters]数量不得超过 $k$。])

完整的#ruby[溢出阶段][spill phase]描述将在@chp11 详细讲解。

= CPS 的语义 <chp3>

CPS表达式的含义可以通过一种简单的#ruby[指称语义][denotaional semantics]给出。完整的语义定义见 @chpb；这里我们沿用该语义定义的#ruby[结构][structure]，进行更为非正式的讨论。如果读者对#ruby[指称语义][denotational syntax]感到不适，可以只阅读本章正文，而略过代码部分的“语义”内容。所有CPS的变体——无论应用了作用域规则、自由变量规则以及语言相关规则的哪种子集——均遵循该语义。

下面给出的是一种直接的、使用Standard ML编写的#ruby[续延语义][continuation semantics]。读者如果熟悉续延语义（参见例如 Stoy @bib84、Gordon @bib43 或Schmidt @bib77）以及ML语言（参见例如Milner @bib65、Reade @bib68 或Paulson @bib67），将更易于理解下文。通过给出针对我们CPS表示的#ruby[形式化语义][formal semantics]，我们希望能让读者独立验证后续章节所介绍的变换，尽管我们很少会给出正式的证明。

#figure[```sml
functor CPSsemantics(structure CPS: CPS ...
```]

该语义以Standard ML中的#ruby[函子][functor]形式编写。它以（形式上的）一个CPS结构（参见@fig2.1）作为参数，同时还包括：

#figure[```sml
val minint: int
val maxint: int
val minreal: real
val maxreal: real
```]

我们不认为CPS作为模型所针对的底层机器架构应该具有无限精度的算术运算。必须存在某个最大和最小的可表示整数和实数。

#figure[```sml
val string2real: string -> real
```]

CPS语义将实数（浮点数）表示为字符串字面量，就像它们在源程序中被书写的方式一样（例如，`0.0`）。我们假设存在某种方法可以将其转换为机器表示。在编译的这一阶段，以字符串形式表示实数的实际原因是使CPS语言独立于特定的机器表示，从而使跨平台编译更加精确和容易。然而，这种表示方式的一个缺点是，使得实值表达式的#ruby[常量折叠][constant folding]变得非常困难。

#figure[```sml
eqtype loc
val nextloc: loc -> loc
```]

在#ruby[指称语义][denotational semantics]中，具有对内存副作用的操作通常通过“#ruby[存储][store]”来表示。每个存储值可以被视为从#ruby[位置][locations]（地址）到#ruby[可指称值][denotable values]的映射。位置的类型`loc`，以及用于生成新位置的函数，都是语义的参数。该类型必须支持值的相等性测试（即为#ruby[等价类型][`eqtype`]）。

#figure[```sml
val arbitrarily: 'a * 'a -> 'a
```]

有些事物无法由语义预测。为了对这种不可预测性建模，表达式`arbitrarily(a, b)`的求值结果可以是 `a` 或 `b` 之一。该表达式仅用于指针比较；关于相等性测试，详见@sec3.3。

#figure[```sml
type answer
```]

按照#ruby[续延语义][continuation semantics]的传统，我们引入一个类型`answer`，用于表示程序整个执行过程的结果。我们实际上并不需要了解该类型的具体结构。

#figure[```sml
datatype dvalue =
 RECORD of dvalue list * int
| INT of int
| REAL of real
| FUNC of dvalue list -> (loc * (loc -> dvalue) * (loc -> int)) -> answer
| STRING of string
| BYTEARRAY of loc list
| ARRAY of loc list
| UARRAY of loc list
```]

这些是语义中的#ruby[可指称值][denotable values]。这些值可以被绑定到变量、作为参数传递，或存储在数据结构中。在实现中，可指称值通常是那些可以保存在一个机器字中的值（如指向堆的指针或单精度整数）。

一个#ruby[可指称值][denotable value]可以是一个包含若干可指称值的 `RECORD`。不仅可以指向记录体的起始位置，还可以指向其中间的某个位置，因此记录体类型的可指称值还包含一个整数，用于表示在该记录体中的#ruby[偏移量][offset]。

一个#ruby[可指称值][denotable value]可以是一个整数（`INT`）或一个 `REAL`。在实现中，可能会期望将整数以“#ruby[非装箱][unboxed]”形式表示（即不存储在堆中，而是直接用一个机器字替代指针）；如果指针足够大或浮点数足够小，对实数也可能采用同样的方式。

`ARRAY` 值是通过#ruby[存储][store]表示的，因此它们在创建之后可以被修改。在语义中，一个长度为 n 的数组表示为一个任意的#ruby[位置][locations]列表，尽管在实际实现中，这些位置很可能是连续的。  
注意，#ruby[记录体][records]并不存储在存储中，因此记录体值是“纯”的，一旦创建便无法修改。数组有两种类型：`ARRAY` 可以包含任意的#ruby[可指称值][denotable values]，而 `UARRAY` 只能包含整数。

一个#ruby[可指称值][denotable value]可以是一个由字符组成的 `STRING`，或是一个 `BYTEARRAY`。字符串和字节数组支持相同的操作，区别在于字节数组可以被写入（修改），而字符串则不行。字符串和字节数组的元素必须是较小的（字节大小的）整数，这一点不同于 `UARRAY` 的元素——它们可以是更大的（机器字大小的）整数；而 `ARRAY` 的元素可以是任意类型（包括整数）。

最后，一个函数值（`FUNC`）接受一个实际参数列表和一个#ruby[存储][store]，然后继续计算以产生一个#ruby[结果值][answer]。该存储的类型为 `(loc * (loc -> dvalue) * (loc -> int))`，包含三个组成部分：下一个未使用的位置、从位置到#ruby[可指称值][denotable values]的映射、以及从位置到整数的映射。
为什么需要两个映射？我们将#ruby[存储][store]划分为两个部分：一部分用于保存任意值，另一部分仅用于保存整数。事实证明，这种划分能显著简化#ruby[代际垃圾回收器][generational garbage collector]的实现，如我们将在@sec16.3 中解释的那样。

#figure[```sml
val handler_ref : loc
val overflow_exn : dvalue
val div_exn : dvalue
```]

存储中有一个特殊的位置用于保存“当前的异常处理器”。这是一个#ruby[续延函数][continuation function]，在“抛出”异常时会被调用。除此之外，还有两个“特殊”的异常：算术溢出和除以零。这些异常之所以特殊，是因为“机器”可以直接引发它们：在实现中，这意味着运行时系统必须知道这些异常值的位置，这样在发生溢出中断时，运行时系统就能抛出相应的异常。

#figure[```sml
  ... ) :
sig val eval: CPS.var list * CPS.cexp ->
              dvalue list ->
              (loc*(loc->dvalue)*(loc->int)) ->
              answer
end = struct ...
```]

请原谅此处的排版问题！右括号表示我们已经到达了函子参数的结束，`sig...end` 描述了该函子所产生结果结构的#ruby[签名][signature]（其中包含一个名为 `eval` 的函数），而 `struct` 一词则标志着函子体的开始。

`eval` 函数接受一个 CPS 变量列表、一个#ruby[续延表达式][continuation expression]、一个可指称值列表以及一个存储。它通过在一个环境中对该 `cexp` 求值来产生一个“结果”，在该环境中，这些变量分别绑定到了相应的值。这使得一种“链接”形式成为可能：可以从一个“编译单元”链接到另一个单元；一个续延表达式的“外部变量”通过一组指定的变量及其对应值来表示。

以下是语义本体的开始：

#figure[```sml
type store = loc * (loc -> dvalue) * (loc -> int)
fun fetch ((_,f,_): store) (l: loc) = f l
fun upd ((n,f,g):store, l: loc, v: dvalue) =
                    (n, fn i => if i=l then v else f i, g)
fun fetchi ((_,_,g): store) (l: loc) = g l
fun updi ((n,f,g):store, l: loc, v: int) =
                    (n, f, fn i => if i=l then v else g i)
```]

为了方便地对#ruby[存储][stores]进行基本操作，我们定义了一些函数：一个用于从值存储中获取某个位置的值；一个用于用新值更新某个位置（当然，它会生成一个全新的存储）；一个用于从整数存储中获取某个位置的整数；以及一个用于更新整数存储的函数。

#figure[```sml
exception Undefined
```]

在CPS语言中，可以编写在语法上正确但在语义上无意义的程序。对于这类程序，语义将无法给出相应的#ruby[指称][denotation]。

我们也可能希望将该语义视为一个 ML 程序，用作 CPS 语言的解释器。对于出错的程序，解释器将引发一个 ML 异常：要么是此处声明的 `Undefined`，要么是预定义的异常 `Bind`、`Match` 或 `Nth` 中的一个。这与 CPS 程序调用 CPS 异常处理器的行为是不同的，二者不可混淆。

#figure[```sml
fun eq(RECORD(a,i),RECORD(b,j)) = 
               arbitrarily(i=j andalso eqlist(a,b), false)
  | eq(INT i, INT j) = i=j
  | eq(REAL a, REAL b) = arbitrarily(a=b, false)
  | eq(STRING a, STRING b) = arbitrarily(a=b, false)
  | eq(BYTEARRAY nil, BYTEARRAY nil) = true
  | eq(BYTEARRAY(a::_), BYTEARRAY(b::_)) = a=b
  | eq(ARRAY nil, ARRAY nil) = true
  | eq(ARRAY(a::_), ARRAY(b::_)) = a=b
  | eq(UARRAY nil, UARRAY nil) = true
  | eq(UARRAY(a::_), UARRAY(b::_)) = a=b
  | eq(FUNC a, FUNC b) = raise Undefined
  | eq(_,_) = false

and eqlist(a::al, b::bl) = eq(a,b) andalso eqlist(al,bl)
  | eqlist(nil, nil) = true
```]

该函数在@secA.4 中有详细解释。

CPS语言中的记录体与字符串是“#ruby[纯值][pure values]”，因此不能可靠地通过“#ruby[指针相等性][pointer equality]”进行比较。例如，记录体 `(4,5)` 应当与记录体 `(4,5)` 无法区分，即使两者不是一起被创建的。这意味着实现可以使用“#ruby[哈希共享][hash-consing]”技术将两个记录体放在相同的地址上；另一方面，垃圾回收器也可能将某个有多个指针引用的记录体复制多份，使每个指针指向自己的副本。

此处的 `eq` 测试——用于表示#ruby[指针相等性比较][pointer-equality comparison]——表示在某些情况下，指针可能相等也可能不相等。例如，两个数组的相等性测试必须准确判断它们是否起始于同一位置；两个整数的相等性测试也必须是精确的。 但为了适配前一段所描述的实现方式，对于两个记录的相等性测试是允许“#ruby[保守的][conservative]”：如果两个记录不相等，`eq` 会返回 `false`；但如果它们相等，`eq` 可能返回 `true`，也可能返回 `false`。在关于记录体、实数（可能表示为指向双精度值的指针）以及字符串的比较中，不同的指针可能指向等价的值。

此版本的 `eq` 测试会将所有指针与所有整数区分开来。因此，在实现中，指针必须具有不同于整数的位表示。为了避免这一要求，我们或许更希望只将“#ruby[小整数][small integers]”与指针区分开（参见第4.1节）。 在这种情况下，我们会在 `eq` 的最后一个子句之前插入如下子句：

#figure[```sml
  | eq(INT i, _) = arbitrarily(false, i<0 orelse i>255)
  | eq(_, INT i) = arbitrarily(false, i<0 orelse i>255)
```]

数字 255 是任意选取的，它表示（在实现中）我们不会将堆对象放在机器内存的前 255 字节中。

#figure[```sml
fun do_raise exn s =
     let val FUNC f = fetch s handler_ref in f [exn] s end

fun overflow(n: unit->int, c: dvalue list -> store -> answer) =
      if (n() >= minint andalso n() <= maxint)
             handle Overflow=> false
      then c [INT(n())]
      else do_raise overflow_exn

fun overflowr(n,c) =
      if (n() >= minreal andalso n() <= maxreal)
             handle Overflow => false
      then c [REAL(n())]
      else do_raise overflow_exn
```]

某些整数和浮点算术运算符可能会产生“#ruby[溢出][overflow]”，即结果超出表示范围，因而无法表示。`overflow` 函数对一个数字 n 求值，将其转换为一个 #ruby[可指称值][dvalue] 列表，并将其传递给其续延参数 $c$；但如果发生溢出，则会改为抛出异常。

这行 “`handle Overflow => false`” 的作用是在使用具有有限精度整数的 ML 系统中执行该语义时提供保护。其中的 `Overflow` 指的是元语言中的#ruby[溢出异常][overflow exception]，不应与 `overflow_exn` 混淆，后者是 CPS 中的溢出异常。

为了抛出一个异常 `exn`，`do_raise` 首先从存储中提取当前的异常处理器（位于位置 `handler_ref`），然后将该处理器应用于 `exn` 和当前的存储。

下面的函数 `evalprim` 用于对一个 `PRIMOP` 及其参数进行求值。该函数接受三个参数：一个#ruby[基本操作符][primitive operator]、一个可指称值（#ruby[dvalue][dvalue]）参数列表，以及一个可能的续延列表。然后它生成一个结果值列表（可能为空，具体取决于操作符），并从中选择一个续延，将其应用于结果列表；最终得到一个 `store -> answer` 类型的函数。当然，续延列表中包含多个元素的情况，仅会出现在该基本操作符属于某种“#ruby[条件分支][conditional branch]”时。

#figure[```sml
fun evalprim (CPS.+ : CPS.primop,
              [INT i, INT j]: dvalue list,
              [c]: (dvalue list -> store -> answer) list) =
                                 overflow(fn()=>i+j, c)
```]

因此，若要对两个整数求和，只需计算 $i + j$，如果没有发生溢出，就将结果传递给 $c$。由于 `evalprim` 函数中没有匹配将 `CPS.+` 应用于非整数值的子句，因此这种应用将是未定义的，并会导致语义无法生成相应的#ruby[指称][denotation]。

#figure[```sml
| evalprim (CPS.-,[INT i, INT j],[c]) =
                              overflow(fn()=>i-j, c)
| evalprim (CPS. *,[INT i, INT j],[c]) =
                              overflow(fn()=>i*j, c)
| evalprim (CPS.div,[INT i, INT 0],[c]) =
                              do_raise div_exn
| evalprim (CPS.div,[INT i, INT j],[c]) =
                              overflow(fn()=>i div j, c)
| evalprim (CPS.~,[INT i],[c]) = overflow(fn()=>0-i, c)
```]

整数的减法、乘法和除法操作与加法类似；对于除以零的情况，必须抛出#ruby[除零异常][divide exception]。

整数#ruby[取反][negation]操作类似于从零中减去一个数；注意这里只有一个 #ruby[可指称值][dvalue] 参数。在某些情况下，整数取反可能会发生#ruby[溢出][overflow]，例如，在采用二补码的机器上，最小的负整数的绝对值可能大于任何正整数。

#figure[```sml
| evalprim (CPS.<,[INT i,INT j],[t,f]) =
                                if i<j then t[] else f[]
| evalprim (CPS.<=,[INT i,INT j],[t,f]) =
                                if j<i then f[] else t[]
| evalprim (CPS.>,[INT i,INT j],[t,f]) =
                                if j<i then t[] else f[]
| evalprim (CPS.>=,[INT i,INT j],[t,f]) =
                                if i<j then f[] else t[]
```]

不等比较运算符 `<`、`<=`、`>` 和 `>=` 仅适用于整数。根据测试的结果，将续延$t$或$f$之一应用于一个（空的）结果列表。

#figure[```sml
| evalprim (CPS.ieql,[a,b],[t,f]) =
                            if eq(a,b) then t[] else f[]
| evalprim (CPS.ineq,[a,b],[t,f]) =
                            if eq(a,b) then f[] else t[]
```]

基本操作符 `ieql` 表示“#ruby[整数相等性][integer equality]”，但这显然是一个用词不当的名称，因为 `eq` 函数实际上会比较多种类型。其设计意图是让实现直接将两个机器字 $a$ 和 $b$ 进行整数相等性比较；如果 $a$ 和 $b$ 是指针，这种比较就会变成#ruby[指针相等性][pointer equality]。

#figure[```sml
| evalprim (CPS.rangechk, [INT i, INT j],[t,f]) =
                   if j<0
                   then if i<0
                        then if i<j then t[] else f[]
                        else t[]
                   else if i<0
                        then f[] else if i<j then t[]
                        else f[]
```]

这个看起来复杂的操作符其实就是“#ruby[无符号比较][unsigned comparison]”。当使用二补码表示负数时，且 $j$ 为非负数，测试 $0 ≤ i < j$ 最有效的方法是使用无符号比较操作符。`rangechk` 实质上就是“无符号小于”；这里嵌套的 `if` 语句仅是通过有符号操作符来表达无符号比较。当 $j < 0$ 时，无符号比较在语义上不再有实际意义，但其语义仍然是可以表达的。

#figure[```sml
| evalprim (CPS.boxed, [INT _],[t,f]) = f[]
| evalprim (CPS.boxed, [RECORD _],[t,f]) = t[]
| evalprim (CPS.boxed, [STRING _],[t,f]) = t[]
| evalprim (CPS.boxed, [ARRAY _],[t,f]) = t[]
| evalprim (CPS.boxed, [UARRAY _],[t,f]) = t[]
| evalprim (CPS.boxed, [BYTEARRAY _],[t,f]) =t[]
| evalprim (CPS.boxed, [FUNC _],[t,f]) = t[]
```]

谓词 `boxed` 在值是“#ruby[装箱][boxed]”（即以指针形式表示）时返回 true，在值是#ruby[非装箱][unboxed] 时返回 false。在实现中，可以通过确保指针具有不同于非指针的位模式，使该操作符成为一次简单的位测试或比较。在实现 ML 时使用 `boxed` 的主要目的是判断某个值被应用了哪个数据构造子；参见@sec4.1。

如果我们希望只有小整数可以与指针区分开，那么可以将 `boxed` 的第一个子句替换为：

#figure[```sml
| evalprim (CPS.boxed, [INT i],[t,f]) =
                 if i<0 orelse i>255
                 then arbitrarily(t[],f[]) else f[]
```]

想要这样做的原因在@sec4.1 中有详细解释。

#figure[```sml
| evalprim (CPS.!, [a],[c]) =
                evalprim(CPS.subscript, [a, INT 0],[c])
| evalprim (CPS.subscript, [ARRAY a, INT n],[c]) =
                  (fn s => c [fetch s (nth(a,n))] s)
| evalprim (CPS.subscript, [UARRAY a, INT n],[c]) =
                  (fn s => c [INT(fetchi s (nth(a,n)))] s)
| evalprim (CPS.subscript, [RECORD(a,i), INT j],[c]) =
                          c [nth(a,i+j)]
```]

#ruby[下标操作符][subscript operator]可用于获取数组或记录体中的元素，尽管记录体字段通常是通过 `SELECT` 来获取的。实际上，为可变对象和不可变对象使用不同的操作符会更清晰一些。无论如何，对于数组，下标操作会选择数组的第 $n$ 个位置，然后从存储中该位置取出值。结果会作为参数传递给续延 $c$。操作符 `!` 等价于对索引 $0$ 进行下标访问。对于记录体，下标操作不需要访问#ruby[存储][store]；但确实需要注意用偏移量 $i$ 来调整索引 $j$。在实际实现中，非零的 $i$ 表示记录体指针指向的是记录体的中间位置，因此下标操作实质上是一次加法加一次取值操作（在按字节寻址的机器上还需要一次左移操作）。

下标操作符并不进行边界检查；越界访问是错误的，且不会产生任何指称结果。然而，对于诸如 ML 这样的安全语言，预期编译器会显式地插入边界检查，方式是使用整数比较与下文所述的数组长度操作符 `alength`。

函数 `nth` 返回列表中的第 $n$ 个元素，从零开始计数。如果 $n < 0$ 或 $n ≥ "length"(l)$，则 `nth(l, n)` 会引发 `Nth` 异常，表示这是一个在语义上未定义的 CPS 表达式。

#figure[```sml
| evalprim (CPS.ordof, [STRING a, INT i],[c]) =
                          c [INT(String.ordof(a,i))]
| evalprim (CPS.ordof, [BYTEARRAY a, INT i],[c]) =
                    (fn s => c [INT(fetchi s(nth(a,i)))] s)
```]

操作符 `ordof` 用于对字符串和字节数组进行#ruby[下标访问][subscripts]，其方式类似于 `subscript` 对数组和记录体的操作。在实现中，字符串很可能被表示为连续的字符序列，实际上字节数组的表示方式也是相同的。
然而，字符串被视为常量，因为（例如：）它们可能是机器语言程序中的#ruby[字面量][literals]。

#figure[```sml
| evalprim (CPS.:=, [a, v],[c]) =
                  evalprim(CPS.update, [a, INT 0, v], [c])
| evalprim (CPS.update, [ARRAY a, INT n, v],[c]) =
                   (fn s => c [] (upd(s,nth(a,n),v)))
| evalprim (CPS.update, [UARRAY a, INT n, INT v],[c]) =
                  (fn s => c [] (updi(s,nth(a,n),v)))
```]

赋值操作符 `:=` 等价于对索引为零的位置执行 `update`。执行更新时，会在存储中将数组的第 $n$ 个位置更新，并生成一个新的存储，然后将该存储（连同形式上的空参数列表）传递给续延 $c$。与 `subscript` 类似，该操作不会进行边界检查。使用整数值更新 `UARRAY` 的过程也是类似的；若尝试用非整数值更新 `UARRAY`，则是错误的行为。

#figure[```sml
| evalprim (CPS.unboxedassign, [a, v], [c]) =
             evalprim(CPS.unboxedupdate, [a, INT 0, v], [c])
| evalprim (CPS.unboxedupdate,
            [ARRAY a, INT n, INT v],[c]) =
                   (fn s => c [] (upd(s,nth(a,n), INT v)))
| evalprim (CPS.unboxedupdate,
            [UARRAY a, INT n, INT v],[c]) =
                   (fn s => c [] (updi(s,nth(a,n),v)))
```]

在某些实现中，#ruby[代际垃圾回收器][generational garbage collector]需要追踪所有指向旧生代数组的指针的存储操作（这一点将在@sec16.3 中详细说明）。由于这种记录体操作的存在，这类存储操作的实现可能会更加昂贵。  

然而，在许多情况下，编译器知道被存储的值不是指针；例如，该值可能属于一种始终不装箱的类型，如 `int`，或是一个不装箱的常量，属于某种有时不装箱的类型。  

在这些情况下，编译器可以使用成本更低的 `unboxedassign` 或 `unboxedupdate` 操作符，这两个操作符在语义上分别与 `:=` 和 `update` 相同，但仅适用于整数值。

#figure[```sml
| evalprim (CPS.store,
            [BYTEARRAY a, INT i, INT v],[c]) =
         if v < 0 orelse v >= 256
         then raise Undefined
         else (fn s => c [] (updi(s,nth(a,i),v)))
```]

`store` 操作符是针对字节数组的，与数组的 `update` 操作符等价。字符串是不可写的，不能被更新。字符串和字节数组都只能保存“单字节”值（即介于 $0$ 到 $255$ 之间的整数）。

#figure[```sml
| evalprim (CPS.makeref, [v],[c]) = (fn (l,f,g) =>
               c [ARRAY[l]] (upd((nextloc l, f,g),l,v)))
| evalprim (CPS.makerefunboxed, [INT v],[c]) = (fn (l,f,g) =>
               c [UARRAY[l]] (updi((nextloc l, f,g),l,v)))
```]

长度为一的数组（在ML中称为“ref”）可以使用 `makeref` 运算符进行分配。CPS语言中无法分配更大的数组；这部分功能预期由实现提供一个外部函数（例如作为运行时系统的一部分）来完成。此类函数可以通过传递给 `eval` 函数的 `dvalue`参数，使CPS程序可以访问。

`makerefunboxed` 运算符用于创建一个只包含整数值的引用；在使用分代垃圾回收器时，这非常有用。  
注意，`: =` 或 `unboxedassign` 都可以用于任意类型的引用，只要 `unboxedassign` 仅用于存储整数值（可能属于非总是装箱的类型），且“unboxed”引用仅包含整数值即可。

#figure[```sml
| evalprim (CPS.alength, [ARRAY a], [c]) =
                           c [INT(List.length a)]
| evalprim (CPS.alength, [UARRAY a], [c]) =
                           c [INT(List.length a)]
| evalprim (CPS.slength, [BYTEARRAY a], [c]) =
                           c [INT(List.length a)]
| evalprim (CPS.slength, [STRING a], [c]) =
                           c [INT(String.size a)]
```]

`alength` 函数可用于提取数组的长度（即元素的数量）；`slength` 则用于字符串和字节数组，作用相同。注意，数组的长度是固定的，尽管其元素的值在存储中是可变的。

#figure[```sml
| evalprim (CPS.gethdlr, [], [c]) =
                    (fn s => c [fetch s handler_ref] s)
| evalprim (CPS.sethdlr, [h], [c]) =
                    (fn s => c [] (upd(s,handler_ref,h)))
```]

操作符 `gethdlr` 返回当前的异常处理器（从存储中提取），而 `sethdlr` 则使用新的异常处理器更新存储。在实现中，可以选择将异常处理器保存在寄存器中，而非内存中，因为在此语义中，`handler_ref` 这一位置的使用方式并不具有普遍性。

#figure[```sml
| evalprim (CPS.fadd, [REAL a, REAL b],[c]) =
                              overflowr(fn()=>a+b, c)
| evalprim (CPS.fsub, [REAL a, REAL b],[c]) =
                              overflowr(fn()=>a-b, c)
| evalprim (CPS.fmul, [REAL a, REAL b],[c]) =
                              overflowr(fn()=>a*b, c)
| evalprim (CPS.fdiv, [REAL a, REAL 0.0],[c]) =
                              do_raise div_exn
| evalprim (CPS.fdiv, [REAL a, REAL b],[c]) =
                              overflowr(fn()=>a/b, c)
| evalprim (CPS.feql, [REAL a, REAL b],[t,f]) =
                              if a=b then t[] else f[]
| evalprim (CPS.fneq, [REAL a, REAL b],[t,f]) =
                              if a=b then f[] else t[]
| evalprim (CPS.flt,[REAL i,REAL j],[t,f]) =
                              if i<j then t[] else f[]
| evalprim (CPS.fle,[REAL i,REAL j],[t,f]) =
                              if j<i then f[] else t[]
| evalprim (CPS.fgt,[REAL i,REAL j],[t,f]) =
                              if j<i then t[] else f[]
| evalprim (CPS.fge,[REAL i,REAL j],[t,f]) =
                              if i<j then f[] else t[]
```]

浮点数的算术运算和比较运算符与整数的运算符类似。

#figure[```sml
type env = CPS.var -> dvalue
```]

其余的语义部分使用了“#ruby[环境][environment]”的概念：即一个从CPS变量到可表示值的映射。那些将结果绑定到变量上CPS操作符，会通过扩展环境来实现绑定。而那些以变量作为参数的CPS操作符，则会从环境中提取这些变量对应的值。

#figure[```sml
fun V env (CPS.INT i) = INT i
  | V env (CPS.REAL r) = REAL(string2real r)
  | V env (CPS.STRING s) = STRING s
  | V env (CPS.VAR v) = env v
  | V env (CPS.LABEL v) = env v
```]

函数 `V` 用于将一个CPS值转换为一个可表示值。对于常量，这一过程相当直接；而变量（以及在此语义中等价的#ruby[标签][labels]）则必须在环境中查找。

#figure[```sml
fun bind(env:env, v:CPS.var, d) =
                fn w => if v=w then d else env w
fun bindn(env, v::vl, d::dl) = bindn(bind(env,v,d),vl,dl)
  | bindn(env, nil, nil)     = env
```]

函数 `bind` 只对#ruby[环境][environment]进行更新，生成一个新的环境。对于需要将多个值绑定到多个变量上的情况，额外定义 `bindn`。

#figure[```sml
fun F (x, CPS.OFFp 0) = x
  | F (RECORD(l,i), CPS.OFFp j) = RECORD(l,i+j)
  | F (RECORD(l,i), CPS.SELp(j,p)) = F(nth(l,i+j), p)
```]

在#ruby[CPS语言][CPS language]中，一个#ruby[记录体字段][record field]被表示为一个值和一个“#ruby[访问路径][access path]”。访问路径只是一个由一连串的选择操作组成的链，最终以一个偏移量结束。例如，记录字段表达式 `(v,SELp(3,SELp(1, OFFp 2)))` 表示先获取 `v` 的第 3 个字段，然后获取结果的第 1 个字段，再对该结果进行两个字的偏移（不进行取值操作），最终得到的结果被放入新的记录中。@chp11 中解释了这样设计的必要性。

访问路径 `OFFp 0` 对字段值没有任何影响；它是唯一可以应用于非记录体值（例如整数、实数等）的路径。

函数 `E` 用于获取一个CPS表达式的#ruby[指称][denotation]。这种指称的类型为 `env->store->answer`，总共只有七种情况：

#figure[```sml
fun E (CPS.SELECT(i,v,w,e)) env =
                   let val RECORD(l,j) = V env v
                    in E e (bind(env,w,nth(l,i+j)))
                   end
  | E (CPS.OFFSET(i,v,w,e)) env =
                   let val RECORD(l,j) = V env v
                    in E e (bind(env,w,RECORD(l,i+j)))
                   end
```]

为了计算一个 `SELECT`，首先从#ruby[环境][environment]中提取值 $v$；该值必须是一个#ruby[记录体][record]，否则该表达式是未定义的。然后，将索引 $i$ 加到偏移量 $j$ 上，并将记录中对应的元素绑定到变量 $w$ 上，形成一个新的环境。该新环境随后被用作子表达式 $e$ 的求值参数。`OFFSET` 的求值方式类似，不同之处在于索引与偏移量相加后，并不选择字段；而是将带有新偏移量的记录绑定到 $w$。

#figure[```sml
| E (CPS.APP(f,vl)) env =
                 let val FUNC g = V env f
                  in g (map (V env) vl)
                 end
```]

#ruby[函数应用][function application]相当简单：变量 $f$ 必须代表某个函数 $g$。参数 $"vl"$ 全部从#ruby[环境][environment]中提取，对得到的值列表应用 $g$。注意，并没有将环境传递给 $g$；这表明CPS语言具有#ruby[词法作用域][lexical scope]（#ruby[静态作用域][static scope]），而不是#ruby[动态作用域][dynamic scope]。

对于不熟悉 ML 的读者，我们在此说明：`map` 函数接受一个函数（在此为 `V env`）和一个列表（在此为 `vl`），并返回一个新列表，其元素是通过将该函数应用于原列表中的每个元素而得到的（在本例中，即从#ruby[环境][environment]中查找 `vl` 中每个值所得到的结果）。

#figure[```sml
| E (CPS.RECORD(vl,w,e)) env =
                 E e (bind(env,w,
                        RECORD(map (fn (x,p) =>
                                     F(V env x, p)) vl, 0)))
```]

为了创建一个#ruby[记录体][record]，首先需要从#ruby[环境][environment]中提取所有字段（`V env x`）；然后，对于每个字段，由函数 `F` 计算其访问路径 $p$ 中隐含的 `SELp` 和 `OFFp` 操作。接着，构造一个偏移量为 $0$ 的 `RECORD`，并将其绑定到 $w$。

#figure[```sml
| E (CPS.SWITCH(v,el)) env =
                 let val INT i = V env v
                  in E (nth(el,i)) env
                 end
```]

#ruby[分支表达式][switch expressions]相当简单：先对 $v$ 求值得到一个整数 $i$，然后对第 $i$ 个#ruby[续延][continuation]进行求值。需要注意的是，每一个续延表达式都会继续执行恰好一个续延的求值。对于 `RECORD`、`SELECT` 和 `OFFSET`，这一点在语法上是显而易见的；对于可能包含多个语法续延表达式作为参数的 `SWITCH` 或 `PRIMOP`，这一行为由语义来强制保证；而在 `APP` 中，续延表达式可能“隐藏”在被应用的函数 $f$ 的函数体内。

#figure[```sml
| E (CPS.PRIMOP(p,vl,wl,el)) env =
                evalprim(p,
                         map (V env) vl,
                         map (fn e => fn al =>
                               E e (bindn(env,wl,al)))
                             el)
```]

为了对一个#ruby[基本操作符][primitive operator]进行求值，首先需要从#ruby[环境][environment]中提取所有的#ruby[原子参数][atomic arguments]（`map (V env) vl`）。然后，将所有的#ruby[复合表达式参数][cexp arguments]转换为类型为 `dvalue list -> store -> answer` 的函数。接着，原子参数列表与续延列表（以及操作符 $p$）一并传递给 `evalprim` 函数，该函数执行相应的操作，并选择一个续延来接收结果。

#figure[```sml
| E (CPS.FIX(fl,e)) env =
          let fun h r1 (f,vl,b) =
                 FUNC(fn al => E b (bindn(g r1,vl,al)))
              and g r = bindn(r, map #1 fl, map (h r) fl)
           in E e (g env)
          end
```]

对#ruby[互相递归的函数][mutually recursive functions]的定义稍显复杂。本质上，我们只是在线程增强后的环境 $g(e n v)$ 中对表达式 $e$ 进行求值。函数 $g$ 以环境 $r$ 作为参数，并返回将所有函数名（`map #1 fl`）绑定到函数体（`map (h r) fl`）之后的增强环境 $r$。

函数 $h$ 用于定义单个函数；它接受一个环境 $r_1$ 和一个函数定义 `(f, vl, b)`，其中 $f$ 是函数名，$v l$ 是形式参数列表，$b$ 是函数体。其结果是一个函数（`fn al => ...`），该函数接受一个实际参数列表 $a l$，并通过两种方式扩展环境 $r_1$：首先，它应用 $g$ 来重新定义所有在 $f l$ 中的（互相递归的）函数；然后，它将实际参数绑定到形式参数。最终生成的环境用于对函数体 $b$ 进行求值。

函数 $g$ 与 $h$ 是#ruby[互相递归的][mutually recursive]；我们在语义中使用递归来实现CPS函数的互相递归。

注意，实际参数的数量必须与形式参数的数量相同，否则 `bindn` 将是未定义的。在我们的CPS语言中，不存在参数数量可变的函数。

#figure[```sml
    val env0 = fn x => raise Undefined
    fun eval (vl,e) dl = E e (bindn(env0,vl,dl))
end
```]

最后#footnote[译者注：最后这个 ```sml end``` 是用于结束整个 functor 的。]，函数 `eval` 接受一个变量列表、一个值列表以及一个#ruby[续延表达式][continuation expression]；它将在空#ruby[环境][environment]中把这些值绑定到对应的变量上，然后返回该表达式在所得环境中的#ruby[指称][denotation]。

= ML 特定的优化 <chp4>

在使用#ruby[续延传递风格][continuation-passing style]的编译器中，大多数优化（部分求值、#ruby[数据流][dataflow]、#ruby[寄存器分配][register allocation]等）应当在CPS表示中完成。然而，一些表示决策最好在更接近源语言的层级上完成。这里我们将描述一些特定于ML的优化，它们在转换为CPS之前完成。这些优化大多与#ruby[静态类型][static types]相关，因此最自然的做法是在CPS转换过程中类型信息被移除之前进行这些优化。

== 数据的内存布局 <sec4.1>

#text(size: 2em)[译者注：暂时工作到这里，这里是原书 P37。]

== 模式匹配

== 等价性 <sec3.3>

== Unboxed 更新

== mini-ML 子语言

== 异常声明

== Lambda 语言

== 模块系统

= CPS 变换 <chp5>

== 变量与常量

== 记录体与成员选择

== 基本算术操作

== 函数调用

== 多重递归函数

== 数据结构构造子

== 条件语句

== 异常处理

== call/cc

= 基于 CPS 的优化

== 常量折叠与 $beta$ 规约

== $eta$ 规约与柯里化

== 级联优化

== 实现

= $beta$ 展开

== 关于内联的时机

== 估算优化效果

== Runaway expansion

= 提升优化

== 合并不动点定义

== 提升优化的规则

== 提升优化

= 公共子表达式

= 闭包转换 <chp10>

== 一个简单例子

== 一个更大的例子

== 闭包传递形式

== 被调用者保存寄存器

== 被调用者保存续延闭包

== 栈上的闭包内存分配

== 将函数定义提升至顶层

= 寄存器溢出 <chp11>

== 表达式重排

== 寄存器溢出算法

= 空间复杂度

== 空间分析的公设

== 保持空间复杂度

== 闭包内存布局

== 关于启动垃圾回收的时机

= 抽象机器

== 编译单元

== 与垃圾回收器的接口

== 位置无关代码

== 特殊目的寄存器

== 伪指令

== 续延机器的指令集

== 寄存器分配

== 分支预测

== 抽象机器指令生成

== 整数算术

== 非装箱浮点值

= 机器码生成

== 翻译到 VAX

=== Span-dependent instructions

== 翻译到 MC68020

== 翻译到 MIPS 与 SPARC

=== PC-相关寻址

=== 指令调度

=== Anti-aliasing

=== Alternating temporaries

== 一个例子

= 性能评估

== 硬件

== 对每个优化步骤的测量

== 调参

== 关于缓存

== 编译时

== 与其他编译器的比较

== 结论

= 运行时系统

== 垃圾回收的效率

== 广度优先复制

== 代际垃圾回收 <sec16.3>

== 运行时数据格式

== 关于分页机制

== 异步中断

= 并行

== 协程与子协程

== 更好的编程模型

== 多处理器

== 多处理器垃圾回收

= 未来方向

== 控制流依赖性

== 类型信息

== 循环优化

== 垃圾回收

== 静态单赋值形式

== 有状态多线程

]}

#{
set heading(numbering: "A.1.1.")
show heading.where(level: 1): it => {
  set align(right)
  set text(font: ("Georgia", "Noto Serif CJK SC"))
  counter(figure.where(kind: image)).update(0)
  counter(figure.where(kind: table)).update(0)
  pagebreak(weak: true) + "Appendix " + counter(heading).display("A. ") + it.body + line(length: 100%) + v(1em)
}
counter(heading).update(0)
[

= ML 语言简介

本附录描述了 ML 语言的基础知识，足以理解本书其余部分中的示例。我们在此仅涵盖核心语言（不包含模块系统），但模块系统的概要参见第 4.8 节。如需更详细的内容，请参阅 Reade [68]、Paulson [67] 或 Sokolowski [81]。

Standard ML 的一个显著特点是其数据结构的表达能力。与其他语言类似，它包含#ruby[原子类型][atomic types]（如整数）、#ruby[笛卡尔积类型][cartesian product types]（#ruby[记录体][records]）和#ruby[不相交和类型][disjoint sum types]（类似于 Pascal 中的#ruby[变体类型][variants]或 C 语言中的#ruby[联合类型][unions]）；但在 ML 中，这些概念的结合方式似乎更加安全和优雅。

#ruby[原子类型][atomic types]包括 `int`（整数）、`real`（浮点数）和 `string`（零个或多个字符组成的序列）。

给定类型 $t_1, t_2, dots, t_n$（其中 $n >= 2$），可以构造出#ruby[笛卡尔积类型][cartesian product type]：$t_1 times t_2 times dots times t_n$。（在 ML 的语法中，$times$ 使用星号 `*` 表示。）这种类型称为#ruby[$n$元组][$n$-tuple]；例如，`int*int*string` 就是一个#ruby[三元组][3-tuple]类型，包含类似 `(3,6,"abc")` 这样的值。

#ruby[记录体类型][record type]是一种#ruby[语法糖][syntactic sugaring]，它在#ruby[$n$元组][$n$-tuple]（其中 $n >= 0$）的基础上，为每个「#ruby[字段][field]」赋予了名称。例如，类型：

#figure[```sml
{wheels: int, passengers: int, owner: string}
```]

包含的值形如：

#figure[```sml
{wheels=4, passengers=6, owner="Fred"}
```]

虽然它与类型 `int*int*string` 非常类似，但两者并不能相互替代。

#ruby[联合类型][union type]可以拥有几种不同形式的值；例如，一个#ruby[列表][list]的值可以是一个#ruby[对][pair]，也可以是#ruby[空值][nil]。与 C 语言中的#ruby[联合类型][union]（或 Pascal 中的#ruby[变体记录体][variant record]）不同，ML 要求每个值都必须带有一个#ruby[标记][tag]以区分该值属于哪一种形式。在未首先检查#ruby[标记][tag]之前，不可能从值中提取信息，因此 ML 中的联合类型更为安全。（ML 中将这种#ruby[标记][tag]称为#ruby[构造子][constructor]。）

使用关键字 `datatype` 来声明#ruby[联合类型][union types]。在一个 `datatype` 声明中，有一个#ruby[构造子][constructor]名称的列表，每个#ruby[构造子][constructor]都指定了与之相关联的值的类型。例如：

#figure[```sml
datatype vehicle =
    CAR of {wheels: int, passengers: int, owner: string}
  | TRUCK of real
  | MOTORCYCLE
```]

类型为 `vehicle` 的每个值都可以是#ruby[汽车][car]、#ruby[卡车][truck]或#ruby[摩托车][motorcycle]。

如果是#ruby[汽车][car]，则携带一个#ruby[记录体类型][record]的值（两个整数和一个字符串）；如果是#ruby[卡车][truck]，则携带一个实数值（`real`），表示其总重量；而所有#ruby[摩托车][motorcycle]的值都是相同的：`MOTORCYCLE` 称为#ruby[常量构造子][constant constructor]，因为它不携带任何值。

类型可以是#ruby[多态的][polymorphic]：一个函数或#ruby[构造子][constructor]可以操作具有不同（但类似）类型的对象。例如，`list` 数据类型可以用来构造整数列表、实数列表、整数列表的列表等等。

#figure[```sml
datatype 'a list = nil | :: of 'a * 'a list
```]

符号 `::` 是一个#ruby[标识符][identifier]，就像 `TRUCK` 或 `nil` 一样。  
类型变量 `'a` 出现在 `list` 前面，这表示 `list` 本身并非一个类型，而是一个#ruby[类型构造子][type constructor]：即它必须先应用于诸如 `int` 或 `string` 这样的类型参数之后，才能成为一个有意义的类型。  
类型构造子写在它们所应用的类型之后，因此 `int list` 是整数列表的类型。

构造子 `::`（发音为「cons」）携带一个类型为 `'a * 'a list` 的值；即一个#ruby[对][pair]，其中第一个元素类型为 `'a`，第二个元素类型为 `'a list`。例如，对于一个字符串列表，第一个元素为一个字符串，第二个元素则是另一个字符串列表（即该列表的「#ruby[尾部][tail]」）。

虽然 `'a` 可以代表任何类型——例如可以构造 `int list list`——但同一个列表中的元素必须全部为相同类型。如果确实需要在同一个列表中包含不同类型的对象，可以使用某个#ruby[数据类型][datatype]作为列表类型构造子的参数，例如：`vehicle list` 就可以同时包含#ruby[汽车][car]和#ruby[卡车][truck]。

大多数数据结构都是#ruby[不可变的][immutable]：它们不能通过赋值语句修改。例如，如果变量 `a` 持有前文所示描述 Fred 的六人座#ruby[汽车][car]的记录体值，那么既无法通过赋值语句修改该记录体。例如，若变量 `a` 存储了上述描述 Fred 的 6 人座汽车的记录体值，则它不能通过赋值语句被修改。

然而，这条规则存在一个例外。有一种特殊的数据类型 `ref`，表示#ruby[可变引用][mutable references]：

```sml
datatype 'a ref = ref of 'a
```

这种内置数据类型具有“特殊”的性质，与预定义于 Standard ML 中的 `list` 数据类型不同——虽然 `list` 是预定义的，但它完全可以被用户自行实现，且并无特殊之处。

例如，若有如下记录体：

```sml
{wheels=4, passengers=ref 6, owner="Fred"}
```

则该记录体的 `passengers` 字段可以通过赋值修改为其他值。但注意，这个记录体的类型是：

```sml
{wheels: int, passengers: int ref, owner: string}
```

这与 Fred 原本汽车的类型并不相同。

== 表达式

ML 中的表达式可取如下形式：

- $"exp"->"id"$

  一个#ruby[表达式][expression]可以是单个#ruby[标识符][identifier]。ML 有两种类型的标识符：#ruby[字母数字标识符][alphanumeric identifier]由字母和数字组成，并且以字母开头（与 Pascal 类似，但 ML 允许在字母数字标识符中包含下划线 `_` 和撇号 `'`）。#ruby[符号标识符][symbolic identifier]则由字符 `!%&$+-/:<=>?@\~\^|#*'` 以任意组合构成。

  有些字母数字组合是#ruby[保留字][reserved words]（如 `let` 和 `end`）；某些符号组合也同样是#ruby[保留字][reserved words]（如 `|` 和 `=>`）。

- $"exp"->"exp" "id" "exp"$

  一个#ruby[中缀运算符][infix operator]可以放在两个#ruby[表达式][expressions]之间，例如 `a+b`、`(a+b)*c` 或 `a*b+c`。和 Pascal 或 C 一样，不同的运算符有不同的#ruby[优先级][precedences]。不过在 ML 中，任何#ruby[标识符][identifier]都可以被声明为带有特定优先级的中缀运算符，而像 `+` 和 `*` 这样的运算符也只是普通的标识符，只是默认被定义为中缀的而已。

- $"exp"->"(" "exp" ")"$

  一个#ruby[表达式][expression]可以用括号括起来而不改变其含义；这与 Pascal 一样，可用于覆盖运算符的通常#ruby[优先级][precedence]。

- $"exp"->"exp" "exp"$

  在 ML 中，#ruby[函数应用][function application]通过先写函数、再跟随参数的方式表示。因此，`f x` 就是函数 `f` 应用到参数 `x` 上。如果你写成 `f(x)`，看起来更类似于 Pascal，但实际上括号并非必要，你同样可以写成 `(f)x`。

  一个表达式可以求值为一个函数；如果 `g y` 返回的结果是一个函数，那么这个函数可以通过 `(g y) x` 的形式应用到 `x` 上。但实际上，函数应用是左结合的，因此 `g y x` 会被解析为 `(g y) x`。另一方面，一个函数调用的参数也可能是另一个函数调用，例如 `f(g y)` 或者 `(g y)(h x)`。

  在 ML 中，每个函数都严格只接受一个参数。

- $"exp"->"id"$
- $"exp"->"id" "exp"$
- $"exp"->"exp" "id" "exp"$

  #ruby[数据类型][datatype]的值既可以用一个不带值的常量#ruby[数据构造子][data constructor]构造（上述三个规则中的第一个规则），也可以用一个携带值的构造子（上述第二个规则）应用于参数构造。如果一个携带值的构造子所携带的值是一个二元组（#ruby[2-元组][2-tuple]），则可以将其声明为#ruby[中缀][infix]形式；这种情况下，构造子写在它的两个参数之间，如上面第三条语法规则所示。

  列表构造子 `::` 就是这样一个例子：`3::nil` 是一个单元素列表，其中 `::` 应用于二元组`(3,nil)`。并且，`::` 被声明为#ruby[右结合][right-associative]的，因此`1::2::3::4::nil`是一个包含四个整数的列表。

- $"exp"->("exp", "exp")$
- $"exp"->("exp", "exp", "exp")$

  在 ML 中，可以通过用括号括起来的两个或多个用逗号分隔的表达式来构造#ruby[$n$元组][n-tuples]。当#ruby[元组表达式][tuple expression]求值时，一个元组形式的记录体值被创建在内存中。例如：

  - `(3,"abc",7)` 是一个包含三个元素的记录体，即一个#ruby[3-元组][3-tuple]；
  - 这与 Lisp 中的`cons`或 Pascal 中的记录体类似。

  记录体的结构取决于括号内逗号的组合方式。例如，表达式 `(3,"a",7)` 是一个包含一个整数、一个字符串和一个整数的 3-元组类型；它与 `((3,"a"),7)` 并不同，后者是一个包含了一个#ruby[2-元组][2-tuple]和一个整数的#ruby[2-元组][2-tuple]。

  函数只能接受一个参数的限制看起来似乎很严格；但实际中人们通常向函数传递一个#ruby[n-元组][n-tuple]，例如 `f(x,y,z)`。这样写就看起来更像是函数接受了多个参数。

- $"exp"->{"exprow"}space$
- $"exprow"->"id" = "exp"$
- $"exprow"->"exprow", "id" = "exp"$

  一个#ruby[记录体][record]可通过在大括号内写出以逗号分隔的多个带有字段名的表达式来构造，这些字段名用来标识各个字段的值。

- $"exp" -> mono("let") "dec" mono("in") "exp" mono("end")$

  一个 `let` #ruby[表达式][expression]引入了一个局部#ruby[声明][declaration]（dec）。此声明所定义的名称仅在 `let` 和 `end` 之间可见。声明的具体形式参见@secA.3。

- $"exp"->mono("fn") "pat" mono("=>") "exp"$

  关键字 `fn` 发音为 lambda（λ），用于定义#ruby[匿名函数][anonymous functions]。语法符号 `pat` 表示#ruby[模式][pattern]；一个简单的模式示例就是单个标识符（但请参阅下文）。例如，表达式：

  ```sml
  fn x => x+3
  ```

  定义了一个将其参数加 $3$ 的函数，因此表达式 `(fn x => x + 3) 7` 的值为 $10$。

  Lambda 表达式可以嵌套，如：

  #figure[```sml fn x => fn y => x + y```]

  这定义了一个返回函数的函数。ML 采用#ruby[词法作用域][lexical (static) scope]，因此表达式：```sml (fn x => fn y => x + y) 3``` 在任何上下文中的含义都与```sml fn y => 3 + y```完全相同。

  嵌套的 lambda 表达式提供了一种定义多参数函数的替代方式，因此如果 $f$ 是：

  #figure[```sml fn x => fn y => fn z => x + y + z```]

  则可以通过 `f a b c` 的形式向函数 $f$ 应用三个参数；在这种情况下，函数 $f$ 称作#ruby[柯里化][curried]函数。

  实际上，`fn` 表达式的语法比上面的语法规则所暗示的更丰富。更精确地说： 允许使用形式为：

- $mono("fn") "match"$

  的表达式，其中 $"match"$ 是一系列由竖线 (`|`) 分隔的#ruby[规则][rules]：

- $"match" → "rule"$
- $"match" → "match" "|" "rule"$
- $"rule" → "pat" => "exp"$

  当一个由多个#ruby[规则][rules]定义的函数被应用于某个参数时，这些#ruby[模式][patterns]将按顺序依次检查，直到找到第一个匹配成功的模式。然后，对应于该模式的表达式将被求值。

- $"exp" → mono("case") "exp" mono("of") "match"$

  一个 `case` 表达式会首先对其参数 $"exp"$ 求值，然后根据所得值依次匹配 $"match"$ 中的#ruby[模式][patterns]，找到第一个匹配成功的模式后，执行对应的绑定并对相应的右侧表达式求值。

== 模式匹配

最简单的#ruby[模式][pattern]就是一个变量（总是可以匹配），但也存在其他类型的模式：

- $"pat" → "constant"$

  当模式为一个整数、浮点数或字符串常量 $c$ 时，它仅能匹配值 $c$。如果给定参数与 $c$ 不相等，则匹配失败。注意，编译时的类型检查确保常量的类型（如 `int`）始终与参数的类型一致。

- $"pat" → "id"$

  当模式为一个#ruby[常量构造子][constant constructor]（通过之前的#ruby[数据类型声明][datatype declaration]定义）时，它仅匹配该常量构造子。

  编译时的类型检查确保参数一定属于对应的数据类型。如果标识符并未通过数据类型声明定义为构造子，则它代表的是匹配中的变量，其行为与构造子截然不同（见下文）。这种情况经常会引起较大的混淆（并产生错误）。

  为了缓解这一问题，有一种常见的惯例是：构造子（不幸的是，除了 `nil`）以大写字母开头，而变量则不以大写字母开头。

- $"pat" → "id" "pat"$

  当模式为构造子应用于另一个模式 $p$ 时，若参数是由同一构造子构建且 $p$ 能匹配该构造子携带的值，则此模式匹配成功。因此，模式 `TRUCK 3.5` 能匹配由表达式 `TRUCK(2.5+1.0)` 所构造的值，但无法匹配值 `MOTORCYCLE` 或 `TRUCK(3.0)`。

- $"pat" -> "(" "pat" ")"$

#ruby[模式][pattern]可以加上括号来消除语法上的歧义，这并不改变其含义。

- $"pat" -> "(" "pat", "pat" ")"$
- $"pat" -> "(" "pat", "pat", "pat" ")"$

  一个 #ruby[$n$-元组模式][n-tuple pattern]（对于任意 $n >= 2$）当且仅当元组模式的每个元素都匹配参数中的对应元素时，才能匹配 $n$-元组参数。#ruby[静态类型检查][static type checking]确保参数是一个 $n$-元组（且 $n$ 的值正确）。

- $"pat" -> {"patrow"}$
- $"patrow" -> "id" "=" "pat", "patrow"$
- $"patrow" ->$
- $"patrow" -> "..."$

  #ruby[记录体模式][record pattern]是一个由 `id=pat` 组成的序列，其中 `id` 是#ruby[记录体][record]的标签。

  与#ruby[元组模式][tuple pattern]类似，记录体模式在所有字段都匹配参数的对应字段时才会匹配成功。记录体模式可以以省略号 (`...`) 结尾，此时参数中剩余的字段会自动匹配；但这些剩余字段的名称必须在#ruby[编译时][compile time]是可确定的。

- $"pat" -> "_"$

  下划线 `_` 是一个#ruby[通配模式][wild-card pattern]，它可以匹配任何参数。

- $"pat" -> "id"$

  当#ruby[模式][pattern] 是一个标识符且未声明为#ruby[构造子][constructor]时，一个新的变量将被绑定到参数上，并且该匹配始终成立。因此，函数 `fn x => x + 3` 具有模式 `x`，它是一个变量。当该函数应用于某个参数时，`x` 会被实例化，并取该参数的值。变量 `x` 的作用域是整个函数的右侧部分（即 `x + 3`），因此该函数会对其参数加三。#ruby[静态类型检查][static type checking] 会确保该参数始终是一个整数。

  函数 `fn(a, b) => a + b * 2` 使用了一个#ruby[对][pair]（即#ruby[二元组][2-tuple]）作为形式参数；该对的第一个元素会被绑定到变量 `a`，第二个元素会被绑定到变量 `b`。因此，尽管 ML 语言要求所有函数都必须有且仅有一个参数，但可以用这种方式模拟多参数函数，这种风格与传统方法非常相似。

  现在来看一个根据列表的不同长度作出不同处理的函数：

  #figure[```ml
  fn nil => 0
  | x::nil => 1
  | z => 2
  ```]

  第一条规则仅匹配空列表（`nil`）。第二条规则匹配的是#ruby[构造单元][cons cell]，即列表的#ruby[头部][head]和#ruby[尾部][tail]都必须匹配；由于 `x` 是一个变量，它可以匹配任意值，而尾部必须匹配空列表（`nil`），因此这条规则匹配的列表长度必须为$1$。最后一条规则会匹配任何未被前两条规则捕获的情况。

== 声明<secA.3>

在 ML 中可以声明几种不同类的内容，每种都有不同的关键字用于引入声明：

- $"dec" -> mono("val") "pat" "=" "exp"$

  在 ML 中，#ruby[`val` 声明][val declaration]可以用于定义新变量，例如 `val x = 5`，这将 $x$ 绑定到 $5$。在这种情况下，#ruby[模式][pattern]是一个简单的变量模式，它总是能够匹配。

  `val` 声明的另一种用途是用于提取#ruby[记录体][record]的字段，例如：

  #figure[```ml
  val (a, (b, c), d) = g(x)
  ```]

  在这种情况下，`g(x)` 返回的类型必须是一个 #ruby[3 元组][3-tuple]，其中第二个元素是一个#ruby[对][pair]。3 元组的第一个和最后一个#ruby[分量][component]分别被绑定到 $a$ 和 $d$，而对的两个元素被绑定到 $b$ 和 $c$。

  最后，`val` 声明也可以用于可能无法匹配的情况，例如：

  #figure[```ml
  val TRUCK gross_weight = v
  ```]

  如果 $v$ 这个 `vehicle` 确实是 `TRUCK`，那么变量 `gross_weight` 将被绑定到 `TRUCK` #ruby[构造器][constructor]携带的值。否则，`val` 声明会因引发 `Bind` #ruby[异常][exception]而失败。

- $"dec" -> mono("val") mono("rec") "pat" "=" "exp"$

  通常，由 #ruby[`val` 声明][val declaration]绑定的#ruby[标识符][identifier]的#ruby[作用域][scope]不包括声明中的#ruby[表达式][expression]`exp`。然而，关键字 `rec` 表示一个#ruby[递归声明][recursive declaration]；在这种情况下，`exp` 必须以关键字 `fn` 开头。因此，以下是一个计算#ruby[列表][list]长度的函数：

  #figure[```ml
  val rec length = fn nil => 0 | fn a::r => 1 + length(r)
  ```]

- $"dec" -> mono("fun") "clauses"$

  为 #ruby[`val rec` 声明][val rec declaration]提供#ruby[语法糖][syntactic sugar]是很方便的。以下是一些示例，以及它们在不使用 `fun` 关键字时的等价形式：

  #{
  let a = ```sml
          fun length nil = 0
            | length (a::r) = 1 + length(r)
          ```
  let b = ```sml
          val rec length = fn nil => 0
                            | (a::r) => 1 + length(r)
          ```
  let c = ```sml
          fun f a b c = a + b + c
          ```
  let d = ```sml
          val rec f = fn a => fn b => fn c => a + b + c
          ```
  figure(
    align(
      center, table(
        columns: 2, stroke: 0.5pt, 
        column-gutter: 10%, row-gutter: 2%,
        a, b, c, d),
    ),
  )
  }

  需要注意的是，如果 `f` 不是递归的，使用 `rec` 关键字不会产生影响。

- $"dec" -> mono("datatype") "datbind"$

  #ruby[数据类型][datatype]使用本附录开头描述的语法进行声明。

- $"dec" -> mono("type") "type-binding"$

  #ruby[类型缩写][type abbreviation]用于声明一个新类型，该类型等价于某个已存在（可能是未命名的）类型。例如：

  #figure[```sml
  type intpair = int * int
  type comparison = int * int -> bool
  ```]

  类型 `intpair` 现在与 `int × int` 相同，而 `comparison` 是“从#ruby[整数对][pair of integers]到#ruby[布尔值][Boolean]的#ruby[函数][function]”的缩写。  

  类型缩写可以是#ruby[参数化][parametrized]的，例如：

  #figure[```sml
  type 'a pair = 'a * 'a
  type 'b predicate = 'b -> bool
  ```]

  其中，`'a pair` 表示元素类型为 `'a` 的成对数据结构，而 `'b predicate` 表示从 `'b` 类型映射到布尔值的#ruby[谓词][predicate]。

- $"dec" -> "dec"$

  在允许使用单个声明的地方，也可以连续使用多个#ruby[声明][declaration]。较早声明中绑定的#ruby[标识符][identifier]可以在后续声明中使用。

- $"dec" -> bold("etc.")$

  还有几种其他类型的#ruby[声明][declaration]，但由于篇幅限制，这里无法详细说明。

== 一些例子<secA.4>

为了说明 ML 的使用，我们将解释本书其他地方使用的一些示例。首先来看 countzeros 程序（第 83 页）：

#figure[```sml
fun count p = let fun f (a::r) = if p a then 1+f(r) else f r
                     | f nil = 0
              in f
              end

fun curry f x y = f(x,y)

val countzeros = count (curry (fn (w,z)=> w=z) 0)
```]

函数 `count` 接受一个参数 p，并返回另一个函数作为结果。该返回的函数接受一个列表作为参数，并返回一个整数。更简单的理解方式是，`count` 是一个#ruby[柯里化][curried] 的双参数函数。无论如何，它的类型是：

#figure[```sml
count: ('a -> bool) -> (('a list) -> int)
count: ('a -> bool) -> 'a list -> int
```]

类型被写了两次，第二次使用了最少数量的括号（注意 `->` 运算符是#ruby[右结合][associates to the right]的）。

编译器可以自动推导出 `count` 的类型（事实上，它可以推导出所有函数的类型）。在这个例子中，由于 `p` 被应用于某个参数，它必须是一个#ruby[函数][function]；而由于 `p` 的返回值被用于 `if` 表达式中，`p` 必须返回一个#ruby[布尔值][bool]。  

第二个参数的写法是 `a::r` 和 `nil`，这意味着它必须是一个 #ruby[列表][list]；此外，由于 `a` 在表达式中被重复使用，这表明列表的元素类型必须与 `p` 的参数类型匹配。最后，由于 `then` 分支返回的表达式是 `1 + count(r)`，可以推导出 `count` 的返回类型是 #ruby[整数][int]。

那么 `count` 实际上做了什么呢？  

参数 `p` 是一个 #ruby[谓词][predicate]，它会被应用到列表的每个元素上。如果列表为空（即 `count p nil`），那么返回 `0`。否则，如果 `p` 在列表的第一个元素上返回 `true`，那么结果是 `1 + count p` 作用于列表的尾部；如果 `p` 返回 `false`，那么不会加 `1`。因此，`count` 计算的是列表中 满足谓词 `p` 的元素个数。

`curry` 函数接受一个函数 `f` 作为参数。`f` 是一个接受#ruby[二元组][2-tuple] 作为参数的函数。而 `curry f` 的返回结果是一个函数 `fn x => fn y => ...`，它接受单个参数 `x`，然后返回一个新函数 `fn y =>`，这个新函数再接受一个参数 `y`。该函数的最终结果是 `f(x, y)`。因此，`curry f` 返回 `f` 的#ruby[柯里化][curried] 版本。

`countzeros` 函数用于计算整数列表中零的个数。它通过将 `count` 应用于合适的 #ruby[谓词][predicate]来实现这一点。当然，在 `count` 实际执行之前，它还需要被应用到另一个参数（一个列表），因此 `countzeros` 本身不会立即执行任何操作，直到它被应用到一个整数列表为止。

现在让我们来看 `eq` 函数（第 27 页）。这里我们为了简洁起见省略了一些情况：

#figure[```sml
fun eq(RECORD(a,i),RECORD(b,j)) =
      arbitrarily(i=j andalso eqlist(a,b), false)
| eq(INT i, INT j) = i=j
| eq(STRING a, STRING b) = arbitrarily(a=b, false)
| eq(ARRAY nil, ARRAY nil) = true
| eq(ARRAY(a::_), ARRAY(b::_)) = a=b
| eq(FUNC a, FUNC b) = raise Undefined
| eq(_,_) = false
and eqlist(a::al, b::bl) = eq(a,b) andalso eqlist(al,bl)
| eqlist(nil, nil) = true
```]

`fun ... and` 语法允许定义#ruby[互递归][mutually recursive]的函数 `eq` 和 `eqlist`。函数 `eq` 给出了#ruby[指针相等][pointer equality]在一对 `dvalue` 参数上的语义（参见第 24 页），而 `eqlist` 模拟了 `dvalue` 列表上的 #ruby[指针相等][pointer equality]。

调用 `eq` 的两个参数分别为 `x` 和 `y`。  

- 如果它们都是 `RECORD`，那么 `x` 的#ruby[字段列表][field-list]会绑定到 `a`，`y` 的字段列表会绑定到 `b`，它们的#ruby[偏移量][offsets]分别绑定到 `i` 和 `j`。  
- 然后，函数 `arbitrarily` 将以两个参数进行求值。  

第一个参数使用了 ```sml andalso``` 关键字，它执行#ruby[短路][short-circuit] 布尔求值；等价于：

#figure[```sml
if i=j then eqlist(a,b) else false
```]

第二个参数是 `false`。`arbitrarily` 仅返回其参数之一（参见第 3 页）。

因此，在测试#ruby[记录体][record] 的相等性时，如果 `i = j`，则会调用 `eqlist` 函数，而 `eqlist` 可能会递归调用 `eq`。  

- 如果其中一个参数是`RECORD`而另一个不是，则会匹配`(_,_)`这一模式，并返回`false`。
- 如果两个参数都是`STRING`，那么匹配第三个模式。
- 如果两个参数都是`ARRAY`，那么会匹配第四个或第五个模式，这取决于它们的 #ruby[元素列表][element-lists]是否都为`nil`。  
- 如果两个参数都是`FUNC`，那么匹配第六个模式，并执行`raise Undefined`，抛出异常。在这种情况下，`eq`不会返回任何结果，而是将控制权转交给最近的#ruby[异常处理器][exception handler]。  

函数`eqlist`具有两个匹配#ruby[子句][clause]：
1. 一个匹配#ruby[非空列表][nonempty lists]，它会测试 首元素的相等性，然后递归处理剩余部分。  
2. 另一个匹配#ruby[空列表][empty lists]。  

但是，如果两个列表的长度不同，那么递归调用最终会导致一个列表是`nil`而另一个不是。在这种情况下，没有任何模式可以匹配，运行时会抛出#ruby[`Match`异常][runtime exception `Match`]。

= CPS 的语义 <chpb>

这个语义在@chp3 中有详细说明。

#align(center)[
```sml
functor CPSsemantics
  (structure CPS: CPS
   val minint: int
   val maxint: int
   val minreal: real
   val maxreal: real
   val string2real: string -> real
   eqtype loc
   val nextloc: loc -> loc
   val arbitrarily: 'a * 'a -> 'a
   type answer
   datatype dvalue =
     RECORD of dvalue list * int
   | INT of int
   | REAL of real
   | FUNC of dvalue list -> (loc * (loc -> dvalue) * (loc -> int)) -> answer
   | STRING of string
   | BYTEARRAY of loc list
   | ARRAY of loc list
   | UARRAY of loc list
   val handler_ref: loc
   val overflow_exn: dvalue
   val div_exn: dvalue):
sig
  val eval: CPS.var list * CPS.cexp
            -> dvalue list
            -> (loc * (loc -> dvalue) * (loc -> int))
            -> answer
end =
struct
  type store = loc * (loc -> dvalue) * (loc -> int)
  fun fetch ((_, f, _): store) (l: loc) = f l
  fun upd ((n, f, g): store, l: loc, v: dvalue) =
    (n, fn i => if i = l then v else f i, g)
  fun fetchi ((_, _, g): store) (l: loc) = g l
  fun updi ((n, f, g): store, l: loc, v: int) =
    (n, f, fn i => if i = l then v else g i)

  exception Undefined

  fun eq (RECORD (a, i), RECORD (b, j)) =
        arbitrarily (i = j andalso eqlist (a, b), false)
    | eq (INT i, INT j) = i = j
    | eq (REAL a, REAL b) =
        arbitrarily (a = b, false)
    | eq (STRING a, STRING b) =
        arbitrarily (a = b, false)
    | eq (BYTEARRAY nil, BYTEARRAY nil) = true
    | eq (BYTEARRAY (a :: _), BYTEARRAY (b :: _)) = a = b
    | eq (ARRAY nil, ARRAY nil) = true
    | eq (ARRAY (a :: _), ARRAY (b :: _)) = a = b
    | eq (UARRAY nil, UARRAY nil) = true
    | eq (UARRAY (a :: _), UARRAY (b :: _)) = a = b
    | eq (FUNC a, FUNC b) = raise Undefined
    | eq (_, _) = false
  and eqlist (a :: al, b :: bl) =
        eq (a, b) andalso eqlist (al, bl)
    | eqlist (nil, nil) = true

  fun do_raise exn s =
    let val FUNC f = fetch s handler_ref
    in f [exn] s
    end

  fun overflow (n: unit -> int, c: dvalue list -> store -> answer) =
    if (n () >= minint andalso n () <= maxint) handle Overflow => false then
      c [INT (n ())]
    else
      do_raise overflow_exn

  fun overflowr (n, c) =
    if (n () >= minreal andalso n () <= maxreal) handle Overflow => false then
      c [REAL (n ())]
    else
      do_raise overflow_exn

  fun evalprim
        ( CPS.+ : CPS.primop
        , [INT i, INT j]: dvalue list
        , [c]: (dvalue list -> store -> answer) list
        ) =
        overflow (fn () => i + j, c)
    | evalprim (CPS.-, [INT i, INT j], [c]) =
        overflow (fn () => i - j, c)
    | evalprim (CPS.*, [INT i, INT j], [c]) =
        overflow (fn () => i * j, c)
    | evalprim (CPS.div, [INT i, INT 0], [c]) = do_raise div_exn
    | evalprim (CPS.div, [INT i, INT j], [c]) =
        overflow (fn () => i div j, c)
    | evalprim (CPS.~, [INT i], [c]) =
        overflow (fn () => 0 - i, c)
    | evalprim (CPS.<, [INT i, INT j], [t, f]) =
        if i < j then t [] else f []
    | evalprim (CPS.<=, [INT i, INT j], [t, f]) =
        if j < i then f [] else t []
    | evalprim (CPS.>, [INT i, INT j], [t, f]) =
        if j < i then t [] else f []
    | evalprim (CPS.>=, [INT i, INT j], [t, f]) =
        if i < j then f [] else t []
    | evalprim (CPS.ieql, [a, b], [t, f]) =
        if eq (a, b) then t [] else f []
    | evalprim (CPS.ineq, [a, b], [t, f]) =
        if eq (a, b) then f [] else t []
    | evalprim (CPS.rangechk, [INT i, INT j], [t, f]) =
        if j < 0 then if i < 0 then if i < j then t [] else f [] else t []
        else if i < 0 then f []
        else if i < j then t []
        else f []
    | evalprim (CPS.boxed, [INT _], [t, f]) = f []
    | evalprim (CPS.boxed, [RECORD _], [t, f]) = t []
    | evalprim (CPS.boxed, [STRING _], [t, f]) = t []
    | evalprim (CPS.boxed, [ARRAY _], [t, f]) = t []
    | evalprim (CPS.boxed, [UARRAY _], [t, f]) = t []
    | evalprim (CPS.boxed, [BYTEARRAY _], [t, f]) = t []
    | evalprim (CPS.boxed, [FUNC _], [t, f]) = t []
    | evalprim (CPS.!, [a], [c]) =
        evalprim (CPS.subscript, [a, INT 0], [c])
    | evalprim (CPS.subscript, [ARRAY a, INT n], [c]) =
        (fn s => c [fetch s (nth (a, n))] s)
    | evalprim (CPS.subscript, [UARRAY a, INT n], [c]) =
        (fn s => c [INT (fetchi s (nth (a, n)))] s)
    | evalprim (CPS.subscript, [RECORD (a, i), INT j], [c]) =
        c [nth (a, i + j)]
    | evalprim (CPS.ordof, [STRING a, INT i], [c]) =
        c [INT (String.ordof (a, i))]
    | evalprim (CPS.ordof, [BYTEARRAY a, INT i], [c]) =
        (fn s => c [INT (fetchi s (nth (a, i)))] s)
    | evalprim (CPS.:=, [a, v], [c]) =
        evalprim (CPS.update, [a, INT 0, v], [c])
    | evalprim (CPS.update, [ARRAY a, INT n, v], [c]) =
        (fn s => c [] (upd (s, nth (a, n), v)))
    | evalprim (CPS.update, [UARRAY a, INT n, INT v], [c]) =
        (fn s => c [] (updi (s, nth (a, n), v)))
    | evalprim (CPS.unboxedassign, [a, v], [c]) =
        evalprim (CPS.unboxedupdate, [a, INT 0, v], [c])
    | evalprim (CPS.unboxedupdate, [ARRAY a, INT n, INT v], [c]) =
        (fn s => c [] (upd (s, nth (a, n), INT v)))
    | evalprim (CPS.unboxedupdate, [UARRAY a, INT n, INT v], [c]) =
        (fn s => c [] (updi (s, nth (a, n), v)))
    | evalprim (CPS.store, [BYTEARRAY a, INT i, INT v], [c]) =
        if v < 0 orelse v >= 256 then raise Undefined
        else (fn s => c [] (updi (s, nth (a, i), v)))
    | evalprim (CPS.makeref, [v], [c]) =
        (fn (l, f, g) => c [ARRAY [l]] (upd ((nextloc l, f, g), l, v)))
    | evalprim (CPS.makerefunboxed, [INT v], [c]) =
        (fn (l, f, g) => c [UARRAY [l]] (updi ((nextloc l, f, g), l, v)))
    | evalprim (CPS.alength, [ARRAY a], [c]) =
        c [INT (List.length a)]
    | evalprim (CPS.alength, [UARRAY a], [c]) =
        c [INT (List.length a)]
    | evalprim (CPS.slength, [BYTEARRAY a], [c]) =
        c [INT (List.length a)]
    | evalprim (CPS.slength, [STRING a], [c]) =
        c [INT (String.size a)]
    | evalprim (CPS.gethdlr, [], [c]) =
        (fn s => c [fetch s handler_ref] s)
    | evalprim (CPS.sethdlr, [h], [c]) =
        (fn s => c [] (upd (s, handler_ref, h)))
    | evalprim (CPS.fadd, [REAL a, REAL b], [c]) =
        overflowr (fn () => a + b, c)
    | evalprim (CPS.fsub, [REAL a, REAL b], [c]) =
        overflowr (fn () => a - b, c)
    | evalprim (CPS.fmul, [REAL a, REAL b], [c]) =
        overflowr (fn () => a * b, c)
    | evalprim (CPS.fdiv, [REAL a, REAL 0.0], [c]) = do_raise div_exn
    | evalprim (CPS.fdiv, [REAL a, REAL b], [c]) =
        overflowr (fn () => a / b, c)
    | evalprim (CPS.feql, [REAL a, REAL b], [t, f]) =
        if a = b then t [] else f []
    | evalprim (CPS.fneq, [REAL a, REAL b], [t, f]) =
        if a = b then f [] else t []
    | evalprim (CPS.flt, [REAL i, REAL j], [t, f]) =
        if i < j then t [] else f []
    | evalprim (CPS.fle, [REAL i, REAL j], [t, f]) =
        if j < i then f [] else t []
    | evalprim (CPS.fgt, [REAL i, REAL j], [t, f]) =
        if j < i then t [] else f []
    | evalprim (CPS.fge, [REAL i, REAL j], [t, f]) =
        if i < j then f [] else t []

  type env = CPS.var -> dvalue

  fun V env (CPS.INT i) = INT i
    | V env (CPS.REAL r) =
        REAL (string2real r)
    | V env (CPS.STRING s) = STRING s
    | V env (CPS.VAR v) = env v
    | V env (CPS.LABEL v) = env v

  fun bind (env: env, v: CPS.var, d) =
    fn w => if v = w then d else env w

  fun bindn (env, v :: vl, d :: dl) =
        bindn (bind (env, v, d), vl, dl)
    | bindn (env, nil, nil) = env

  fun F (x, CPS.OFFp 0) = x
    | F (RECORD (l, i), CPS.OFFp j) =
        RECORD (l, i + j)
    | F (RECORD (l, i), CPS.SELp (j, p)) =
        F (nth (l, i + j), p)

  fun E (CPS.SELECT (i, v, w, e)) env =
        let val RECORD (l, j) = V env v
        in E e (bind (env, w, nth (l, i + j)))
        end
    | E (CPS.OFFSET (i, v, w, e)) env =
        let val RECORD (l, j) = V env v
        in E e (bind (env, w, RECORD (l, i + j)))
        end
    | E (CPS.APP (f, vl)) env =
        let val FUNC g = V env f
        in g (map (V env) vl)
        end
    | E (CPS.RECORD (vl, w, e)) env =
        E e (bind (env, w, RECORD (map (fn (x, p) => F (V env x, p)) vl, 0)))
    | E (CPS.SWITCH (v, el)) env =
        let val INT i = V env v
        in E (nth (el, i)) env
        end
    | E (CPS.PRIMOP (p, vl, wl, el)) env =
        evalprim
          ( p
          , map (V env) vl
          , map (fn e => fn al => E e (bindn (env, wl, al))) el
          )
    | E (CPS.FIX (fl, e)) env =
        let
          fun h r1 (f, vl, b) =
            FUNC (fn al => E b (bindn (g r1, vl, al)))
          and g r =
            bindn (r, map #1 fl, map (h r) fl)
        in
          E e (g env)
        end

  val env0 = fn x => raise Undefined

  fun eval (vl, e) dl =
    E e (bindn (env0, vl, dl))
end
```]

= 获取 SML/NJ

Standard ML of New Jersey 是许多人共同完成的工作（参见Acknowledgement）。该系统由普林斯顿大学和 AT&T 贝尔实验室联合开发，并有来自其他机构的贡献。

Standard ML of New Jersey 可以从 http://smlnj.org 获取。

= 延伸阅读

]}

#{
set heading(numbering: none)
show heading.where(level: 1): it => {
  set align(left)
  set text(font: ("Georgia", "Noto Serif CJK SC"))
  counter(figure.where(kind: image)).update(0)
  counter(figure.where(kind: table)).update(0)
  pagebreak(weak: true) + it.body + line(length: 100%) + v(1em)
}
[

#bibliography("bib.bib")

= 索引

]}
