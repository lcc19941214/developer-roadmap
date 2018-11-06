# 移动端开发中的一些小笔记

## overview

* [移动端调试](170808-yi-dong-duan-kai-fa-xiao-bi-ji.md#debug)
* [移动端适配方案](170808-yi-dong-duan-kai-fa-xiao-bi-ji.md#compatible-solution)
* [css动画](170808-yi-dong-duan-kai-fa-xiao-bi-ji.md#css-animation)
* [踩坑分享](170808-yi-dong-duan-kai-fa-xiao-bi-ji.md#sharing)
  * [微信开发相关](170808-yi-dong-duan-kai-fa-xiao-bi-ji.md#wechat-issues)
  * [滚动穿透](170808-yi-dong-duan-kai-fa-xiao-bi-ji.md#scroll-penetrate)
  * [输入法键盘遮挡](170808-yi-dong-duan-kai-fa-xiao-bi-ji.md#keyboard-cover)
  * [iOS相关](170808-yi-dong-duan-kai-fa-xiao-bi-ji.md#ios-issues)

## 移动端调试 <a id="debug"></a>

移动端开发浏览器调试的方式很多，可以参考[各种 真机远程调试 方法 汇总](https://github.com/jieyou/remote_inspect_web_on_real_device#调试android上的x5内核)

调试工具包括chrome remote device， safari等。

### 1. Chrome remote device

适用于一般的页面和webview，大部分的浏览器均可调试。通过USB连接电脑即可，谷歌官方有详细的介绍，可以参考[远程调试 Android 设备使用入门](https://developers.google.com/web/tools/chrome-devtools/remote-debugging/?hl=zh-cn)。

QQ browser、钉钉、微信中webview的页面一般无法用chrome remote device进行调试。

_不过不是真机调试，算是用Chrome模拟的。_

### 2. Mac Safari

#### 真机测试

在iOS设备上的Safari浏览器中打开要调试的页面，然后切换到Mac的Safari，在顶部菜单栏选择“开发”→找到你的iOS设备名称→右边二级菜单选择需要调试的对应标签页，即可开始远程调试

#### Simulator

mac系统中通过模拟器可以直接进行真机测试，需要安装Xcode，启动模拟器后选择一个具体的设备，在模拟器中的safari访问页面；然后启动mac中的safari（需要开启开发者选项），重复重复上个步骤。

### 3. 腾讯TBS

可用于模拟QQ browser、微信等X5内核的浏览器页面，详细可以访问[腾讯浏览服务 TBS studio](https://x5.tencent.com/tbs/guide/debug.html)。十分强大的调试工具。

我在开发过程中遇到过手机（锤子 Smartisan M1/ 小米 Mi 4c）无论如何都没法连接到mac TBS studio的问题。后来发现需要手动安装Android adb工具，让手机为电脑授权。

* 下载[Android SDK 命令行工具](https://developer.android.com/studio/index.html?hl=zh-cn)。下载sdk-tools和sdk-platform-tools，并且配置环境变量。

  ```bash
  ANDROID_SDK_PATH=/Users/lcc/Android/
  export ANDROID_SDK_PATH
  export PATH=$PATH:$ANDROID_SDK_PATH/tools:$ANDROID_SDK_PATH/platform-tools
  ```

* 通过usb连接手机后，启动adb的转发服务，也可以自定义端口

  ```bash
     adb forward tcp:9988 tcp:9988
  ```

* 在手机弹出的授权页面上为当前电脑授权，然后在TBS studio里即可正常连接。

### 4. 微信web开发者工具

微信自己推出的调试工具，在[微信公众平台](https://mp.weixin.qq.com/wiki?t=resource/res_main&id=mp1455784140)有比较详细的介绍。

但是仅适用于能够安装TBS内核的手机。我使用锤子M1手机开发时遇到过无法安装TBS内核的问题。TBS的安装也是一个大坑，建议还是使用腾讯的TBS Studio调试微信。

### 移动端调试工具

* [v-console](http://libraries.io/github/WechatFE/vConsole) 微信团队实现的工具库，在手机端模拟console的信息控制，可以方便的打印调试信息。但是一些代码错误有时候会捕捉不到。

## 移动端适配方案 <a id="compatible-solution"></a>

一般来说，移动端适配主要目标，是保证不同尺寸的屏幕的UI表现一致。

### 相关概念

#### 屏幕尺寸/viewport

提到移动端适配，这里首先要了解一下什么是`viewport`（[详情查看MDN的说明](https://developer.mozilla.org/zh-CN/docs/Mobile/Viewport_meta_tag)）。我们可以通过`viewport`来设置页面的设备宽度，缩放比例，对页面进行基本的控制。

简单来说，`viewport`就是设备的可见范围。不过在移动设备上，`viewport`的宽度并不等于设备的实际宽度，更多详情可以参考[移动前端开发之viewport的深入理解](http://www.cnblogs.com/2050/p/3877280.html)。

#### 设备像素 & 独立像素 & devicePixelRatio

设备像素就是设备屏幕用于成像的最小物理单元，而独立像素即我们通过代码用于描述UI尺寸的单位（如css单位）。

一般手机参数中的分辨率，也即设备像素，如iPhone6的分辨率为`1334 x 750`；而独立像素为`667*375`。

之前我对于这两个概念的理解一直很模糊，看了一些资料，总是在纠结移动端适配与设备像素和独立像素的关系。实际上这二者与屏幕适配没有直接的关系，只需要知道设备像素越密集，dpr越大就行了。

dpr大的设备上，如拥有retina屏幕的苹果设备，用于展示的图片需要更大的尺寸，因为相同大小的独立像素区域内，设备像素更加密集，展示图片时需要填充更多的像素，否则会出现失真。这里也有很多解决方案，就不详述了。

屏幕缩放可以参考前面提到的[移动前端开发之viewport的深入理解](http://www.cnblogs.com/2050/p/3877280.html)这篇文章。

关于设备像素和物理像素，可参考以下几篇：

* [前端乱炖-移动端高清、多屏适配方案](http://www.html-js.com/article/3041?from=timeline&isappinstalled=0)
* [张鑫旭-设备像素比devicePixelRatio简单介绍](http://www.zhangxinxu.com/wordpress/2012/08/window-devicepixelratio/)

#### orientation

涉及到屏幕翻转（即横向显示）时的样式，要利用css media query的[orientation](https://developer.mozilla.org/en-US/docs/Web/CSS/Media_Queries/Using_media_queries)来设置`portrait`和`landscape`，调整不同方向上的屏幕尺寸。

### 利用viewport和rem进行移动端适配

参考

[移动端H5页面高清多屏适配方案](http://www.cocoachina.com/webapp/20150715/12585.html)

## CSS动画 <a id="css-animation"></a>

移动开发中涉及到添加CSS动效，下面给出一些推荐：

### Animate.css

[**animate.css**](https://daneden.github.io/animate.css/)是一个很轻量的css动画库，如果不想引入所有文件，直接从源码中拷贝需要的动画样式即可。

### React动画库

react动画库有很多选项，简单介绍两个：

* **react-addons-css-transition-group**  [**Animation \| React** ](https://facebook.github.io/react/docs/animation.html)对应 transitionName 通过 css 来实现动画
* [**Ant Motion**](https://motion.ant.design/) ant design 

### 3D动效

实现3D动效，比较多的选择是[**Three.js**](https://threejs.org/)和[**webGL**](https://www.khronos.org/webgl/)。

我对这两个的研究都不多，这里推荐一个依赖css3 `transition`的轻量库[**css3d-engine**](https://github.com/shrekshrek/css3d-engine#css3d-engine)。支持场景、景深，也可以结合手机的重力感应实现丰富的3D视觉效果。

阿迪达斯使用该库实现了一个特别酷炫的[营销广告](http://drose6.adidasevent.com/)。

## 踩坑分享 <a id="sharing"></a>

### 微信开发相关 <a id="wechat-issues"></a>

#### 调试

关于的微信的调试简直就是可怕，还好现在腾讯推出了相关的调试工具，详见本文第一节。

#### 缓存

开发过程中要来回切换测试环境和线上环境，DNS解析缓存会影响开发，所以需要清除缓存。

* 安卓可以尝试在微信登陆[debugx5.qq.com](http://debugx5.qq.com)，在代理页面最下方，勾选需要清理的缓存类型，选择**清除**即可
* iOS稍微麻烦一点，按照[官方文档](https://mp.weixin.qq.com/wiki?t=resource/res_main&id=mp1483682025_enmey)的说法，`退出微信账号后，将会清空所有Cookie和LocalStorage`。不过实际开发过程中，iPhone SE和iPhone 6 plus都必须`退出微信登录 - 杀死微信进程 - 重启并登陆`才可以清除缓存

#### 文档

_顺便吐槽一下微信的开发文档真是乱七八糟_

* [小程序](https://mp.weixin.qq.com/debug/wxadoc/introduction/index.html?t=1505119774)
* [公众平台](https://mp.weixin.qq.com/wiki?t=resource/res_main&id=mp1445241432) webview开发基本都在这里面可以搜索。微信似乎在多个平台维护了多个不同版本的文档，甚至微信登录的文档都很分散

### 滚动穿透 <a id="scroll-penetrate"></a>

滚动穿透问题，即移动端当有 fixed 遮罩背景和弹出层时，在屏幕上滑动能够滑动背景下面的内容。

可参考的解决方案：[移动端滚动穿透问题](https://github.com/pod4g/tool/wiki/移动端滚动穿透问题)

这里提供我的解决方案

```javascript
// util是项目常用函数工具库
function fixScroll(selector, flag = true) {
  if (!fixScroll.handleTouchMove) {
    fixScroll.handleTouchMove = e => {
      e.preventDefault();
    };
  }

  let elem;
  if (util.isDOM(selector)) {
    elem = selector;
  }

  function fix() {
    if (util.isString(selector) && selector !== '') {
      elem = document.querySelector(selector);
    }
    if (elem) {
      if (flag) {
        elem.addEventListener('touchmove', fixScroll.handleTouchMove, false);
      } else {
        elem.removeEventListener('touchmove', fixScroll.handleTouchMove, false);
      }
    }
  }

  setTimeout(fix, 10);
}
```

### 输入法键盘遮挡 <a id="keyboard-cover"></a>

部分安卓机型在输入法调起之后，会直接覆盖页面下半部分，如果输入框在页面下半部分，则会被隐藏。

我在开发过程中没有涉及到fixed底部输入框的问题，这里主要说一下表单输入框被遮挡的问题。

我采用的解决方案是，为input绑定onfocus事件，点击input时会调起键盘，这里延迟300s等待键盘谈起，通过onfocus事件获取到event.target，并调用下面的inputScrollIntoView方法。

```javascript
function handleOnFlcus(event) {
  inputScrollIntoView(event.target);
}

// util是项目常用函数工具库
function inputScrollIntoView(elem) {
  if (!util.isDOM(elem)) return;
    setTimeout(() => {
      const rect = elem.getBoundingClientRect();
      if (rect.bottom <= 0 || rect.bottom > window.innerHeight) {
        elem.scrollIntoView(false);
      }
    }, 300);
}
```

### iOS相关 <a id="ios-issues"></a>

#### css样式

1. **input/textarea 内部阴影**

   需要使用`-webkit-appearance: none;`隐藏。

2. **可点击项被touch时的阴影**

   可以使用`-webkit-tap-highlight-color`属性来控制。

#### 其他

1. **viewport禁用缩放失效**

   iOS 10以上的safari会无视viewport的meta标签，绑定了`touchstart`和`touchend`的元素，依然存在双指和双击缩放的问题。详情可以参考stackoverflow中的[讨论](https://stackoverflow.com/questions/37808180/disable-viewport-zooming-ios-10-safari)

   提供一个解决方案

   ```javascript
   // disable iOS 10 safari scale
   document.documentElement.addEventListener('touchstart', function (event) {
     if (event.touches.length > 1) {
       event.preventDefault();
     }
   }, false);

   var lastTouchEnd = 0;
   document.documentElement.addEventListener('touchend', function (event) {
     var now = Date.now();
     if (now - lastTouchEnd <= 300) {
       event.preventDefault();
     }
     lastTouchEnd = now;
   }, false);
   ```

   ​

2. **无法自动触发input元素的focus且调起键盘**

   （**unable to trigger input focus and keyboard programmatically**）

   直接使用`input.focus()`是无法在ios中调起键盘的，因为ios中input元素的focus必须由事件触发。

   此外，如果模拟了触摸事件，但是在`setTimeout`中延迟执行，也是不行的。这部分可以参考stackoverflow上的case：[Mobile Safari Autofocus text field](http://stackoverflow.com/questions/6287478/mobile-safari-autofocus-text-field).

   来自FastClick团队的大牛指出了IOS下input的获取焦点存在这样的问题：

   > _my colleagues and I found that iOS will only allow focus to be triggered on other elements, from within a function, if the first function in the call stack was triggered by a non-programmatic event. In your case, the call to setTimeout starts a new call stack, and the security mechanism kicks in to prevent you from setting focus on the input._

   综上，要在ios中选中input并调起键盘，可以将focus调用包装在一个用户行为触发的事件中，如点击事件、表单onChange事件等。

   解决方案

   * [Trigger focus on input on iPhone programmatically](http://blog.pixelastic.com/2015/07/13/trigger-focus-on-input-on-iphone-programmatically/)
   * [Show keyboard on iOS automatically](https://www.sencha.com/forum/showthread.php?280423-Show-keyboard-on-iOS-automatically)

   如果需要模拟触发事件，可以参考[manually trigger touch event](https://stackoverflow.com/questions/18059860/manually-trigger-touch-event)

   ​

