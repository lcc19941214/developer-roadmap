# HTTPS 握手过程

## Client Hello

* `client.random`
* `SSL/TLS version`
* `encrypt methods(suits)` 加密方式 key exchange

其他：

* `压缩方式`

## Server Hello

* `server.random`
* `SSL/TLS version` 确认支持的安全协议，如果客户端与服务端不一致则断开连接
* `encrypt methods(suits)` 加密方式 key exchange
* `certificate` CA证书
  * 包含服务器信息
  * signature
  * `public-key`
* `server hello done`

其他：

* `ClientCertificateRequest` 如果有要求，则还会请求客户端的证书

## Client Response

* `CA校验` 对服务端证书结构进行链式查找，与浏览器内置的CA证书比对。
  * 通过内置的CA公钥解密signature并判断
  * 证书的有效期
  * 证书所在的域名
* `pre-master secret` \(浏览器生成一个random，然后用证书中的`public-key`进行加密\)
  * 根据`client.random`，`server.random`，`pre-master secret` 客户端会生成一个`master secret`用于之后的通信。
* `cipher change spec` 更改加密协议，告诉服务端客户端将使用对称加密进行通信

其他：

* `SendClientCertificate` 如果服务端要求发送客户端证书，则此时需要返回一个客户端证书

## Server Response

* 使用私钥解密客户端的`pre-master secret`，根据之前握手获得的所有random，生成`master secret`
* `cipher change spec`
* finished

其他：

* `客户端证书校验` （如果有）

**注：** 并没有传输`master—key`这一步，客户端和服务端利用互相传输的random，结合商定好的加密方法，可以得出相同的对称加密秘钥。

## Referrence

1. [看完你就知道什么是 HTTPS 了](https://juejin.im/post/592d23630ce46300579882b4)

基本概念介绍。

**关键字：** 对称加密，非对称加密，CA证书，签名

1. [The First Few Milliseconds of an HTTPS Connection](http://www.moserware.com/2009/06/first-few-milliseconds-of-https.html)

数据通信的介绍。

**关键字：** 过程解析，字节，加密算法

1. [RFC-2818](https://tools.ietf.org/html/rfc2818)

规范。

1. [SSL/TLS协议运行机制的概述](http://www.ruanyifeng.com/blog/2014/02/ssl_tls.html)

阮一峰的科普。

**关键字：** master-secret的生成时client和server各生成一份。

