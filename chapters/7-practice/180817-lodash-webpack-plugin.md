# lodash按需加载注意事项

> 2018年8月17日 14:40:47

大家引用lodash的时候，如果想要按需加载，可以考虑使用webpack lodash plugin
具体使用可以看文档，[lodash-webpack-plugin](https://github.com/lodash/lodash-webpack-plugin)

```javascript
// 使用前：
const isElement = require('lodash/isElement');
const debounce = require('lodash/debounce');

// 使用后:
import { isElement, debounce } from 'lodash'
```

使用少量lodash代码的，用按需加载可以节省近1MB大小。

这里说一个坑，最近压缩代码时发现的。
按需加载会只加载引用的函数，但是有的函数内部会调用其他方法。最常见的是，某些支持迭代器的方法，只是使用shorthand写法非显示调用。按需加载不会加载shorthand的函数。

![](/assets/images/2018-08-17-14-42-07.png)

类似上面这种，按需加载引用`groupBy`时，不会默认加载`property`方法

配置时可以考虑用以下配置。具体可以参考文档设置配置。

![](/assets/images/2018-08-17-14-43-13.png)