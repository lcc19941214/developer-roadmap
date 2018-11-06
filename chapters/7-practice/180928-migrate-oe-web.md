# 记一次项目迁移的踩坑记录

## 合并 git 仓库

这里先说一个坑，那就是一定要先合并仓库，再做迁移升级，否则手动拷贝过来到新仓库的文件，commit 信息会全部丢失并生成新的，后期必须再次手动操作，容易出差错。

### 合并方案
合并不同 git 仓库里的修改历史的方法有很多，简单说几种我这次尝试过的方案：
> 我们先假设有两个仓库 repo1, repo2，我们需要把 repo1 合并到 repo2
#### 方案一：`git merge`
最简单粗暴的方案，即把 repo1 设置为 repo2 的远端仓库，让 repo2 直接merge repo1 指定的分支即可。

```bash
cd repo2
# 1.将本地的 repo1 仓库添加为 repo2 一个（虚拟）远端仓库
# `-f` 仓库将在添加完成后自动执行 `git fetch` 操作
git remote add -f repo1 /fullpath/repo1

# 2. 在 repo2 本地仓库新建 branch/repo1 分支，并与远端的 repo1 仓库的 master 分支对齐
git checkout -b branch/repo1 repo1/master

# 3. 在 repo2 本地新建一个用于合并的分支（不建议直接在 master 分支操作）
git checkout -b branch/repo2 origin/master

# 4. 合并 branch/repo1 的改动。git@2.9 之后默认不允许两个不同的仓库合并，需要添加 `--allow-unrelated-histories`命令
git merge branch/repo1 --allow-unrelated-histories
```

到此为止还合并就完成了。但是这样的合并还存在很多问题：
1. 把整个 repo1 的改动都合并了过来，如果有大量的冲突，需要花费时间解决。
2. 有可能 repo1 有 be 和 fe 两个文件夹，但是只想保留 fe 里的改动，上述方案无法实现。

#### 方案二：`read-tree`
针对方案一的第一个问题，我们可以考虑使用 `merge --strategy` 和 `read-tree`来解决。

`merge --strategy` 可以指定一个如何合并冲突的策略，记录到当前的树当中，但是不将冲突写入硬盘。`read-tree` 可以将当前的树重写到指定的目录下。

```bash
cd repo2
git remote add -f repo1 /fullpath/repo1

# 1. 合并 repo1/master 分支到当前树，使用本地的改动覆盖对应分支的冲突但不写入硬盘，并且不进行提交
git merge -s=ours --no-commit repo1/master

# 2. 新建一个用于存放所有改动的文件夹
mkdir -p merge

# 3. 重写树，并且把改动都存放到 prefix 指定的目录中，必须以`/`结尾。
git read-tree --prefix=merge/ -u repo1/master
git commit -m 'done'
```

#### 方案三：`git filter-branch`
如果想过滤指定为文件，可以考虑使用 git filter-branch。

##### `--tree-filter <command>`
过滤整个树，对每个提交都执行同样的操作。可以用于删除不需要的文件。

**sample:**
```bash
git filter-branch --tree-filter --prune-empty 'ls -a | egrep -v "front\-end|\.git|\.$" | xargs rm -rf' HEAD
```

##### `--subdirectory-filter <directory>`

过滤整棵树，把指定的文件夹作为新的git仓库的根目录

**sample:**
```bash
git filter-branch -f --subdirectory-filter front-end
```

#### 参考
- [合并两个repo](https://blog.csdn.net/gouboft/article/details/8450696)
- [use read-tree to modify history](https://segmentfault.com/a/1190000000678808)
- [git-filter-branch](https://git-scm.com/docs/git-filter-branch)

---

## 自动遍历文件修改代码
很多时候旧代码中有一些方法、组件的使用方式已经过时了，需要批量修改，甚至是添加引用。如果逐个添加、修改、删除就会耗费大量的人力成本。

在本次迁移中，使用babel全家桶来解析指定的文件，生成AST，并在指定位置插入需要的代码，节省了大量时间。具体需要的依赖如下
- `@babel/parser` 解析代码生成AST
- `babel-traverse` 遍历AST指定节点
- `babel-template` 将代码转换为AST节点（非常有用，不需要手动构建节点）
- `babel-core` 将AST转换成代码

举个例子，比如我需要给指定的一堆文件头部添加下面这样一句依赖声明:
```js
import { basename } from 'data/router'
```
同时我们的eslint要求绝对路径的依赖声明必须放在相对路径依赖声明的前面。

让我们分步骤来解决这个问题：

**1. 生成AST**
将读取到的代码输入给 `@babel/parser` 即可。

这里parser使用的`plugins`和`babel-plugins-*`不是一个概念，具体可以参考文档 [ECMAScript proposals](https://babeljs.io/docs/en/babel-parser)
```js
const fs = require('fs');
const util = require('util');
const babelParser = require('@babel/parser');
const [readFile] = [fs.readFile].map(util.promisify);

async function parse(filename) {
  const content = await readFile(route, 'utf-8');

  // 语法解析
  const ast = babelParser.parse(content, {
    sourceType: 'module',
    plugins: [
      'jsx',
      'asyncGenerators',
      'classProperties',
      'decorators-legacy',
      'objectRestSpread'
    ],
  });

  ...
}
```

**2. 构建要插入的代码片段的AST节点**
直接使用`babel-template`即可。
```js
const template = require('babel-template');

async function parse(filename) {
  ...

  const myCode = template("import { basename } from 'data/router'", {
    sourceType: 'module',
  });

  ...
}
```

**3. 修改AST**
这里需要借助`babel-traverse`遍历之前生成的AST。这里用到了[访问器](https://en.wikipedia.org/wiki/Visitor_pattern)，具体的节点可以参考[@babel/types](https://babeljs.io/docs/en/next/babel-types.html)。

下面的代码访问了代码主体（Program），过滤掉依赖声明是相对路径的节点并取出符合要求的节点的最后一个。最后判断当前文件没有引入'data/router'（这里有点问题，因为OE项目之前没有引入过，所以直接这样判断了，实际上还要考虑如果已有同模块的引入，应该是修改该节点而不是插入新的），则插入我们构建的AST节点。

```js
const traverse = require('babel-traverse').default;

async function parse(filename) {
  ...
  traverse(ast, {
    Program(nodePath) {
      let duplicated = false;
      const targetNode = nodePath
        .get('body')
        .filter((p) => {
          if (p.isImportDeclaration()) {
            const { value } = p.node.source;
            if (value === 'data/router') duplicated = true;
            return !value.startsWith('.');
          }
          return false;
        })
        .pop();

      if (!duplicated && targetNode) targetNode.insertAfter(myCode());
    },
  });
  ...
}
```

**4. 生成代码**
这一步就比较简单了，直接使用`babel-core`即可
```js
const babel = require('babel-core');

async function parse(filename) {
  ...

  const { code } = babel.transformFromAst(ast, null, {
    retainLines: true, // 使用此配置可以让babel尽量保留转换前的代码格式
  });
  return code;
}
```

---

## 使用yarn resolutions 解决依赖问题
老People把依赖的`antd@1.3.2`打包到了`dll/lib.min.js`当中，因此很长一段时间里没有人做lib的构建，则一直不会更新antd版本，仓库里node_modules/antd的版本号就只是一个摆设。

为什么这么说呢？因为antd@1.3.2依赖的很多包其实已经更新了，比如rc-select，rc-form等。

antd@1.3.2的部分依赖如下：
```
    ...
    "rc-input-number": "~2.5.10",
    "rc-menu": "~4.12.3",
    "rc-notification": "~1.3.4",
    "rc-pagination": "~1.5.3",
    "rc-progress": "~1.0.4",
    "rc-time-picker": "~1.1.4",
    "rc-tooltip": "~3.3.2",
    "rc-tree": "~1.3.1",
    ...
```
注意这里的语义化符号`~`和`^`，这意味着不使用package-lock.json或yarn.lock时，每次安装的antd的依赖都是在不断更新的。

但是配合yarn.lock锁版本后，还是会有一个问题，antd自身构建的代码当中已经包含的依赖版本，和单独安装的依赖的源码版本不一致。简单来说，就是dist/antd.js打包进的依赖版本，和lib内依赖的代码版本不一致。

```shell
.
├── CHANGELOG.md
├── LICENSE
├── dist
│   ├── antd.css
│   ├── antd.js
│   ├── antd.less
│   ├── antd.min.css
│   ├── antd.min.js
├── index.d.ts
├── lib
├── node_modules
└── package.json
```

dist内是构建后的代码，lib内是babel转义后的源码。在项目中不同的引用方式会导致引入不同的代码：

```javascript
// 直接引入时，会全量引入 antd/dist/antd.js
import { Button } from 'antd';

// 配合 babel-plugin-import 按需加载时，会从 antd/lib/*中引入使用的组件
// 编译前
import { Button } from 'antd';

// 编译后
import Button from 'antd/lib/button/index.js'
```

当OE项目迁移后，使用了按需加载的方式引入 `antd@1.3.2`，此时获取到的组件版本已经和之前 `dll/lib.min.js` 中打包的 `antd/dist/antd.js` 的组件版本差了太多。而很多二次封装的组件都是以dll中的antd的版本开发的，这就导致迁移完之后很多组件没法使用了。

为了保证 antd/dist 和 antd/lib 各自的依赖版本一致，就需要让antd的依赖版本被锁死至指定版本。不过antd本身的package.json的写法就带了语义符号，该怎么办呢？

可以参考yarn提供的[resolutions解决方案](https://yarnpkg.com/zh-Hans/docs/selective-version-resolutions)，为项目的依赖指定其子依赖的版本。基于此，指定antd的子依赖版本即可。

我的做法时，去掉了antd子依赖左右的语义符号，直接用对应版本。
