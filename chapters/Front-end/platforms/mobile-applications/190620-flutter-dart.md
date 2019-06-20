# Flutter 在移动端和 Web 端的技术实现

## 基本层次
Flutter 在移动端和 Web 端都采用了从上到下的层次模型。

- Code 层。
  基于 Dart 编写代码

- 框架层，即 Flutter framework in Dart。
  这一层为 Code 层暴露组件、事件、以及各类接口。

- 渲染引擎。
  在移动端采用 C++ Flutter engine，在 Web 端采用 Flutter Web Engine。
  这一层的主要作用，是把框架层产生的组件、画面绘制到运行环境中。

- 代码编译。
  严格来说这里不是一个层，只是一个步骤。
  以浏览器为例，这一步是使用 Dart2js compiler，把 Dart 编译为 JavaScript。
  同时也会把组件、画面”翻译“为 html, css 和 canvas。

- 运行环境。
  包含iOS, Android, Browser.

- 底层硬件。
  GPU, ARM, x86 chips, etc.

### 移动端

![](/assets/images/2019-06-20-16-17-29.png)

### Web 端

![](/assets/images/2019-06-20-16-17-42.png)
