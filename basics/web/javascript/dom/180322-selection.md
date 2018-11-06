# selection api

## 常用API

selection

* window.getSelection
* selection.getRangeAt
* selection.removeAllRanges
* selection.addRange

range

* document.createRange
* range.getBoundingClientRect
* range.selectNode
* range.selectNodeContents
* range.setStart
* range.setEnd

## 设置光标

[javascript获取以及设置光标位置](http://www.dengzhr.com/js/1013)

## 一些实践

1. 获取range，获取选中的所有节点
2. 获取选中项的rect

   `range.getBoundingClientRect()`

3. 模拟selection

   ```javascript
   var s = window.getSelect();
   s.removeAllRanges();
   var r = document.createRange();
   r.selectNode(elem);
   s.addRange(r);
   ```

