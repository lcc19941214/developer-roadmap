# 性能检测：performance 对象

![](/assets/images/2018-07-20-17-41-14.png)

## `Performance`对象

```javascript
// 获取 performance 数据
var performance = {
    // memory 是非标准属性，只在 Chrome 有
    // 财富问题：我有多少内存
    memory: {
        usedJSHeapSize:  16100000, // JS 对象（包括V8引擎内部对象）占用的内存，一定小于 totalJSHeapSize
        totalJSHeapSize: 35100000, // 可使用的内存
        jsHeapSizeLimit: 793000000 // 内存大小限制
    },

    //  哲学问题：我从哪里来？
    navigation: {
        redirectCount: 0, // 如果有重定向的话，页面通过几次重定向跳转而来
        type: 0           // 0   即 TYPE_NAVIGATENEXT 正常进入的页面（非刷新、非重定向等）
                          // 1   即 TYPE_RELOAD       通过 window.location.reload() 刷新的页面
                          // 2   即 TYPE_BACK_FORWARD 通过浏览器的前进后退按钮进入的页面（历史记录）
                          // 255 即 TYPE_UNDEFINED    非以上方式进入的页面
    },

    timing: {
        // 在同一个浏览器上下文中，前一个网页（与当前页面不一定同域）unload 的时间戳，如果无前一个网页 unload ，则与 fetchStart 值相等
        navigationStart: 1441112691935,

        // 前一个网页（与当前页面同域）unload 的时间戳，如果无前一个网页 unload 或者前一个网页与当前页面不同域，则值为 0
        unloadEventStart: 0,

        // 和 unloadEventStart 相对应，返回前一个网页 unload 事件绑定的回调函数执行完毕的时间戳
        unloadEventEnd: 0,

        // 第一个 HTTP 重定向发生时的时间。有跳转且是同域名内的重定向才算，否则值为 0 
        redirectStart: 0,

        // 最后一个 HTTP 重定向完成时的时间。有跳转且是同域名内部的重定向才算，否则值为 0 
        redirectEnd: 0,

        // 浏览器准备好使用 HTTP 请求抓取文档的时间，这发生在检查本地缓存之前
        fetchStart: 1441112692155,

        // DNS 域名查询开始的时间，如果使用了本地缓存（即无 DNS 查询）或持久连接，则与 fetchStart 值相等
        domainLookupStart: 1441112692155,

        // DNS 域名查询完成的时间，如果使用了本地缓存（即无 DNS 查询）或持久连接，则与 fetchStart 值相等
        domainLookupEnd: 1441112692155,

        // HTTP（TCP） 开始建立连接的时间，如果是持久连接，则与 fetchStart 值相等
        // 注意如果在传输层发生了错误且重新建立连接，则这里显示的是新建立的连接开始的时间
        connectStart: 1441112692155,

        // HTTP（TCP） 完成建立连接的时间（完成握手），如果是持久连接，则与 fetchStart 值相等
        // 注意如果在传输层发生了错误且重新建立连接，则这里显示的是新建立的连接完成的时间
        // 注意这里握手结束，包括安全连接建立完成、SOCKS 授权通过
        connectEnd: 1441112692155,

        // HTTPS 连接开始的时间，如果不是安全连接，则值为 0
        secureConnectionStart: 0,

        // HTTP 请求读取真实文档开始的时间（完成建立连接），包括从本地读取缓存
        // 连接错误重连时，这里显示的也是新建立连接的时间
        requestStart: 1441112692158,

        // HTTP 开始接收响应的时间（获取到第一个字节），包括从本地读取缓存
        responseStart: 1441112692686,

        // HTTP 响应全部接收完成的时间（获取到最后一个字节），包括从本地读取缓存
        responseEnd: 1441112692687,

        // 开始解析渲染 DOM 树的时间，此时 Document.readyState 变为 loading，并将抛出 readystatechange 相关事件
        domLoading: 1441112692690,

        // 完成解析 DOM 树的时间，Document.readyState 变为 interactive，并将抛出 readystatechange 相关事件
        // 注意只是 DOM 树解析完成，表明可以操作DOM树了
        // 但是这个时候 DOM 树不一定稳定，因为内部和外部的 script 脚本可能会操作 DOM 树
        domInteractive: 1441112693093,

        // DOM 解析完成后，网页内资源加载开始的时间
        // 在 DOMContentLoaded 事件抛出前发生
        domContentLoadedEventStart: 1441112693093,

        // DOM 解析完成后，读完</html>标签
        domContentLoadedEventEnd: 1441112693101,

        // DOM 树解析完成，且资源也准备就绪的时间，Document.readyState 变为 complete，并将抛出 readystatechange 相关事件
        domComplete: 1441112693214,

        // load 事件发送给文档，也即 load 回调函数开始执行的时间
        // 注意如果没有绑定 load 事件，值为 0
        loadEventStart: 1441112693214,

        // load 事件的回调函数执行完毕的时间
        loadEventEnd: 1441112693215
    }
};
```

## `domReady` vs `onload`

`domReady`是jQuery提供的一个事件。我理解`domReady`是对`onreadystatechange`事件的封装。核心逻辑即提供一个页面DOM结构稳定之后的事件接口。 可以通过下列代码实现：

```javascript
document.onreadystatechange = function(e) {
  const { readyState } = document;
  switch (readyState) {
    case 'loading':
      // ...
    case 'interactive':
      // ...
    case 'complete':
      // ...
  }
}
```

不过也有文章指出目前的实现存在一些问题，可以参考[DOM Ready 详解 - 张子秋的博客](http://www.cnblogs.com/zhangziqiu/archive/2011/06/27/DOMReady.html)。比如 setTimeout onload 'interactive' 的触发时机均存在不符合预期的情况。

## 几个时间点

### DOMContentLoaded

先来看看 [MDN](https://developer.mozilla.org/en-US/docs/Web/Events/DOMContentLoaded) 中的定义：

> The **DOMContentLoaded** event is fired when the initial HTML document has been completely loaded and parsed, without waiting for stylesheets, images, and subframes to finish loading

也就是说浏览器会在 HTML 加载完毕后就会触发该事件，不会等待样式表、图像，以及一些子框架（iframes）的加载完成。

那什么叫"`the initial HTML document has been completely loaded and parsed`"呢？我们知道浏览器一般是逐行解析 document 的，所以我 parser 读完最后一行`</html>`标签时，HTML 也就加载完了。

不过这里有一个点有待商榷，那就是浏览器真的不会等待样式表的加载完成吗？

Patrick Sexton在["What is domContentLoaded?"](https://varvy.com/performance/domcontentloaded.html)中提到了以下四点内容：

> 1. domContentLoaded is the point when both the DOM is ready and there are no stylesheets that are blocking JavaScript execution.
> 2. This event typically marks when both the DOM and CSSOM are ready
> 3. This means that the render tree can now be built
> 4. If there is no parser blocking JavaScript then DOMContentLoaded will fire immediately after domInteractive

上述第一点结论明确指出该事件在没有样式表阻塞js执行时，才会触发。根据第四点我们可以知道，所有阻塞 parser 线程的脚本都执行结束后，DOMContentLoaded事件才会触发。也就是说，阻塞 parser 线程的脚本（比如设置了`defer`的外部脚本），一定会在DOMContentLoaded之前触发。更准确的说法是：

> Scripts with the defer attribute will prevent the DOMContentLoaded event from firing until the script has loaded and finished evaluating.

那这里的样式表有可能阻塞哪里的js代码呢？

这里就需要说说 script 标签了。参考规范对 [The script element](https://www.w3.org/TR/html5/semantics-scripting.html#list-of-scripts-that-will-execute-when-the-document-has-finished-parsing) 标签的定义，满足下图条件的script标签（主要就是defer脚本中的js代码），浏览器会把其中的代码放到一个叫做`list of scripts that will execute when the document has finished parsing`的队列当中。

![](/assets/images/2018-07-27-13-39-50.png)

根据事件循环的模型，我们知道 parser 解析 HTML 过程中的 js 代码都是同步执行的，异步执行的代码（ajax请求、定时器等）会被放进事件队列。当 HTML 解析结束后，事件循环会检查事件队列中是否有需要执行的代码，如果有就会开始执行。parser 解析完成后，浏览器会执行一个类似的操作。结合规范中 `Parsing HTML document` 过程对 `the end` 环节中一个步骤的定义：

> Spin the event loop until the first script in the list of scripts that will execute when the document has finished parsing has its "ready to be parser-executed" flag set and the parser’s Document has no style sheet that is blocking scripts.

可知浏览器结束解析过程后，会检查上述的script队列，如果有待执行的script，则取出并执行。

因此，样式表的加载是有可能阻塞所谓`list of scripts that will execute when the document has finished parsing`这个队列中的脚本的。

当 DOMContentLoaded 事件触发后，浏览器还会遍历下面两个队列中的script并执行（如果有）

*   `set of scripts that will execute as soon as possible`

    该队列中的代码会尽可能快的执行。如添加了async的脚本，会在加载完成后立刻执行。
* `list of scripts that will execute in order as soon as possible`

这里涉及到不同条件的 script，具体可以参考文档。

### DOMComplete

Patrick Sexton在["What is domComplete?"](https://varvy.com/performance/domcomplete.html)中指出：

* The domComplete time represents the end of the browser processing a document. The browser has received the document, processed it and has done the same for the page subresources like images and CSS.
* To a user, this is the point where the browser tab spinner stops spinning. To a developer, this marks the beginning of the time to add additional application logic / javascript.

## 参考：

> [spec - Parsing HTML documents](https://www.w3.org/TR/html5/syntax.html#parsing-html-documents) [spec - Scripting](https://www.w3.org/TR/html5/semantics-scripting.html#list-of-scripts-that-will-execute-when-the-document-has-finished-parsing) [speed - performance](https://varvy.com/performance/)
