# this 关键字

`this`并不指向一个函数的词法作用域，而是在被调用时，由调用方式决定的一种绑定。

## 绑定规则

* 确定绑定规则的一个很重要的点，就是要确定函数的调用栈。但是这不是`this`的决定性因素。

### 默认绑定

适用条件：在函数调用时，直接调用，没有其他任何修饰。

this指向：

* 严格模式下，指向`undefined`
* 非严格模式，指向全局对象\(`window`或者是`global`\)

_指函数体内部有没有处于严格模式或非严格模式_

```javascript
function foo() {
    console.log(this);
}

foo(); // window

function bar() {
    "use strict";
    console.log(this);
}

bar(); // undefined
```

### 隐式绑定

适用条件：函数调用时存在一个上下文对象，即函数被一个对象包含或拥有。

this指向：指向绑定的对象

```javascript
var a = 1;

var o = {
    a: 2,
    foo() {
        console.log(this.a);
    }
};

var bar = o.foo;

o.foo(); // 2

bar(); // 1
```

**note:** 1. 这种隐式绑定只会在对象属性引用链的最后一层起作用。 2. \[隐式丢失\]隐式绑定的函数，如果是直接调用时，会采用默认绑定。比如作为参数传递给另一个函数。

```javascript
var a = 1;

var o = {
    a: 2,
    foo() {
        console.log(this.a);
    }
};

function bar(fn) {
    fn();
}

bar(o.foo); // 1
```

### 显式绑定

适用条件：

* `call`
* `apply`
* `bind`
* `forEach`, `map`等原生方法，支持传入第二个参数，用于改变第一个函数的context

this指向：指定的上下文

### new 绑定

适用条件：通过`new`操作符进行构造函数调用时

this指向：通过`new`操作符调用的函数，创建的新对象上

## 特殊case

### 被忽略的this

如手动在显式绑定、硬绑定，传入context时传入`undefined`或`null`，此时等同于默认绑定

### 间接引用

注意函数的间接引用，比如赋值时的返回值。

```javascript
var a = {
    foo() {
        console.log(this.bar)
    },
    bar: 1
};

var b = {
    bar: 2
};

(b.foo = a.foo)() // undefined
```

### 箭头函数

箭头函数的this指向词法作用域中被调用的this。并不是直接就跟词法作用域的this绑定了，具体还要考虑外层函数的调用规则。

```javascript
function Bar() {
  this.a = 1;
  var obj = {
    func: () => {
      console.log(this.a);
    }
  };

  this.obj = obj;

  obj.func();
}

var bar = new Bar(); // 1
bar.obj.func(); // 1

function Foo() {
  this.a = 2;
  this.bar = new Bar();
  this.func = this.bar.obj.func;
}

var foo = new Foo(); // 1
foo.bar.obj.func(); // 1
foo.func(); // 1
```

