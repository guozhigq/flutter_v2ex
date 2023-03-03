import 'dart:developer';
import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cookie_jar/cookie_jar.dart' ;
import 'package:flutter_v2ex/utils/utils.dart';
import 'package:flutter_v2ex/utils/cookie.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebView extends StatefulWidget {
  const WebView({super.key});

  @override
  State<WebView> createState() => _WebViewState();
}

class _WebViewState extends State<WebView> {
  // final GlobalKey? webViewKey = GlobalKey();

  InAppWebViewController? webViewController;

  InAppWebViewSettings settings = InAppWebViewSettings(
      // mediaPlaybackRequiresUserGesture: false,
      // allowsInlineMediaPlayback: true,
      // iframeAllow: "camera; microphone",
      // iframeAllowFullscreen: true,
    allowContentAccess: true,
    userAgent: 'random',
    javaScriptEnabled: true,
  );

  PullToRefreshController? pullToRefreshController;

  late ContextMenu contextMenu;
  String aUrl = "";
  double progress = 0;
  var cookieManager = CookieManager.instance();

  @override
  void initState() {
    super.initState();
    setUA();
    aUrl = Get.parameters['aUrl']!;

    // pullToRefreshController = kIsWeb ? null : PullToRefreshController(
    //   settings: PullToRefreshSettings(
    //     color: Theme.of(context).colorScheme.primary,
    //   ),
    //   onRefresh: () async {
    //     if (defaultTargetPlatform == TargetPlatform.android) {
    //       webViewController?.reload();
    //     } else if (defaultTargetPlatform == TargetPlatform.iOS) {
    //       webViewController?.loadUrl(
    //           urlRequest: URLRequest(url: await webViewController?.getUrl()));
    //     }
    //   },
    // );
  }

  setUA() async {
    String? newUserAgent;
    final defaultUserAgent = await InAppWebViewController.getDefaultUserAgent();
    if (Platform.isIOS) {
      newUserAgent = "$defaultUserAgent Safari/604.1";
      // newUserAgent =
      //     "Mozilla/5.0 (Linux; Android 9.0; V2er Build/OPD3.170816.012) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.138 Mobile Safari/537.36";
    }
    if (Platform.isAndroid) {
      newUserAgent =
          "Mozilla/5.0 (Linux; Android 9; LG-H870 Build/PKQ1.190522.001) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/83.0.4103.106 Mobile Safari/537.36";
    }
    webViewController?.setSettings(
        settings: InAppWebViewSettings(userAgent: newUserAgent));
    await webViewController?.setSettings(
        settings: InAppWebViewSettings(userAgent: newUserAgent));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '登录 - Google账号',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        leading:
            IconButton(onPressed: closePage, icon: const Icon(Icons.close)),
        actions: [
          IconButton(onPressed: onShare, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
                child: Stack(
              children: [
                InAppWebView(
                  // key: GlobalKey,
                  initialUrlRequest: URLRequest(url: WebUri(aUrl)),
                  pullToRefreshController: pullToRefreshController,
                  initialSettings: settings,
                  onWebViewCreated: (controller) async {
                    webViewController = controller;
                    // print(await controller.getHtml());
                  },
                  // 加载url时触发
                  onLoadStart: (controller, url) async {
                    // List<Cookie> cookies =
                    //     await cookieManager.getCookies(url: url!);
                    URLRequest(url: WebUri(aUrl));
                  },
                  // 触发多次 页面内可能会有跳转
                  onLoadStop: (controller, url) async {
                    log('🔥🔥 👋🌲');
                    // log(url.toString());
                    // google登录完成
                    // ignore: unrelated_type_equality_checks
                    String strUrl = url.toString();
                    if (strUrl == 'https://www.v2ex.com/#' ||
                        // ignore: unrelated_type_equality_checks
                        strUrl == 'https://www.v2ex.com/') {
                      // 使用cookieJar保存cookie
                      List<Cookie> cookies =
                          await cookieManager.getCookies(url: url!);
                      setCookie.onSet(cookies, strUrl);
                    }
                  },
                  onProgressChanged: (controller, progress) async {
                    if (progress == 100) {
                      pullToRefreshController?.endRefreshing();
                    }
                    setState(() {
                      this.progress = progress / 100;
                    });
                  },
                  onCloseWindow: (controller) async {
                    // List<Cookie> cookies =
                    //     await cookieManager.getCookies(url: WebUri(aUrl));
                    // print('😊: $cookies');
                  },
                ),
                progress < 1.0
                    ? LinearProgressIndicator(value: progress)
                    : Container(),
              ],
            ))
          ],
        ),
      ),
    );
  }

  void onShare() {
    print('share');
  }

  void onMore() {
    print('onMore');
  }

  void closePage() async {
    Navigator.pop(context);
    // List<Cookie> cookies = await cookieManager.getCookies(url: WebUri(aUrl));
    // String cookiePath = await Utils.getCookiePath();
    // PersistCookieJar cookieJar =
    //     PersistCookieJar(ignoreExpires: true, storage: FileStorage(cookiePath));
    // cookieJar.saveFromResponse(
    //     Uri.parse("https://www.v2ex.com/"), cookies);
  }
}
