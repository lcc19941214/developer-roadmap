# Grid 布局简易笔记

2018 年 11 月 6 日 15:03:19

## 属性介绍

### Layout

#### Template

* `grid-template` grid-template-\* 属性的缩写
* `grid-template-rows` 设置行高
* `grid-template-columns` 设置列宽
* `grid-template-areas` 设置具名栅格
* `repeat` 栅格可配合 repeat 实现快速布局

[click here to see example](http://jsfiddle.net/cool_conan/j7pyfbv0/3/embedded/result,html,css/)

#### Item

* `grid-area` 栅格对应的区域的名称；也支持书写边界的名称，如 `1 / 1 / 2 / 2`，即横、纵方向上的第一个栅格
* `grid-row` 栅格在同一行上所占据的区域
* `grid-row-start` 区域在行的起始位置
* `grid-row-end` 区域在行的结束位置
* `grid-column` 栅格在同一列上所占据的区域
* `grid-column-start` 区域在列的起始位置
* `grid-column-end` 区域在列的结束位置
* `span` span 关键字，如果起始和结束位置是具名的，则没有效果；如果 span 后面紧跟一个 number 类型的值，则表示需要横跨几个区域

[click here to see example](http://jsfiddle.net/cool_conan/jk45b9tx/embedded/result,html,css/)

#### Gap

* `grid-gap` 间隙的缩写
* `grid-row-gap` 水平方向上的间隙
* `grid-column-gap`  垂直方向上的间隙

[click here to see example](http://jsfiddle.net/cool_conan/xszy8g1h/19/embedded/result,html,css/)

#### 隐式栅格

对溢出栅格范围的区域进行控制

* `grid-auto-row`
* `grid-auto-column`

### Align

#### Template

* `justify-content` 仅当栅格所占宽度小于容器宽度时生效。设置栅格区域在水平上的的对齐方式
* `align-content` 仅当栅格所占高度小于容器高度时生效。设置栅格区域在垂直上的的对齐方式
* `justify-items` 设置栅格区域内，每个格子水平上的对齐方式，默认是 `stretch` 填充满整个格子
* `align-items` 设置栅格区域内，每个格子垂直上的对齐方式，默认是 `stretch` 填充满整个格子
* `place-items` \*-items 属性的缩写，eg: `place-items: <align-items> <justify-items>`

#### Item

* `justify-self` 设置栅格区域内，当前格子水平上的对齐方式
* `align-self` 设置栅格区域内，当前格子垂直上的对齐方式
* `place-self` \*-self 属性的缩写，eg: `place-self: <align-self> <justify-self>`

[click here to see example](http://jsfiddle.net/cool_conan/w8znp1gL/24/embedded/result,html,js,css)

