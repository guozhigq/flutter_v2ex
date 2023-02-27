import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter_v2ex/utils/utils.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebView extends StatefulWidget {
  const WebView({super.key});

  @override
  State<WebView> createState() => _WebViewState();
}

class _WebViewState extends State<WebView> {
  // final GlobalKey? webViewKey = GlobalKey();

  InAppWebViewController? webViewController;

  // InAppWebViewSettings settings = InAppWebViewSettings(
  //     mediaPlaybackRequiresUserGesture: false,
  //     allowsInlineMediaPlayback: true,
  //     iframeAllow: "camera; microphone",
  //     iframeAllowFullscreen: true);

  PullToRefreshController? pullToRefreshController;

  late ContextMenu contextMenu;
  String aUrl = "";
  double progress = 0;
  final urlController = TextEditingController();
  var cookieManager = CookieManager.instance();

  @override
  void initState() {
    super.initState();
    setUA();
    aUrl = Get.parameters['aUrl']!;
  }

  setUA() async {
    String? newUserAgent;
    final defaultUserAgent = await InAppWebViewController.getDefaultUserAgent();
    if (Platform.isIOS) {
      // newUserAgent = "$defaultUserAgent Safari/604.1";
      newUserAgent =
          "Mozilla/5.0 (Linux; Android 9.0; V2er Build/OPD3.170816.012) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.138 Mobile Safari/537.36";
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
                  initialSettings: InAppWebViewSettings(
                    allowContentAccess: true,
                  ),
                  onWebViewCreated: (controller) async {
                    webViewController = controller;
                    // print(await controller.getHtml());
                  },
                  onLoadStart: (controller, url) async {
                    List<Cookie> cookies =
                        await cookieManager.getCookies(url: url!);
                    // print('😊😊😊😊😊: $cookies');
                    URLRequest(url: WebUri(aUrl));
                  },
                  onCloseWindow: (controller) async {
                    List<Cookie> cookies =
                        await cookieManager.getCookies(url: WebUri(aUrl));
                    print('😊: $cookies');
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
    List<Cookie> cookies = await cookieManager.getCookies(url: WebUri(aUrl));
    String cookiePath = await Utils.getCookiePath();
    PersistCookieJar cookieJar =
        PersistCookieJar(ignoreExpires: true, storage: FileStorage(cookiePath));
    // cookieJar.saveFromResponse(
    //     Uri.parse("https://www.v2ex.com/"), cookies);
  }
}
