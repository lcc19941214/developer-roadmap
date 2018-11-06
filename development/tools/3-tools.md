# 常用工具

## 必备工具

* [alfred](https://www.alfredapp.com/)
* [alfred workflows](http://www.alfredworkflow.com/)

## 查文档

* [dash](https://www.dash.org/)
* [jsdoc 语法](http://www.css88.com/doc/jsdoc/about-namepaths.html)
* [can i use](https://caniuse.com/)

## 便捷工具

* [三角形生成器](http://tool.uis.cc/sjmaker/)

## 正则

* [RegExr: Learn, Build, & Test RegEx](http://regexr.com/)

## 图形图像

* [在线 ico 图标制作](http://www.ico.la/)

## 转码

* [图片转 ASCII](http://www.text-image.com/convert/)
* [WEBP 轉 JPG 轉換器](https://convertio.co/zh/webp-jpg/)
* [ASCII Generator](http://www.network-science.de/ascii/)

## 数据统计

* [浏览器市场份额 - 百度统计流量研究院](http://tongji.baidu.com/data/browser)

## 常用 Node Package

* [sharpJS](https://github.com/lovell/sharp) 图形转码
  * [my example code](https://github.com/lcc19941214/sharp-image)
* [fluent-ffmpeg](https://github.com/fluent-ffmpeg/node-fluent-ffmpeg) 音视频转码

  * example code

  ```javascript
  const ffmpegInstaller = require('@ffmpeg-installer/ffmpeg');
  const ffmpeg = require('fluent-ffmpeg');
  const fs = require('fs');
  const util = require('util');
  const path = require('path');
  ffmpeg.setFfmpegPath(ffmpegInstaller.path);
  const [readdir, readFile] = [fs.readdir, fs.readFile].map(util.promisify);

  async function readFiles() {
    try {
      const dir = path.resolve('./raw');
      const outputDir = path.resolve('./output');
      const files = await readdir(dir, 'utf8');
      files.forEach(file => {
        const { name } = path.parse(file);
        const fileName = path.resolve(dir, file);
        const outputFileName = path.resolve(outputDir, `${name}.mp3`);
        ffmpeg(fileName)
          .format('mp3')
          .save(outputFileName);
        console.log(`${name} is converted`);
      });
    } catch (error) {
      console.log(error);
    }
  }

  readFiles();
  ```

