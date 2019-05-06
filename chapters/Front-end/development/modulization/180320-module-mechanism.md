# 模块化机制

## 模块化
- [知乎-前端开发的模块化和组件化的定义，以及两者的关系？](https://www.zhihu.com/question/37649318)
- [javascript模块循环加载](http://www.ruanyifeng.com/blog/2015/11/circular-dependency.html)

  - commonJS 同步加载。循环引用时，只加载模块已执行的部分。
  - Es6 参考webpack打包的esmodules代码，es加载模块的内容，是保持了一个对模块导出部分的引用。

## 打包
- 那个是 CSS/JS 的发布时的合并，因为你写的时候，特别是应用了各种预处理器以及衍生语言等写 CSS/JS 的时候，源代码的处境是为了写代码，为了易于管理和阅读，你的代码通常会分布在多个文件中，在发布的时候就不需要那样了，而且浏览器还不一定吃你的源代码 （比如你写的是 SCSS，CoffeeScript，模块化的 JS，JSX……），所以需要有编译 -> 打包这个过程，其中包括把你的源代码变成浏览器吃的代码，自动前缀，最小化，连接，混淆等操作，一般最后输出就是一个整的 CSS 或者 JS 文件。
- 这个是在处理依赖管理的时候遇到的包，指的是更接近软件包的概念，例如你写程序的时候用了一些别人的“库”或者“组件”，实际的体现就是你通过 npm，bower 等依赖管理（或者叫包管理器）来管理你的项目的外部依赖。比如你在你的项目里面用了一个 bootstrap，通常的方式是你可以直接下载官网发布的程序，然后解压，放到你的项目文件夹里面，但是有了 bower 之后，你就可以直接通过 bower 一键来帮你完成这些事情，在你的程序很复杂，用的库很多的时候，手动一个个下载和更新那就是非常繁琐的事情了，所以有了这样的依赖管理工具来帮助你处理这 些琐事，同时你自己的项目也是作为一个“包”来被处理的，通过记录你的“包”依赖的其他包的信息，然后那些依赖管理工具就能够自动帮你搞定后面的事情了