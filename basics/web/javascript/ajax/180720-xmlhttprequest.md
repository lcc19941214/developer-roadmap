# XMLHttpRequest

> AJAX: Asynchronous JavaScript and XML  
>  [MDN](https://developer.mozilla.org/en-US/docs/Web/API/XMLHTTPRequest)
>
> [doris](https://github.com/lcc19941214/doris) 自己封装的一个简单的XMLHttpRequest库

## 创建对象

XMLHttpRequest 是 AJAX 的基础。

### XMLHttpRequest 对象

所有现代浏览器均支持 XMLHttpRequest 对象（IE5 和 IE6 使用 ActiveXObject）。 XMLHttpRequest 用于在后台与服务器交换数据。这意味着可以在不重新加载整个网页的情况下，对网页的某部分进行更新。

### 创建 XMLHttpRequest 对象

所有现代浏览器（IE7+、Firefox、Chrome、Safari 以及 Opera）均内建 XMLHttpRequest 对象。

#### 创建语法：

```javascript
variable = new XMLHttpRequest();
```

**老版本的 Internet Explorer （IE5 和 IE6）使用 ActiveX 对象：**

```javascript
variable = new ActiveXObject("Microsoft.XMLHTTP");
```

为了应对所有的现代浏览器，包括 IE5 和 IE6，请检查浏览器是否支持 XMLHttpRequest 对象。如果支持，则创建 XMLHttpRequest 对象。如果不支持，则创建 ActiveXObject ：

```javascript
var xmlhttp;
if (window.XMLHttpRequest) {
  // code for IE7+, Firefox, Chrome, Opera, Safari
  xmlhttp = new XMLHttpRequest();
} else {
  // code for IE6, IE5
  xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
}
```

### 发送请求

#### 方法

**open**

`open(method, url, async)`

* method: "GET", "POST", "PUT", "DELETE", ...
* url: "url"
* async: true \| false

**GET**

* GET可以得到缓存结果
* GET的长度是有限的（2048）
* GET不够保密
* 编码类型（ASIIC）

```javascript
XHR.open( "GET" , "URL" , true );
XHR.send();

XHR.open( "GET" , "URL?name=value&name=value" , true );
XHR.send();
```

**POST**

* 不会得到缓存结果
* 可以发送大量数据
* 足够安全
* 编码类型（无限制，可包括二进制流）

```javascript
XHR.open( "POST" , "URL" , true );
XHR.send();

XHR.oepn( "POST" , "URL" , true );
XHR.setRequestHeader(header , value);
XHR.send("name&value"); // request body
```

**async**

* 异步时，不用等待服务器返回信息即可继续执行其他操作。需要设置服务器返回的信息为对应的状态时，应当执行的操作（`onreadystatechange`）

```javascript
xmlhttp.onreadystatechange = function() {
  if (xmlhttp.readyState==4 && xmlhttp.status==200) {
    document.getElementById("myDiv").innerHTML = xmlhttp.responseText;
  }
}
```

* 同步时，需要等待服务器返回信息才能继续执行后面的脚本。**设置为同步时**，主线程会顺序执行xhr对象后面的语句，**无法侦听readystatechange事件**。

**send**

`send(body)`

**body**

* A Document, in which case it is serialized before being sent.
* A BodyInit, which as per the Fetch spec can be a Blob, BufferSource, FormData, URLSearchParams, ReadableStream, or USVString object.

**note**

* 使用`POST`时，需要设置`Content-Type`为`application/x-www-form-urlencoded`
* 如果send方法传入的不是字符串，则不需要设置header的`Content-Type`

### Properties

* responseText  获得字符串形式的响应数据
* responseXML   获得字符串形式的响应数据
* getResponseHeader  获取响应头，没有或不存在则返回null
* getAllResponseHeaders
* readystate
  * `onreadystatechange` 每次readystate发生改变时，即触发该事件
  * 取值
    * 0: 请求初始化，还没调用open\(\)方法
    * 1: 服务器建立连接，还没调用send\(\)方法
    * 2: 请求已经接受，已经调用send\(\)方法,响应头和响应状态已经返回
    * 3: 请求处理中，下载中,已经得到部分响应实体
    * 4: 请求完成，响应就绪
* status
* statusText

### XHR 2.0

* 支持设置`timeout`

  \`\`\`js

  xhr.timeout = 2000; // time in milliseconds

xhr.onload = function \(\) { // Request finished. Do processing here. };

xhr.ontimeout = function \(e\) { // XMLHttpRequest timed out. Do something here. };

```text
- 支持使用`FormData`

- 支持CORS，需要后端配合。
    - `withCredentials`
```js
xhr.withCredentials = true;
```

* 可配置`responseType`  - an enumerated value that returns the type of response
  * text
  * json
  * arrayBuffer
  * document

