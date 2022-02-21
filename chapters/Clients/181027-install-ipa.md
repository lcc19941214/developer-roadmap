# 安装 IPA 包

> 2018年10月27日 11:39:17

最近需要给iPhone手机设置科♂学♂上♂网，已经有自己搭建的 ssserver 服务，并且在 mac 和安卓上利用 ssr 客户端畅快地科♂学♂上♂网了。无奈8102年 app store 里找不到任何相关的 app，要么就得花钱。

后来发现了这样一个网站 [shadowsocks.org/](https://shadowsocks.org)，提供了多种客户端工具的下载，也就是说，这些工具都只是 ss 的协议。

![](<../../assets/images/2018-10-27-11-37-58 (1).png>)

iOS 端赫然在列啊！ 经过实验， `wingy` 在大陆区已经无法下载了。据说可以通过切换 iCloud 账号实现下载并使用。

于是我把目光转移到了 `outline` 身上。很遗憾，大陆区同样无法下载；不过难能可贵的是，官方提供了它的 github [repo](https://github.com/Jigsaw-Code/outline-client/) 地址！

作为一个程序员，有了源码地址意味着什么？你懂的，再不济咱们可以自己编译一个.ipa啊！很幸运的是，outline-client 的作者定期发布了编译好的版本。

![](<../../assets/images/2018-10-27-11-43-26 (1).png>)

也就是说，现在的问题变成了，如何在手机上安装 ipa 文件？因为我用的是 Mac，而且个人很不喜欢用各种所谓的手机助手，所以这里不考虑XX助手等方式。

## 使用 iTunes 安装 .ipa

这种方法其实已经过时了，因为 apple 在 iTunes@12.7 版本时移除了 application 的入口，以至于无法通过 iTunes 直接安装 .ipa了。

```
iTunes 12.7 change log
The new iTunes focuses on music, films, TV programmes, podcasts and audiobooks. It adds support for syncing iOS 11 devices and includes new feature for:
Apple Music, Now discover music with friends. Members can create profiles and follow each other to see music they are listening to and any playlists they've shared.
Podcasts. iTunes U collections are now part the Apple Podcasts family. Search and explore free educational content produced by leading schools, universities, museums and cultural institutions all in one place.
If you previously used iTunes to sync apps or ringtones to your iOS device, use the new App Store Sound Settings on iOS to re-download them without your Mac.
```

相关链接:

* [History of iTunes - Wikipedia](https://en.wikipedia.org/wiki/History\_of\_iTunes#iTunes\_9)
* [Software > Portable Mobile > iTunes 12.9](https://www.videohelp.com/software/iTunes/version-history)

## 使用 Apple configurator 2 安卓 .ipa (mac only)

![](<../../assets/images/2018-10-27-12-01-56 (1).png>)

官方亲儿子，直接看[官方支持文档](https://support.apple.com/apple-configurator)吧，方法不赘述。 不过比较坑的是，apple 刚刚更新了 10.14 版本的 macOS， Apple configurator 2 要求必须是 > 10.14才能从 app store 安装.

## 使用 diawi.com 转链接下载并安装 .ipa

一个神奇的网站 [diawi.com](https://www.diawi.com)。

![](<../../assets/images/2018-10-27-12-05-08 (1).png>)

支持上传 .ipa 文件并生成下载链接，只需要通过 safari 访问即可下载。建议注册一个免费账号进行使用。

![](<../../assets/images/2018-10-27-12-05-34 (1).png>)

## 使用 xcode 安装 .ipa
