<div align=center><img src="https://github.com/guozhigq/flutter_v2ex/blob/main/assets/images/icon/icon_android.png" width="200" height="200"></img></div>
<br/>


<div align="center">
    <h1>VVEX</h1>
    <div align="center">
        <img alt="GitHub" src="https://img.shields.io/badge/Flutter-3.7.10-success?style=flat&logo=flutter">
        <img alt="GitHub" src="https://img.shields.io/badge/Dart-2.19.2-blue?style=flat">
        <img alt="GitHub" src="https://img.shields.io/badge/Java-11.0.15-green?style=flat">
        <a target="_blank" href="https://github.com/guozhigq/flutter_v2ex/releases">
            <img alt="Version" src="https://img.shields.io/github/v/release/guozhigq/flutter_v2ex?color=c3e7ff&label=version&style=flat">
        </a>
    </div>
    <br/>
    <p>使用 Flutter 开发的 <a target="_blank" href="https://www.v2ex.com/">V2ex</a> 客户端</p>
    <p>适配了<a target="_blank" href="https://m3.material.io/">Material You</a> 样式</p>
    <a target="_blank" href="https://github.com/guozhigq/flutter_v2ex/releases">去下载</a>
    <br/>
    <br/>
    <img src="https://raw.githubusercontent.com/guozhigq/flutter_v2ex/main/assets/preview/preview_1.png" width="49%"></img>
    <img src="https://files.catbox.moe/kpuks8.png" width="49%"></img>
    <img src="https://files.catbox.moe/dkf8qt.png" width="49%"></img>
    <img src="https://files.catbox.moe/xij4ov.png" width="49%"></img>
</div>
<br/>


## 功能  

[开发计划](https://github.com/users/guozhigq/projects/2)  / <a target="_blank" href="https://t.me/+lm_oOVmF0RJiODk1">加入讨论组</a>
<br/>
- [x] 夜间模式
- [x] 动态主题
- [x] 自动签到
- [x] 高级搜索
- [x] 节点排序
- [x] @回复多人
- [x] 检测更新
- [x] 2FA验证登录
- [x] 回复保存为图片
- [x] 多类型消息提醒
- [x] 评论倒序查看
- [x] 快速返回顶部&刷新
- [x] base64 加密/解密
- [x] Signin with Google
- [x] 话题标记已读
- [x] 消息跳转至楼层
- [x] 图片上传
- [ ] 数据缓存
- [x] 页面骨架屏
- [ ] 适配Pad布局
- [x] markdown 格式发布主题

<br/>

## 环境配置

```
[✓] Flutter (Channel stable, 3.10.6, on macOS 12.1 21C52 darwin-arm64, locale
    zh-Hans-CN)
[✓] Android toolchain - develop for Android devices (Android SDK version 33.0.2)
[✓] Xcode - develop for iOS and macOS (Xcode 13.4)
[✓] Chrome - develop for the web
[✓] Android Studio (version 2022.2)
[✓] VS Code (version 1.77.3)
[✓] Connected device (3 available)
[✓] Network resources
```

## 运行


确保相关开发环境及代码编辑器正确配置

-   终端运行

    -   进入项目根目录
    -   键入 flutter pub get 安装插件
    -   键入 flutter run 编译&运行项目至模拟器

-   编辑器运行 - Android studio
    -   安装 dart&flutter 相关插件
    -   点击顶部工具栏 绿色按钮（确保 main.dart 显示为 flutter logo）
-   编辑器运行 - VSCode
    -   安装 dart&flutter 相关插件
    -   打开 lib -> main.dart 文件
    -   确保底部状态栏显示正确的设备，点击顶部工具栏下箭头 -> Start Debugging

<br/>

## 打包

<strong>执行 flutter build apk/ios</strong>
```dart
打包前在 lib/http/init.dart 中关闭代理

client.findProxy = (uri) {
    // proxy all request to localhost:8888
    // return 'PROXY 192.168.1.60:7890';
    // return 'PROXY 172.16.32.186:7890';
    // return 'PROXY localhost:7890';
    // return 'PROXY 127.0.0.1:7890';
    // 不设置代理 TODO 打包前关闭代理
    return 'DIRECT';
};
```

<br/>

授权@24 版权©️

## 感谢

* [V2LF](https://github.com/w4mxl/V2LF) : 很多思路借鉴了 V2LF， 感谢 🙏
* [sov2ex](https://github.com/Bynil/sov2ex) : 一个便捷的 V2EX 站内搜索引擎，搜索功能基于此实现，感谢🙏

