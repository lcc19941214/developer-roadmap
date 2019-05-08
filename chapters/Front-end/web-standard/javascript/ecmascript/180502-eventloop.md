# Event Loop

## Browser

### JS的执行
浏览器中，函数的执行会被推入一个执行栈，称之为`Call Stack`. 每一次函数调用就进栈，调用结束就出栈，知道所有代码执行完毕。

我们知道JS的代码一般都是同步执行的，但是浏览器也提供了一些异步API，比如 DOM 事件、AJAX 请求、定时器等。当代码调用了异步API，并且设置了回调函数，浏览器会把这些回调函数放入一个任务队列中（`Callback Queue`）。

当执行栈中的代码被阻塞时，任务队列依然能够工作。
比如，页面渲染卡顿时，点击页面元素，页面卡顿结束后，点击事件依然能够触发，因为点击时的回调会被放入任务队列中，等待执行栈代码执行结束后被调用。

![](/assets/images/2018-07-20-16-18-46.png)

### Macrotask & Microtask

    - An event loop has one or more task queues.(task queue is macrotask queue)
    - Each event loop has a microtask queue.
    - task queue = macrotask queue != microtask queue
    - a task may be pushed into macrotask queue,or microtask queue
    - when a task is pushed into a queue(micro/macro),we mean preparing work is finished,so the task can be executed now.

翻译并提炼一下：
1. macrotask 其实就是 task queue，而microtask 不是任务队列。
2. 一个任务可以被放入到macrotask队列，也可以放入microtask队列

- macrotasks
script（初始化加载的代码）、setTimeout、setInterval、I/O 操作、UI rendering

- microtasks 
process.nextTick，promise，ObjectObserver，MutationObserver

### 事件循环过程解析

大致的过程如下：

![](/assets/images/2019-05-07-17-15-07.png)

- JS引擎准备就绪，当全局上下文（script 标签）被推入执行栈时，同步代码开始执行
- 在执行的过程中，会判断是同步任务还是异步任务：
  - 如果是同步任务，或者当前任务产生了新的同步任务，执行栈会推入新的任务立即执行
  - 如果是异步任务，或者当前任务产生了新的异步任务，异步调用的回调函数会被推入任务队列中
- 当前执行栈中的宏任务出栈后，如果存在未执行的 microtasks，会将对应的 microtasks 全部执行。处理microtask期间，如果有新添加的microtasks，也会被添加到队列的末尾并执行。
- 执行栈中的任务全部执行结束之后，浏览器的事件循环会不停轮询事件队列，如果有准备就绪的回调函数，会取出其中的任务并推入栈中执行，执行结束后出栈
- 执行渲染操作
- 检查是否存在 Web worker 任务，如果有，则对其进行处理
- 重复上述过程，直到执行栈和任务队列都被清空

需要注意的是，宏任务出栈时，是一个一个出栈的，只有前一个任务执行完毕，才能执行后一个任务。而微任务出队时，是一队一队出队的，即全部执行完。因此，在处理 micro 队列这一步，会逐个执行队列中的任务并把它出队，直到队列被清空。

我们总结一下，每一次循环都是一个这样的过程：

![](/assets/images/2019-05-07-17-15-17.png)

参考以下代码：
```js
setTimeout(() => {
  Promise.resolve().then(() => {
    console.log('promise-1');
    Promise.resolve().then(() => {
      console.log('promise-2');
      Promise.resolve().then(() => {
        console.log('promise-3');
      })
    })
  })
  console.log(1)
}, 0);

setTimeout(() => {
  Promise.resolve().then(() => {
    console.log('promise-4');
    Promise.resolve().then(() => {
      console.log('promise-5');
      Promise.resolve().then(() => {
        console.log('promise-6');
      })
    })
  })
  console.log(2)
}, 0);
```

在 Chrome v73 中的输出结果为：
```shell
1
promise-1
promise-2
promise-3
2
promise-4
promise-5
promise-6
```

在浏览器中，第一个定时器触发后，执行栈压入定时器回调函数，输出 1 并出栈。宏任务出栈后执行微任务，并且把微任务执行过程中的产生的微任务都执行掉，所以陆续输出promise-1、promise-2、promise-3。第二个定时器同理。

## Node

> 这里不会细讲 Node 的事件循环的实现原理，如有需要，可以参考《NodeJS 深入浅出》中朴灵在第三章“异步I/O”中的相关介绍。

Node 的事件循环和浏览器略有一些不一样。如图，Node 的事件循环有以下几个阶段：

![](/assets/images/2019-05-07-16-54-12.png)

每一个阶段都会有一个先进先出的队列。当事件循环进入到这个阶段时，会依次执行对应阶段的队列中的任务，直到队列清空或者是执行回调的次数超过最大上限。一个阶段的任务全部执行结束后（或者是达到调用上限），事件循环就会进入到下一个阶段。
在poll阶段执行队列中的回调函数，可能会产生新的事件与回调函数，因此事件循环可能会在此阻塞。

### 各阶段概览

- **timers** 执行 `setTimeout` 和 `setInterval`
- **pending callbacks** 执行前一次循环过程中，尚未执行的 I/O 回调
- **idle, prepare** 仅在 Node 内部调用
- **poll** 
  - 获取新的 I/O 事件并执行相关回调。基本上除了 close callbacks，定时器任务 和 setImmediate ，poll会执行所有类型的回调
  - 这个阶段的时间会比较长。如果没有其他异步任务要处理（比如到期的定时器），会一直停留在这个阶段，等待 I/O 请求返回结果。
- **check** 执行 setImmediate 回调
- **close callbacks** 执行一些 close 事件的回调，比如 `socket.on('close', ...)`

### 各阶段具体的内容

#### timers

timers 阶段会执行 setTimeout 和 setInterval 回调，并且是由 poll 阶段控制的。
同样，在 Node 中定时器指定的时间也不是准确时间，只能是尽快执行。

#### pending callbacks

此阶段会执行一些系统操作的回调，比如 TCP 连接抛出的异常事件。

#### poll

poll 阶段主要做两件事：
1. 执行当前阶段的任务队列
2. 如果当前队列已经被清空，并且存在超时的定时器任务，事件循环会回到 tiemrs 阶段并执行对应的定时器任务

当poll阶段没有定时器任务需要执行时，会发生以下事情：
- 如果poll的队列不是空的，依次同步执行队列内的回调函数，直到队列被清空或者达到系统限制
- 如果poll的队列已经空了，会发生以下事情：
  - 如果已经设置了 setImmediate 回调，则退出 poll 阶段并进入 check 阶段
  - 如果没有 setImmediate 回调，poll阶段会持续轮询任务队列，如果有新添加的任务，会立即执行

#### check

这个阶段会在 poll 阶段结束之后，立刻执行所有的 setImmediate 事件。
如果 poll 阶段任务队列为空，进入idle，并且存在已有的 setImmediate 任务队列，事件循环会结束等待然后进入 check 环节。

#### close callbacks

如果socket突然关闭（比如 `socket.destroy()`），这个阶段会触发 `close` 事件。否则会在 `process.nextTick()` 中触发。

### `setImmediate()` vs `setTimeout()`

两者都是定时器任务，但是在 Node 中存在如下差别：
- `setImmediate` 用于在 poll 阶段执行结束后执行
- `setTimeout` 用于在指定的时间之后执行

两者在不同的阶段触发，表现效果也不一样。
- 以下代码如果是在 main script 中直接执行，两者的输出结果是不稳定的，因为进入事件循环也是需要成本的。
结合 check 阶段的描述，如果 Node 启动并开始执行 main script 时，准备阶段花费了大于 1ms 的时间，正常进入了循环，那么在 timer 阶段就会直接执行 setTimeout 回调；如果准备时间花费小于 1ms，那么就是 setImmediate 回调先执行了

```js
setTimeout(() => {
  console.log('timeout');
}, 0);

setImmediate(() => {
  console.log('immediate');
});
```

- 如果在 I/O 回调中执行上述代码， setImmediate 会先于 setTimeout 执行。
因为 I/O 回调执行 poll 阶段执行的，poll 阶段的任务队列执行完后进入了 check 阶段。

```js
const fs = require('fs');

fs.readFile(__filename, () => {
  setTimeout(() => {
    console.log('timeout');
  }, 0);
  setImmediate(() => {
    console.log('immediate');
  });
});
```

### `process.nextTick()`

实际上 `process.nextTick()` 并不是事件循环的一部分。无论事件循环进行到哪个环节，`nextTickQueue` 都会在当前操作执行完毕后执行。 Node 官方文档里对**当前操作**的定义如下：

> Here, an operation is defined as a transition from the underlying C/C++ handler, and handling the JavaScript that needs to be executed

不能简单的认为当前操作是指执行栈中的某一个宏任务。根据阮一峰的描述，在同一个阶段里，如果 phase 内的任务队列执行完毕，就会开始执行 `nextTickQueue`. 也就是说，同一阶段的同步代码执行完后，会立刻执行 `process.nextTick()`，事件循环可能会因此而阻塞。

根据语言规格，Promise对象的回调函数，会进入异步任务里面的"微任务"（microtask）队列。而微任务队列会追加在`nextTickQueue`队列的后面。

![](/assets/images/2019-05-07-19-09-05.png)

参考以下代码：
```js
setTimeout(() => {
  process.nextTick(() => {
    console.log('tick1');
    process.nextTick(() => {
      console.log('tick2');
      Promise.resolve().then(() => {
        console.log('tick3');
      })
    })
  })
  console.log(1)
}, 0);

setTimeout(() => {
  process.nextTick(() => {
    console.log('tick4');
    process.nextTick(() => {
      console.log('tick5');
      Promise.resolve().then(() => {
        console.log('tick6');
      })
    })
  })
  console.log(2)
}, 0);
```

在 Node v10.14.1 中的输出结果为：
```shell
1
2
tick1
tick4
tick2
tick5
tick3
tick6
```

在 Node 当中，同一阶段的代码执行完成后，才会开始执行 nextTickQueue 和 microTaskQueue，之后才是下一个 phase。

- 因为上述代码定义的两个 setTimeout 都会在 timers 阶段执行，所以最先输出 1 和 2。
- 紧接着会开始执行 nextTickQueue，输出了 tick1 和 tick4。
- 而在 tick1 和 tick4 中定义的 nextTick，会在下一次循环前（tick）执行，所以这时输出了tick2 和 tick5。
- 同理，因为 nextTickQueue 被清空，会开始执行 microTaskQueue，最后输出 tick3 和 tick6。


## 参考文章

- [jobs-and-job-queues](https://tc39.github.io/ecma262/#sec-jobs-and-job-queues)
- [阮一峰：event loop](http://www.ruanyifeng.com/blog/2014/10/event-loop.html)
- [how javascript works](http://www.zcfy.cc/article/how-javascript-works-event-loop-and-the-rise-of-async-programming-5-ways-to-better-coding-with-4506.html)
- [The Node.js Event Loop, Timers, and `process.nextTick()`](https://nodejs.org/de/docs/guides/event-loop-timers-and-nexttick/)
- [浏览器与Node的事件循环(Event Loop)有何区别?](https://blog.fundebug.com/2019/01/15/diffrences-of-browser-and-node-in-event-loop/)