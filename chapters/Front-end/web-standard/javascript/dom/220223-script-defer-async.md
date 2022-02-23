# script 标签的几个属性

## async

对于普通的 script 标签（`classic scripts`），async 遵循「异步加载、立即执行」的策略。

对于模块化的 script 标签（[`module scripts`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Modules)），async 会进行「异步加载」，将脚本和脚本依赖的内容，添加到 defer 队列中执行。

由于「异步加载」的特性，async 属性可以消除脚本在加载阶段对 DOM 解析的阻塞。

## defer

defer 属性默认只对带有 `src` 属性的普通 script 标签生效，对脚本资源进行「异步加载」后，会在 document 完成解析、`DOMContentLoaded` 事件触发之前执行。在带有 defer 属性的 script 执行完成之前，浏览器不会触发 `DOMContentLoaded` 事件。

带有 defer 属性的脚本，会按照声明顺序依次执行。

*对于模块化的脚本，defer 属性不会生效，因为 `module script` 默认会在 defer queue 中执行。*

## type

## integrity
