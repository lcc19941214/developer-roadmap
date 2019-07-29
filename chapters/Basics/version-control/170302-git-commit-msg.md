# Writing advice on commit message

### Format
- **Header** (required)
- **Body** (optional)
- **Footer** (optional)

```
<type>(<scope>): <subject>
\n
<body>
\n
<footer>
```



#### Header

`Header` should contain **type**(required), **scope**(optional) and **subject**(required) in one line.

##### 1. type

`type` is used to describe the type of a commit.
Several commonly used types are provided for consideration:

```
- feat: new feature
- fix: fix bug
- refactor: modifications other than features or fixes
- release: release a new version
- style: format or beautify code without effects on main function
- chore: modifications of dependencies or build tools
- docs: write documentation(e.g. README.md)
```

##### 2. scope
`scope` describes the scope of a commit, such as view layer, data layer, etc.

##### 3. subject
`subject` is a brief description of a commit and it's suggested to be limited in 50 characters.

    - start with a verb
    - end without a period



#### Body

`Body` contains more detailed explanatory text where contents could be wapped to multiple lines.

```
feat(font-end): click affix to back to homepage

- add affix component in all detail pages
- add css styles for user interface
```



#### Footer

`Footer` is an uncommon part. When some **breaking changes** are added to a commit, it's mainly used to append descriptions, reasons and methods of migration



### Appendix
Below is some commits from Lark/pc-client repository:

```vim
commit xxxxxx
Author: xxx <xxx@abc.com>
Date:   Tue Feb 21 18:47:17 2017 +0800

    relase: version 0.5.9

    Change-Id: xxxxxx


commit xxxxxx
Author: xxx <xxx@abc.com>
Date:   Mon Feb 20 22:12:18 2017 +0800

    feat: 一些细节优化

    1. 切换会话input focus
    2. 点击群会话聊天头像直接进入单人会话
    3. 群描述没有时不再显示“无说明”
    4. 欢迎界面修改

    Change-Id: xxxxxx


commit xxxxxx
Author: xxx <xxx@abc.com>
Date:   Mon Feb 20 13:21:58 2017 +0800

    fix: sessionid获取失败时 没有重连websocket

    Change-Id: xxxxxx


commit xxxxxx
Author: xxx <xxx@abc.com>
Date:   Tue Feb 28 11:07:25 2017 +0800

    style: 不在ui规范中的颜色不占用对应的变量名

    Change-Id: xxxxxx
```



### Reference
- [《Commit message 和 Change log 编写指南》（阮一峰）](http://www.ruanyifeng.com/blog/2016/01/commit_message_change_log.html)
- [5 Useful Tips For A Better Commit Message](https://robots.thoughtbot.com/5-useful-tips-for-a-better-commit-message)
