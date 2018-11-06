# 隐式转换

> ref: [JS的隐式转换 从 \[\] ==false 说起](https://juejin.im/post/5a220ed85188254cc067adc0)

## ToPrimitive

**函数签名：**

ToPrimitive\(input, PreferredType?\) // PreferredType: Number 或者 String

**流程如下：**

* input为原始值，直接返回；
* 不是原始值，调用该对象的valueOf\(\)方法，如果结果是原始值，返回原始值；
* 调用valueOf\(\)不是原始值，调用此对象的toString\(\)方法，如果结果为原始值，返回原始值；
* 如果返回的不是原始值，抛出异常TypeError。

其中PreferredType控制线调取valueOf\(\)还是toString\(\)。

ps: Date类型按照String去调用。

如果对prototype上的`valueOf`或者`toString`方法进行了修改，则隐式转换会有不一样的结果。可以通过以下代码看下上述流程是如何进行的。

```javascript
[] == false; // true

Array.prototype.valueOf = () => true;
[].valueOf(); // true;
[] == false; // false

Array.prototype.toString = Object.prototype.toString;
[].toString(); // [object Array]
[] == false; // false
```

## 数学运算

* 计算两个操作数的原始值： prima = ToPrimitive\(a\), prima = ToPrimitive\(b\)；
* 如果原始值有String,全部转换为String，返回String相加后的结果；
* 如果原始值没有String,全部转换为Number， 返回Number相加后的结果；

## 比较运算

`==` 中的隐式转换：

* x y都为Null或undefined,return true;
* x或y为NaN, return false;
* 如果x和y为String，Number，Boolean并且类型不一致，都转为Number再进行比较
* 如果存在Object，先转换为原始值，再进行比较

## `valueOf`\([MDN](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/Object/valueOf)\)

![](../../../../.gitbook/assets/2018-07-20-16-08-58.png)

## Relational and Equality Operators

![](../../../../.gitbook/assets/2018-07-20-16-09-08.png)

## What goes through If statement

![](../../../../.gitbook/assets/2018-07-20-16-09-16.png)

