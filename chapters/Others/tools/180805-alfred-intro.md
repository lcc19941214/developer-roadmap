# 利用nodeJs打造一款alfred workflow

> Any application that can be written in JavaScript, will eventually be written in JavaScript
—— Jeff Atwood 2007

[alfred](https://www.alfredapp.com/) 是mac上一款高效的工具，结合workflow功能可以大大提高日常工作的效率。

下面是的使用情况，可以说是每天不离手啊。

![](/assets/images/2018-08-05-18-29-03.png)

自从电脑装了 alfred （其实是有了powerpack）之后，总想自己写一个workflow。但是在alfred上找不到合适的文档，不知道应该如何在js里返回alfred需要的数据结构。

后来发现npm有一个 `alfy` 的库，结合yeoman和generator-alfred，就可以很容易的实现一款自己的alfred workflow啦！


alfred workflow介绍
用js编写workflow
alfred内置环境
使用nodejs运行
dependencies
alfy
yeoman
generator-alfred
notice

安装axa的时候可能会提示某个名为babel-xxx的依赖无法安装。如果使用cnpm的话可以顺利安装，使用npm的话可以手动先安装这个依赖，不然无法安装其他的依赖。

alfy是一个经过简单封装的工具库，能方便获取alfred的input，并且输出内容。安装alfy的同时也会同时安装xo和axa用于alfred-workflow的自动化测试。

执行generator-alfred，会自动生成工程目录，包括以下一些内容

info.plist 包含了workflow的所有信息
travis 默认你会把这个包发布出去并进行持续集成测试
.git 默认使用git进行版本管理