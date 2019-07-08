# 为什么读取某些属性，也会导致回流？

## TL;DR

1. 浏览器会尽可能高效的去执行重绘和回流
2. 代码中修改 DOM 的操作，会缓存到一个队列中，一定时间间隔或者指定修改次数后，统一执行
3. 如果此时查询了某些 DOM 属性，比如：
```
clientHeight clientLeft clientTop clientWidth 
offsetHeight offsetLeft offsetParent offsetTop offsetWidth 
scrollHeight scrollLeft scrollTop scrollWidth
```
**为了获取到最新的数据**，浏览器会将上述队列中的任务依次执行，保证队列被清空，从而导致了回流。

> All of these above are essentially requesting style information about a node, and any time you do it, the browser has to give you the most up-to-date value. In order to do so, it needs to apply all scheduled changes, flush the queue, bite the bullet and do the reflow.

## Reference
- [Rendering: repaint, reflow/relayout, restyle](http://www.phpied.com/rendering-repaint-reflowrelayout-restyle/)
- [What forces layout / reflow](https://gist.github.com/paulirish/5d52fb081b3570c81e3a)
- [ON LAYOUT & WEB PERFORMANCE](https://kellegous.com/j/2013/01/26/layout-performance/)
