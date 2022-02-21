# Jest Snapshot 使用指南

## Intro

* [Testing with Jest Snapshots: First Impressions](http://benmccormick.org/2016/09/19/testing-with-jest-snapshots-first-impressions/)
* [官方文档](https://jestjs.io/docs/en/snapshot-testing)

## Usage

* 如何生成快照？
  * [第一次测试时，会自动生成](https://jestjs.io/docs/en/snapshot-testing#snapshot-testing-with-jest)
* 如何测试？
  * `toMatchSnapshot()`
* 怎么更新快照？
  * [仅在你修改了视图后才需要更新 `jest -u`](https://jestjs.io/docs/en/snapshot-testing#updating-snapshots)

## Tips

1.  snapshot 可以快速在已有项目中使用，方便后期的迭代

    > (It) works well for us since our code base currently contains a large amount of code that is difficult to test for one reason or another.

    ​ 记住两点：

    * 初始化时，在测试用例中调用 toMatchSnapshot
    * 修改视图后，使用  jest -u 更新snapshot
2. snapshot只是一个简化测试的辅助手段，而不能作为测试的替代品。 react/vue 组件单测，还需要配合 enzyme，编写简易的交互逻辑，不能全指望snapshot
3.  缺点

    > Like any other test, if the initial snapshot passes with bugs, or doesn’t capture the full range of cases, the test won’t adequately cover those behaviors.

    snapshot test和普通的测试没有区别，也存在 case 覆盖不全，导致快照对比不完整的情况。

## Common Issues

### 如何让 jest 识别未编译的code？

我们编写的测试用例，大多数场景下都是直接引用的开发代码，即基于 esNext 编写的代码。如果不做额外的处理，测试引入的 jsx、ts、tsx文件，以及未经转义的 node\_modules 包，都有可能让单测跑不起来。

所以需要用到 jest 提供的 [transform](https://jestjs.io/docs/en/configuration#transform-object-string-string)，同步编译测试过程中使用到的资源。官方已经为我们实现了一个插件，[babel-jest-plugin](https://github.com/facebook/jest/tree/master/packages/babel-jest#setup)，可以直接读取本地的 .babelrc，可以做到和 webpack 同样的编译效果，使用方式如下：

```javascript
{
    transform: {
        '^.+\\.(js|jsx|ts|tsx)$': 'babel-jest'
    },
}
```

但是，对于 node\_modules 中某些包引用依赖，babel-jest默认会从相对目录读取配置，如果对应的包没有设置.babelrc，就会导致转义不成功。

因此可以使用[自定义 transformer](https://jestjs.io/docs/en/tutorial-react#custom-transformers) 的方式来规避上述问题：

```javascript
// jest.transformer.js
const babelJest = require('babel-jest');
const options = require('./.babelrc.js');

// test 过程中，有可能引入 es 版本的 node_modules 代码，
// 而 babel-jest 默认会根据相对路径读取 babelrc。
// 所以使用自定义的 transformer, 手动注入 babel options, 避免上述问题
module.exports = babelJest.createTransformer(options);


// jest.config.js
{
    transform: {
        '^.+\\.[t|j]sx?$': './jest.transformer.js',
    },
}
```
