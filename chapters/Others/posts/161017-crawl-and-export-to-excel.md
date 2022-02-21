# 使用 node 爬取数据并导出到 excel

之前使用 request + cheerio 简单的爬过虾米音乐的一些排行榜，后来一直想用node导出excel文件来方便统计，于是使用node-xlsx尝试了一下。

## 1. 为什么要导出为excel

使用node的各类处理请求的库，甚至是直接用jsonp, AJAX直接在控制台简单的请求，都能获取到文档内容或者是api返回的结果。但是由于有时候这些爬取操作只是简单的一次性操作，数据并不会存储到本地的数据库里，但是有需要有一定的数据管理系统来对爬取的数据进行处理，所以选择了excel。

## 2. 依赖

这里用到的依赖主要有：

* [request](https://github.com/request/request) 用于服务端发起请求
* [cheerio](https://github.com/cheeriojs/cheerio) 服务器端的轻量化jquery，将请求到的文档内容转化为可以操作的DOM对象，对DOM进行节点操作，api与jquery相似
* [node-xlsx](https://github.com/mgcrea/node-xlsx) node-xlsx是对 [sheetJS](https://github.com/SheetJS/js-xlsx) 的简单封装，可以读取和导出xlsx文件

## 3. 具体实现

这里主要用一个爬取荆楚网发帖数据的例子进行演示。

主要的思路是，首先登陆荆楚网网站（由于登陆需要输入验证码，而且爬取数据单一，这里直接人工登陆从控制台获取到cookie），这是请求头中的cookie，爬取指定页面内容后存储到本地，利用node-xlsx转存为excel文件。

### 文件结构

```bash
├── config.js   # 配置数据分隔符、存储文件名
├── index.js    # 发起请求，处理文档，存储内容
└── save.js     # 转存文本内容到excel
```

### 配置项

```javascript
module.exports = {
  // 如果将分隔符定义为空格，有可能错误的截取爬取到的数据
  // 且分隔符要避免使用正则表达式中需要转义的字符
  separator: ';;;',
  rawDataFileName: 'output/data.txt',
  saveFileName: 'output/out.xlsx'
};
```

### 爬取请求

```javascript
// 引入依赖
var request = require('request');
var cheerio = require('cheerio');
var fs = require('fs');
var path = require('path');
var config = require('./config.js');
// 请求配置项
const pageSize = 10;  // 爬取多个列表页，一共爬取10页
let counter = 0;  // 成功爬取的数据计数
let options = {
  method: 'GET',
  url: 'http://bbs.cnhubei.com/forum.php',  // 主机地址
  qs: { mod: 'guide', view: 'my', type: 'thread' },  // 请求字符串
  headers: {
     'cache-control': 'no-cache',
     cookie: '*******'
   },
};
// 发起请求
function fetchData(cb, page) {
  let finalOptions = Object.assign({}, options);
  Object.assign(finalOptions.qs, { page });
  request(options, (err, res, body) => {
    if (err) throw err;

    // 请求到文档内容后开始提取内容
    extractDocument(body, cb);
  });
}
// 内容抽取
function extractDocument(body, cb) {
  // 调用cheerio.load方法载入文档，转化为可操作的DOM文档
  const $ = cheerio.load(body);
  // 根据文档结构进行节点查询
  $('#threadlist .bm_c table tbody').each(function (i, el) {
    let title = $(this).find('tr .common a').text();
    let pageView = $(this).find('tr .num em').text();
    let createTime = $(this).find('tr .by').last().find('em a').text();
    if (title && pageView && createTime) {
      counter++;
      cb({ title, pageView, createTime }, counter);
    }
  });
}
// 将数据保存到本地
function writeFile(data, index) {
  // 拼接爬取到的数据
  data = Object.keys(data).map(key => data[key]).join(config.separator) + '\n';
  let fileRoute = path.resolve(__dirname, config.rawDataFileName);

  // 使用node将数据储存到本地，使用appendFile逐条追加
  fs.appendFile(fileRoute, data, 'utf-8', (err) => {
    console.log(`已读取：${index}`);
  });
}
// start
for (let page = 1; page <= pageSize; page++) {
  fetchData(writeFile, page);
}
```

### 转存为excel

由于`sheetJS/js-xlsx`的写入操作比较繁琐，这里采用`node-xlsx`。

使用node-xlsx写入xlsx文件的方式为

调用build方法并传入一个对象options，设置options的data属性为数组Sheet 数组Sheet的每项为一个数组Row,对应excel表格的每一行 数组Row的每一项对应每一个table cell的内容。 node-xlsx.build()最终会返回一个buffer对象，用于写入到最终的xlsx文件。

```javascript
var path = require('path');
var fs = require('fs');
var xlsx = require('node-xlsx');
var config = require('./config.js');
let fileRoute = path.resolve(__dirname, config.rawDataFileName);
let fileName = path.resolve(__dirname, config.saveFileName);
// 定义导出配置项
let exportData = {
  name: '荆楚网阅读数据',
  data: [
    ['标题', '阅读数', '发布时间']  // 第一行数据，分别对应A1 B1 C1的table cell的内容，即单元格标题
  ]
};
// 转存文本
function saveFile(data) {
  // 剔除无效数据
  data = data.split(/\n/).filter(r => !!r);
  // 将文本转换为符合要求的数组对象
  var seperatorPtn = new RegExp(config.separator, 'g');
  data = data.map(r => {
    var rst = r.split(seperatorPtn);
    rst[1] = parseInt(rst[1]);  // 将每行数据的第1项转化为Number类型
    return rst;
  });
  exportData.data = exportData.data.concat(data);
  // 转存数据
  var buffer = xlsx.build([exportData]); // Returns a buffer
  fs.writeFile(fileName, buffer, (err) => {
    if (err) throw err;
    console.log('保存成功');
  });
}
// start
// 读取文本内容并开始转存
fs.readFile(fileRoute, 'utf-8', (err, data) => {
  if (err) throw err;
  saveFile(data);
});
```

## 4. 改进

之后准备该用stream的方式在内存中保存爬取到的数据，爬取结束后然后直接转存为excel。 但是这样也有一个问题是，爬取数据过多会占用大量内存。

所以还是用写入数据库吧……
