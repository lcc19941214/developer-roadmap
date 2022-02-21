# 移动端调试 web

移动端开发浏览器调试的方式很多，可以参考[各种 真机远程调试 方法 汇总](https://github.com/jieyou/remote\_inspect\_web\_on\_real\_device#%E8%B0%83%E8%AF%95android%E4%B8%8A%E7%9A%84x5%E5%86%85%E6%A0%B8)

调试工具包括chrome remote device， safari等。

## 1. Chrome remote device

适用于一般的页面和webview，大部分的浏览器均可调试。通过USB连接电脑即可，谷歌官方有详细的介绍，可以参考[远程调试 Android 设备使用入门](https://developers.google.com/web/tools/chrome-devtools/remote-debugging/?hl=zh-cn)。

QQ browser、钉钉、微信中webview的页面一般无法用chrome remote device进行调试。

_不过不是真机调试，算是用Chrome模拟的。_

## 2. Mac Safari

### 真机测试

在iOS设备上的Safari浏览器中打开要调试的页面，然后切换到Mac的Safari，在顶部菜单栏选择“开发”→找到你的iOS设备名称→右边二级菜单选择需要调试的对应标签页，即可开始远程调试

### Simulator

mac系统中通过模拟器可以直接进行真机测试，需要安装Xcode，启动模拟器后选择一个具体的设备，在模拟器中的safari访问页面；然后启动mac中的safari（需要开启开发者选项），重复重复上个步骤。

## 3. 腾讯TBS

可用于模拟QQ browser、微信等X5内核的浏览器页面，详细可以访问[腾讯浏览服务 TBS studio](https://x5.tencent.com/tbs/guide/debug.html)。十分强大的调试工具。

我在开发过程中遇到过手机（锤子 Smartisan M1/ 小米 Mi 4c）无论如何都没法连接到mac TBS studio的问题。后来发现需要手动安装Android adb工具，让手机为电脑授权。

*   下载[Android SDK 命令行工具](https://developer.android.com/studio/index.html?hl=zh-cn)。下载sdk-tools和sdk-platform-tools，并且配置环境变量。

    ```bash
    ANDROID_SDK_PATH=/Users/lcc/Android/
    export ANDROID_SDK_PATH
    export PATH=$PATH:$ANDROID_SDK_PATH/tools:$ANDROID_SDK_PATH/platform-tools
    ```
*   通过usb连接手机后，启动adb的转发服务，也可以自定义端口

    ```bash
       adb forward tcp:9988 tcp:9988
    ```
* 在手机弹出的授权页面上为当前电脑授权，然后在TBS studio里即可正常连接。

## 4. 微信web开发者工具

微信自己推出的调试工具，在[微信公众平台](https://mp.weixin.qq.com/wiki?t=resource/res\_main\&id=mp1455784140)有比较详细的介绍。

但是仅适用于能够安装TBS内核的手机。我使用锤子M1手机开发时遇到过无法安装TBS内核的问题。TBS的安装也是一个大坑，建议还是使用腾讯的TBS Studio调试微信。

## 移动端调试工具

* [v-console](http://libraries.io/github/WechatFE/vConsole) 微信团队实现的工具库，在手机端模拟console的信息控制，可以方便的打印调试信息。但是一些代码错误有时候会捕捉不到。
