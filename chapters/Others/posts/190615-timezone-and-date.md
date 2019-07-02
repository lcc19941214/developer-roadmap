# 时区与JS中的Date对象

## 时区

### 什么是时区？

![时区划分](/assets/images/2019-07-02-11-14-46.png)

1884年在华盛顿召开的一次国际经度会议（又称国际子午线会议）上，规定将全球划分为24个时区（东、西各12个时区）。规定英国（[格林尼治天文台](https://baike.baidu.com/item/格林尼治天文台)旧址）为[中时区](https://baike.baidu.com/item/中时区)（零时区）、东1-12区，西1-12区。每个时区横跨经度15度，时间正好是1小时。

### 时区的分类

#### 理论时区

上述时区定义其实是**理论时区**。理论时区的时间采用其中央经线（或标准经线）的地方时。比如东八区的经度范围是112.5°E~127.5°E，中央经线为120°E。

所以每差一个时区，区时相差一个小时，相差多少个时区，就相差多少个小时。东边的时区时间比西边的时区时间早。

#### 法定时区

复原辽阔的国家，横跨多个时区，常常以国家内部行政分界线为时区界线。这就是**实际时区**，即**法定时区**。

比如中国的地理区划，西至75°E，东至135°E，横跨多个时区，然而实际上我们国家法定时区为东八区标准时。居住在我国西部，如新疆的同学应该深有感触，北京时间早上六点时，当地时间可能还处于凌晨3点，天空一片漆黑。

而美国同样横跨多个时区，但是美国本土使用了西部时间（-8）、山地时间（-7）、中部时间（-6）、东部时间（-5），共四个时区（阿拉斯加和夏威夷群岛分别是-8和-10）。所以简单的说美国时区就是-8区，这是不正确的。

##### 国际日期变更线

东12区和西12区的中央经线其实都是180°经线，为了避免同一个时区即存在新的一天，又存在旧的一天，人为规定180°以西至0点所在经线，为新的一天，以东为旧的一天。

但是太平洋上存在一些国家，行政区划横跨180°经线，为了方便管理，国际日期变更线其实不是一条直线。

![国际日期变更线](/assets/images/2019-07-02-11-16-01.png)

前面提到，**理论时区**只包括西12区~东12区24个时区。但是太平洋国家萨摩亚在2011年12月29日完结时把标准时间从国际日期变更线以东调整到国际日期变更线以西，即从时区UTC-11改为UTC+13（夏时制由UTC-10改为UTC+14）。因此，现行国际时区标准中，存在一个“东13区”。

```js
// 太平洋阿皮亚地区的时区

moment().tz('Pacific/Apia').format('Z')
// "+13:00"
```


## 常见的时间标准

一般说到时区，就会提到这几个名词，`UTC`，`GMT`，`DST`，`CST`，那这几个名词分别代表什么含义呢？

### GMT

GMT 即 **Greenwich Mean Time**， 代表**格林威治标准时间**。

前文提到，1884年国际经度会议决定选择格林威治的子午线，作为划分地球东西两半球的经度零度。而格林威治皇家天文台早在十七世纪，就已经是海上霸主大英帝国的扩张而进行天体观测。

对全球而言，这里所设定的时间是世界时间参考点，全球都以格林威治的时间作为标准来设定时间。

```js
new Date()
// Sat Jun 15 2019 17:55:58 GMT+0800 (中国标准时间)

new Date('2020-10-10 00:08:19')
// Sat Oct 10 2020 00:08:19 GMT+0800 (中国标准时间)
```

常说的 时间戳，timestamp 就是指格林威治时间1970年01月01日00时00分00秒(北京时间1970年01月01日08时00分00秒)起至现在的总秒数，js 中出输出的 timestamp 是到毫秒级的。

```js
new Date('1970-01-01').getTime();
// 0

new Date('1969-12-31').getTime();
// -86400000
```



### UTC

UTC 即 **Coordinated Universal Time**，代表**世界协调时间**或**协调世界时**。

UTC是经过平均太阳时(以格林威治时间GMT为准)、地轴运动修正后的新时标以及以“秒”为单位的国际原子时所综合精算而成的时间，计算过程相当严谨精密。协调世界时是最接近GMT的几个替代时间系统之一。

普遍认为，UTC时间被认为能与GMT时间互换，但GMT时间已不再被科学界所确定。

一般来说，当我们提到 **UTC 时间** 而不带任何别的修饰时，常指 UTC 0点。

**UTC 和 GMT 唯一的差别，UTC 有闰秒，GMT 没有。**



### DST

DST 即 **Daylight Saving Time**， 代表**日光节约时间**。这是一个完全由各国政府主导的行政行为，即与 GMT、UTC 这两种基于地理的时间标准而言，**DST 不是一种参考经线坐标的标准。**

所谓日光节约时间，是指在夏天太阳升起的比较早时，将时钟拨快一小时，以提早日光的使用，削减灯光照明和耗电开支。在英国则称为夏令时间(Summer Time)。

全球仍有部分国家在实施夏令时。**值得注意的是，我国在1986年至1991年期间也使用了夏令时**，可以参考[百度百科-夏令时](https://baike.baidu.com/item/%E5%A4%8F%E4%BB%A4%E6%97%B6)中对中国政策部分的描述。

简而言之，我们国家在上述时期的夏天，**打印出来的时区是+9区**。

```js
new Date('1985-07-01 00:00:00')
// Mon Jul 01 1985 00:00:00 GMT+0800 (中国标准时间)

new Date('1986-07-01 00:00:00')
// Tue Jul 01 1986 00:00:00 GMT+0900 (中国夏令时间)

new Date('1988-07-01 00:00:00')
// Fri Jul 01 1988 00:00:00 GMT+0900 (中国夏令时间)

new Date('1990-07-01 00:00:00')
// Sun Jul 01 1990 00:00:00 GMT+0900 (中国夏令时间)

new Date('1991-07-01 00:00:00')
// Mon Jul 01 1991 00:00:00 GMT+0900 (中国夏令时间)

new Date('1992-07-01 00:00:00')
// Wed Jul 01 1992 00:00:00 GMT+0800 (中国标准时间)
```



### 各国标准

每个国家/地区使用的时区标准，都用不同的简称，可参考 [moment.timezone](https://momentjs.com/timezone/).

想要获取各国、各地区的时区标准，可以使用`moment.tz`以及国际时区标准中的地点名称：

```js
moment().tz('Asia/Shanghai').format('z') // 'CST'
moment().tz('Asia/Tokyo').format('z') // 'JST'
moment().tz('America/Los_Angeles').format('z') // 'PDT' - Pacific Daylight Time
```



不同的浏览器显示效果相同，Chrome会显示 GMT，以及一个已经翻译好的地方时区标准：

```js
new Date();
// Sat Jun 15 2019 20:36:10 GMT+0800 (中国标准时间)
```

而 Safari 则很贴心的没有做翻译：

```js
new Date();
// Thu Oct 10 2019 00:00:00 GMT+0800 (CST)
```

要想省心，还是用 moment 吧。



下面列举几个常见的国际标准：

![](/assets/images/2019-06-24-20-19-44.png)



#### BST

与夏令时相同，即 **British Summer Time**.



#### CST

美国中部时间：Central Standard Time (USA) UT-6:00

澳大利亚中部时间：Central Standard Time (Australia) UT+9:30

中国标准时间：China Standard Time UT+8:00

古巴标准时间：Cuba Standard Time UT-4:00



## JavaScript 中的时区

### 如何获取时区？

如果想在js中获取一个日期的时区，可以直接使用 [Date.prototype.getTimezoneOffset()](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date/getTimezoneOffset).

```js
var dateLocal = new Date();
var date1 = new Date('August 19, 1975 23:15:30 GMT+07:00');
var date2 = new Date('August 19, 1975 23:15:30 GMT-02:00');

console.log(dateLocal.getTimezoneOffset());
console.log(date1.getTimezoneOffset());
console.log(date2.getTimezoneOffset());

// -480
// -480
// -480
```

`getTimezoneOffset`返回的结果，是当前地方时和UTC时间的差值，用分钟表示。上述 `dateLocal` 可以理解为，`( 0时区 - 本地时区(+8) ) * 60min = -480`.

所以想获得标准的时区，例如 +8 或 -8，需要进行以下处理：

```js
// 使用原生 js
var date = new Date().getTimezoneOffset();
var timezone = -date;

console.log(timezone)； // 480
console.log(timezone / 60)； // 8

// 使用 moment (moment是基于local - utc得到的)
var date = moment();
var timezone = date.utcOffset();

console.log(timezone); // 480
console.log(timezone / 60); // 8
```

看到输出结果，大家可能会问为什么 date1 和 date2 的输出结果不是 +7 和 -2？

这个问题后面会为大家解答。



### 如何设置时区？

Date 对象提供了给实例 set 日期、时间的方法，但是并不支持修改实例的时区。

详情可以参考 [Date.prototype 提供的方法](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date)。



### 补充1：如何实例化一个日期对象？

| Date Creation                                                | Output                                              |
| ------------------------------------------------------------ | --------------------------------------------------- |
| `new Date()`                                                 | Current date and time                               |
| `new Date(timestamp)`                                        | Creates date based on milliseconds since Epoch time |
| `new Date(date string)`                                      | Creates date based on date string                   |
| `new Date(year, month, day, hours, minutes, seconds, milliseconds)` | Creates date based on specified date and time       |

datestring的类型很多，可以参考[MDN的汇总](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date/parse)

ISO标准类型有：

- "2011-10-10" (date-only form)

- "2011-10-10T14:48:00" (date-time form)

- "2011-10-10T14:48:00.000+09:00" (date-time form with milliseconds and time zone)

- "2019-01-01T00:00:00.000Z"(specifying UTC timezone via the ISO date specification，Z is the same with +00:00)



### 补充2：如何获取js中的日期和时间？


| Date/Time          | Method              | Range                         | Example              |
| ------------------ | ------------------- | ----------------------------- | -------------------- |
| Year               | `getFullYear()`     | YYYY                          | 1970                 |
| Month              | `getMonth()`        | 0-11                          | 0 = January          |
| Day (of the month) | `getDate()`         | 1-31                          | 1 = 1st of the month |
| Day (of the week)  | `getDay()`          | 0-6                           | 0 = Sunday           |
| Hour               | `getHours()`        | 0-23                          | 0 = midnight         |
| Minute             | `getMinutes()`      | 0-59                          |                      |
| Second             | `getSeconds()`      | 0-59                          |                      |
| Millisecond        | `getMilliseconds()` | 0-999                         |                      |
| Timestamp          | `getTime()`         | Milliseconds since Epoch time |                      |

  

## 常见问题

### 1. 实例化 Date 对象时传入了时区，为什么获取的时区是本地时区？

```js
var date1 = new Date('August 19, 1975 23:15:30 GMT+07:00');
var date2 = new Date('August 19, 1975 23:15:30 GMT-02:00');

console.log(date1.getTimezoneOffset());
console.log(date2.getTimezoneOffset());

// -480
// -480
```

需要注意，不管你如何实例化一个 Date 对象，js在本地存储时，都会将它转换成本地时区。js 不会帮你存储实例化该日期时的时区信息。



   > It's important to keep in mind that the date and time is stored in the local time zone, and that the basic methods to fetch the date and time or its components all work in the local time zone as well.



```js
new Date('June 15, 2019 23:15:30 GMT+10:00')；
// 东10区的时间，实例化成功后，日期被转换成了本地时区

// Sat Jun 15 2019 21:15:30 GMT+0800 (中国标准时间)
```



那怎样才能获得一个携带了指定时区的日期对象呢？答案是，**JS原生日期对象并不支持**。

无法想象RD同学跟PM满脸无辜的解释"JS办不到"之后，被PM追着砍的场景，因为还好[moment](https://momentjs.com/timezone/)支持了。

如下图所示，直接声明一个moment实例，并不会携带任何`offset`信息，因为这是一个 UTC 时间，只不过基于 js Date 的特性，直接`toDate`打印的结果会基于本地时区给你进行展示。

通过调用 `tz()` 方法，我们给一个moment实例指定了时区，这个时区是东京所在的 +9 区。这时能看到，这个moment实例拥有了`offset`属性。继续调用`format('Z')`，可以得到其时区为"+09:00".

![](/assets/images/2019-06-24-20-20-10.png)



### 2. 如何处理 YYYY-MM-DD 这样的日期字符串？

在js中，很多时候需要把日期字符串转换为一个 Date 对象。如果得到的日期字符串有时间还好办，如果就是一个`"2019-10-10"`这样的字符串呢？

大部分人可能什么都没想，直接就调用了 `new Date(datestring)`。可是事情没有想象中那么简单。让我们来对比一下：

```js
var date1 = new Date('2019-10-10')
// Thu Oct 10 2019 08:00:00 GMT+0800 (中国标准时间)

var date2 = new Date('2019-10-10 00:00:00')
// Thu Oct 10 2019 00:00:00 GMT+0800 (中国标准时间)
```

可以发现，直接输入日期，和输入日期+时间，得到的结果差了整整8个小时！

MDN中给出了详细的解释：

> parsing of date strings with the `Date` constructor (and `Date.parse`, they are equivalent) is strongly discouraged due to browser differences and inconsistencies. Support for RFC 2822 format strings is by convention only. Support for ISO 8601 formats differs in that date-only strings (e.g. "1970-01-01") are treated as UTC, not local.

简单翻译一下，直接给new Date传入'YYYY-MM-DD'这样的字符串，得到的是一个基于UTC时间的Date实例。前文有说过，UTC时间即是0时区的标准时间。

所以上面的代码例子中，`date1` 实例化时，内部先获取到了一个`2019-10-10 00:00:00 GMT+00:00`这样的时间，再被转为本地时区，就多了8个小时。

而`date2`实例化时，`2019-10-10 00:00:00`被当做`GMT +08:00`的时区，所以得到的时间，就是0点。

这两种方式没有对与错之分，但是使用的时候需要十分注意。个人不建议使用`new Date(YYYY-MM-DD)`这样的方式。

说了一堆理论，到底哪些场景要注意问题呢？Show you the code:

```js
// code is runningg on GMT +08:00
const d = new Date('2019-10-10');
const date = d.getDate();

// 10
// Looks good!


// code is runningg on GMT -10:00
const d = new Date('2019-10-10');
const date = d.getDate();

// 9
// Amazing?!
```

总结上面的代码：在小于0时区的地方，直接用 new Date('YYYY-MM-DD') 这样的方式实例化日期并且获取日期，永远会少一天。但是使用 new Date('YYYY-MM-DD 00:00:00') 就不会。

有没有一劳永逸的办法？有，moment。

```js
moment('2019-10-10').toDate()
// Thu Oct 10 2019 00:00:00 GMT+0800 (中国标准时间)

moment('2019-10-10 00:00:00').toDate()
// Thu Oct 10 2019 00:00:00 GMT+0800 (中国标准时间)
```



### 3. 为什么 safari 调用 new Date 老报错？

下面这段代码确实会报错：

```js
new Date('2019-10-10 00:00:00')
// Invalid Date
```

老司机们可能知道safari一直以来都有上述bug，为了解决这个问题，可以使用以下代码：

```js
new Date('2019/10/10 00:00:00')
// Thu Oct 10 2019 00:00:00 GMT+0800 (CST)
```

有没有一劳永逸的办法？有，moment。


### 4. 有哪些好用的处理时区与日期的工具库？

- [Moment.js](https://momentjs.com/) - Parse, validate, manipulate, and display dates and times in JavaScript

- [Moment Timezone](https://momentjs.com/timezone/) - Parse and display dates in any timezone

- [DAY.JS](https://github.com/iamkun/dayjs) - A minimalist JavaScript library for modern browsers with a largely Moment.js-compatible API

- [date-fns](https://date-fns.org/) - Modern JavaScript date utility library

- [查看更多](https://blog.bitsrc.io/9-javascript-date-time-libraries-for-2018-12d82f37872d)




## 参考

- [MDN-Date](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date)

- [Timezone](https://en.wikipedia.org/wiki/Time_zone#Nautical_time_zones)

- [antd 1.x datepicker 时区问题](https://coolconan.gitbook.io/roadmap/others/posts/180413-datepicker-timezone-offset)

- [Understanding Date and Time in JavaScript](https://www.digitalocean.com/community/tutorials/understanding-date-and-time-in-javascript)

- [GMT vs UTC](https://stackoverflow.com/questions/1612148/gmt-vs-utc-dates)

- [时区大全](http://www.timeofdate.com/)

- [为什么要用毫秒值的形式存储日期时间？](https://www.v2ex.com/t/550865#r_7117086)
  