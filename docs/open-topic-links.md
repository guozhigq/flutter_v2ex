# 从外部打开帖子

- Android：接收 `http(s)://v2ex.com/t/123`、`www.v2ex.com` 以及 Manifest 中列出的镜像域名。冷启动和运行中收到链接均跳转到帖子。
- Android / iOS：可通过 `vvex://v2ex.com/t/123` 唤起。iOS 的普通 HTTPS Universal Links 需要网站提供 AASA 并配置 Associated Domains；当前没有网站控制权，因此未配置。
- 启动应用或切回前台时，读取一次剪贴板；识别 V2EX 帖子链接后询问是否打开，同一份剪贴板内容在本次运行中不会反复提示。系统可能显示剪贴板访问提示。
- 支持分享文字中包含链接、`?p=2`、`#reply101`、`?p=2#r_456`。不处理其他网站或非帖子路径。

## Android 系统设置

Android 12 及以上，请在 VVEX「设置 → 浏览器链接打开设置」进入系统页面，开启「打开支持的链接」，再在「添加链接」中勾选 `v2ex.com`、`www.v2ex.com` 等需要的域名。也可从系统「设置 → 应用 → VVEX → 默认打开」进入。只开启总开关、没有选择域名，普通 HTTPS 链接仍可能交给浏览器。

Manifest 使用 `android:autoVerify="true"` 将域名登记到系统链接管理。应用不能自行启用域名选择；自动域名验证需要 V2EX 网站在 `/.well-known/assetlinks.json` 授权本应用的包名和签名。浏览器地址栏输入、站内跳转及部分内置浏览器可能继续留在浏览器中。

## 真机验证

```sh
# 显式测试应用接收链接（不代表系统默认打开已生效）
adb shell am start -W -a android.intent.action.VIEW -d 'https://www.v2ex.com/t/123?p=2#r_456' com.guozhigq.vvex
# 测试系统链接分发（先配置默认打开）
adb shell am start -W -a android.intent.action.VIEW -c android.intent.category.BROWSABLE -d 'https://www.v2ex.com/t/123'
# 自定义协议
adb shell am start -W -a android.intent.action.VIEW -d 'vvex://v2ex.com/t/123'
```

分别在应用已关闭、停留首页、停留另一帖子、后台状态下验证；复制帖子链接后切回应用，确认取消后不会重复弹窗、打开后进入对应帖子，普通文本和伪造域名不弹窗。

桌面平台目前支持剪贴板识别，未注册系统 URL 协议。
