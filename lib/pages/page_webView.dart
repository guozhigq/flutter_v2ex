import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_v2ex/utils/cookie.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebView extends StatefulWidget {
  const WebView({super.key});

  @override
  State<WebView> createState() => _WebViewState();
}

class _WebViewState extends State<WebView> {
  InAppWebViewController? webViewController;

  PullToRefreshController? pullToRefreshController;

  String aUrl = "";
  double progress = 0;
  var cookieManager = CookieManager.instance();

  @override
  void initState() {
    super.initState();
    aUrl = Get.parameters['aUrl']!;
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
          IconButton(onPressed: reFresh, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Stack(
                children: [
                  InAppWebView(
                    initialOptions: InAppWebViewGroupOptions(
                        crossPlatform: InAppWebViewOptions(
                      userAgent: 'random',
                      javaScriptEnabled: true,
                      useShouldOverrideUrlLoading: true,
                      useOnLoadResource: true,
                      cacheEnabled: true,
                    )),
                    initialUrlRequest: URLRequest(
                      url: Uri.parse(aUrl),
                      headers: {
                        'refer':
                            'https://www.v2ex.com//signin?next=/mission/daily',
                        'User-Agent':
                            'User-Agent: MOT-V9mm/00.62 UP.Browser/6.2.3.4.c.1.123 (GUI) MMP/2.0'
                      },
                    ),
                    pullToRefreshController: pullToRefreshController,
                    // initialSettings: settings,
                    onWebViewCreated: (controller) async {
                      webViewController = controller;
                      // print(await controller.getHtml());
                    },
                    // 加载url时触发
                    onLoadStart: (controller, url) async {
                      URLRequest(url: Uri.parse(aUrl));
                    },
                    // 触发多次 页面内可能会有跳转
                    onLoadStop: (controller, url) async {
                      pullToRefreshController?.endRefreshing();
                      print('🔥🔥 👋🌲');
                      // google登录完成
                      // ignore: unrelated_type_equality_checks
                      String strUrl = url.toString();
                      if (strUrl == 'https://www.v2ex.com/#' ||
                          // ignore: unrelated_type_equality_checks
                          strUrl == 'https://www.v2ex.com/' ||
                          strUrl == 'https://www.v2ex.com/2fa#' ||
                          strUrl == 'https://www.v2ex.com/2fa') {
                        // 使用cookieJar保存cookie
                        List<Cookie> cookies =
                            await cookieManager.getCookies(url: url!);
                        var res = await SetCookie.onSet(cookies, strUrl);
                        if (res && strUrl.contains('/2fa')) {
                          SmartDialog.show(
                            useSystem: true,
                            animationType:
                                SmartAnimationType.centerFade_otherSlide,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('系统提示'),
                                content: const Text('已登录，是否继续当前账号的2FA认证 ?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('取消'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      Get.back(
                                          result: {'signInGoogle': 'success'});
                                    },
                                    child: const Text('继续'),
                                  )
                                ],
                              );
                            },
                          );
                        } else {
                          Get.back(result: {'signInGoogle': 'success'});
                        }
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
                    onCloseWindow: (controller) {},
                  ),
                  progress < 1.0
                      ? LinearProgressIndicator(value: progress)
                      : Container(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void reFresh() async {
    webViewController?.reload();
  }

  void closePage() async {
    Get.back(result: {'signInGoogle': 'cancel'});
  }
}
