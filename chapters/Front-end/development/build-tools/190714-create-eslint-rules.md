# 如何编写一个 eslint 插件？

## 准备

- 什么是 [eslint](https://eslint.org/)？
- 如何配置 [eslintrc](https://eslint.org/docs/user-guide/configuring)？
- 什么是 [AST](https://zh.wikipedia.org/zh-hans/%E6%8A%BD%E8%B1%A1%E8%AA%9E%E6%B3%95%E6%A8%B9)？



## 正文

### 开始编写 eslint 插件

>  官方推荐使用 [yeoman generator-eslint](https://www.npmjs.com/package/generator-eslint) 脚手架快速生成 eslint plugin模版，不过已经3年没有更新了，感兴趣可以看看这个脚手架的源码。



#### 编写规则

编写一个规则，其实就是在 eslint 提供的 AST 中，找到我们需要检查的 AST 节点，对其进行判断，如何符合条件，就抛出相关提示。

##### 遍历 AST 节点

参考以下代码：

```js
module.exports = {
    create: function(context) {
        // declare the state of the rule
        return {
            ReturnStatement: function(node) {
                // at a ReturnStatement node while going down
            },
            // at a function expression node while going up:
            "FunctionExpression:exit": checkLASTSegment,
            "ArrowFunctionExpression:exit": checkLASTSegment,
            onCodePathStart: function (codePath, node) {
                // at the start of analyzing a code path
            },
            onCodePathEnd: function(codePath, node) {
                // at the end of analyzing a code path
            }
        };
    }
};

```

上述代码中，create 方法返回的对象，就是 AST 节点 “遍历器” 的集合。我们可以直接声明 [estree 中支持的 AST types](https://github.com/estree/estree/blob/mASTer/es2015.md)；同时，eslint 所依赖的 espree，也支持使用类似 css 选择器的 [selector](https://eslint.org/docs/developer-guide/selectors) 强大语法，对 AST types 进行组装。

如果对特定代码片段的 AST 结构非常陌生，可以考虑编写一段 demo 代码，使用 espree 进行解析，可以根据得到的 AST 中编写“遍历器”。

[context](https://eslint.org/docs/developer-guide/working-with-rules#the-context-object) 相关 api 可以参考官方文档的说明。



##### 抛出错误提示

context 对象提供了一个 [`report`](https://eslint.org/docs/developer-guide/working-with-rules#contextreport) 方法，用于抛出警告和错误提示。

最基本的用法如下：

```js
context.report({
    node: node,
    message: "Unexpected identifier"
});
```

report 方法也支持变量插值：

```js
context.report({
    node: node,
    message: "Unexpected identifier: {{ identifier }}",
    data: {
        identifier: node.name
    }
});
```



##### Example

让我们来实战一下，现在我们需要限制用户调用 `new Date()` 方法。

1. 如果你不知道一个 `new Date()` AST 节点是什么样子的，可以试试编写demo代码，得到一个初始化的 AST 结构

   ```js
   // demo code
   const code = `
   const a = new Date();
   const b = new Date('adwad');
   `;
   
   const espree = require('espree');
   const fs = require('fs');
   const ast = espree.parse(code, {
     ecmaVersion: 6
   });
   ```

   <details>
     <summary>AST</summary>
     <pre>
     {
     "type": "Program",
     "start": 0,
     "end": 52,
     "body": [
       {
         "type": "VariableDeclaration",
         "start": 1,
         "end": 22,
         "declarations": [
           {
             "type": "VariableDeclarator",
             "start": 7,
             "end": 21,
             "id": {
               "type": "Identifier",
               "start": 7,
               "end": 8,
               "name": "a"
             },
             "init": {
               "type": "NewExpression",
               "start": 11,
               "end": 21,
               "callee": {
                 "type": "Identifier",
                 "start": 15,
                 "end": 19,
                 "name": "Date"
               },
               "arguments": []
             }
           }
         ],
         "kind": "const"
       },
       {
         "type": "VariableDeclaration",
         "start": 23,
         "end": 51,
         "declarations": [
           {
             "type": "VariableDeclarator",
             "start": 29,
             "end": 50,
             "id": {
               "type": "Identifier",
               "start": 29,
               "end": 30,
               "name": "b"
             },
             "init": {
               "type": "NewExpression",
               "start": 33,
               "end": 50,
               "callee": {
                 "type": "Identifier",
                 "start": 37,
                 "end": 41,
                 "name": "Date"
               },
               "arguments": [
                 {
                   "type": "Literal",
                   "start": 42,
                   "end": 49,
                   "value": "adwad",
                   "raw": "'adwad'"
                 }
               ]
             }
           }
         ],
         "kind": "const"
       }
     ],
     "sourceType": "script"
   }
     </pre>
   </details>

   可以发现，`new Date()` 方法的调用，在 AST 中的 type 为 `NewExpression`。这里的 `init`其实就是 eslint 中的 node 节点。

2. 现在我们需要判断，一个 AST 节点，是否是 `new Date()`

   ```js
   {
      NewExpression(node) {
        const { callee } = node;
        if (callee.name === 'Date') {
          // your code here
        }
      }
   }
   ```

3. 找到正确的代码语句后，我们需要抛出提示

   ```js
   {
     NewExpression(node) {
       const { callee } = node;
       if (callee.name === 'Date') {
         const message = 'Do not using `new Date()` at all!';
         context.report(node, message);
       }
     }
   }
   ```

4. 现在你会发现，一个自定义的规则就大功告成了

  ```js
  module.exports = {
    rules: {
      'no-date-string-construct': {
        create: function(context) {
          return {
            NewExpression(node) {
              const { callee } = node;
              if (callee.name === 'Date') {
                const message = 'Do not using `new Date()` at all!';
                context.report(node, message);
              }
            }
          };
        }
      }
    }
  }
  ```



#### 使用规则

##### plugins + rules

eslint 提供了接入 plugin 的方式，使用 `plugins`字段即可。需要注意的是，这里配置的 plugin 名称，不需要再声明 `eslint-plugin` 的前缀。

引入 plugin 后，就可以直接在 `rules` 中添加该插件中定义的各个规则。与 eslint 内置的规则不同，使用 plugin 的规则，需要声明命名空间，采用 `'namespace/rule-name'` 的形式。

```js
// eslintrc.js
module.exports = {
  plugins: ['my-rules'],
  rules: {
    "my-rules/my-rule": 2
  }
}
```

如果你编写的 plugin 尚未发布 npm 包，可以使用以下方式把一个开发中的包加入到当前工作目录下的 node_modules 中

```shell
yarn add -D file:path/to/eslint-plugin-my-rules
```



##### extends

一个插件可以提供预设好的多个规则，让使用者直接引入。

plugin内的配置如下：

```javascript
// eslint-plugin-my-rules
module.exports = {
    configs: {
    recommended: {
      plugins: ['my-rules'],
      rules: {
        'my-rules/my-rule': 1
      }
    }
  }
}
```

使用者的配置如下：

```js
// eslintrc.js
module.exports = {
  extends: ['plugin:my-rules/recommended']
}
```



## 参考内容

- [Create custom ESLint rules in 2 minutes](https://blog.webiny.com/create-custom-eslint-rules-in-2-minutes-e3d41cb6a9a0)
- [AST抽象语法树——最基础的javascript重点知识，99%的人根本不了解](https://segmentfault.com/a/1190000016231512)
- [Working with Rules](https://eslint.org/docs/developer-guide/working-with-rules)
- [Working with Plugins](https://eslint.org/docs/developer-guide/working-with-plugins)