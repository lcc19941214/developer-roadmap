# TS 中 enum 的编译结果

## 声明 enum
```typescript
enum Family {
  Ann,
  Bob,
  Cindy = 3,
  Douglas,
  Emma
}

const Cindy = Family.Cindy;
```

## 编译结果
```javascript
var Family;
(function (Family) {
    Family[Family["Ann"] = 0] = "Ann";
    Family[Family["Bob"] = 1] = "Bob";
    Family[Family["Cindy"] = 3] = "Cindy";
    Family[Family["Douglas"] = 4] = "Douglas";
    Family[Family["Emma"] = 5] = "Emma";
})(Family || (Family = {}));
var Cindy = Family.Cindy;
```

编译后的对象，可以实现“双向访问”。

```typescript
enum Tristate {
  False,
  True,
  Unknown
}

console.log(Tristate[0]); // 'False'
console.log(Tristate['False']); // 0
console.log(Tristate[Tristate.False]); // 'False' because `Tristate.False == 0`
```


## 参考
[深入理解 Typescript](https://jkchao.github.io/typescript-book-chinese/typings/enums.html)