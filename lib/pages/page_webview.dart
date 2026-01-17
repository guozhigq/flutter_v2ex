import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_v2ex/utils/cookie.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class WebView extends StatefulWidget {
  const WebView({super.key});

  @override
  State<WebView> createState() => _WebViewState();
}

class _WebViewState extends State<WebView> {
  final CookieManager _cookieManager = CookieManager.instance();
  final InAppWebViewSettings _webViewSettings = InAppWebViewSettings(
    javaScriptEnabled: true,
    useShouldOverrideUrlLoading: true,
    useOnLoadResource: true,
    cacheEnabled: true,
    allowsInlineMediaPlayback: true,
    mediaPlaybackRequiresUserGesture: false,
  );

  InAppWebViewController? webViewController;
  late final PullToRefreshController _pullToRefreshController;
  bool _isDisposing = false;

  String aUrl = "";
  double progress = 0;

  @override
  void initState() {
    super.initState();
    aUrl = Get.parameters['aUrl'] ?? '';
    _pullToRefreshController = PullToRefreshController(
      settings: PullToRefreshSettings(color: Colors.blue),
      onRefresh: () async {
        if (Platform.isAndroid) {
          await webViewController?.reload();
        } else {
          final uri = await webViewController?.getUrl();
          if (uri != null) {
            await webViewController?.loadUrl(urlRequest: URLRequest(url: uri));
          }
        }
      },
    );
  }

  @override
  void dispose() {
    _isDisposing = true;
    super.dispose();
  }

  void _endRefreshingSafely() {
    if (_isDisposing) {
      return;
    }
    _pullToRefreshController.endRefreshing();
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
                    initialSettings: _webViewSettings,
                    initialUrlRequest: URLRequest(
                      url: WebUri(aUrl),
                      headers: const {
                        'Referer':
                            'https://www.v2ex.com/signin?next=/mission/daily',
                      },
                    ),
                    pullToRefreshController: _pullToRefreshController,
                    onWebViewCreated: (controller) async {
                      webViewController = controller;
                    },
                    shouldOverrideUrlLoading:
                        (controller, navigationAction) async {
                      final uri = navigationAction.request.url;
                      if (uri == null) {
                        return NavigationActionPolicy.CANCEL;
                      }
                      const allowedSchemes = {
                        'http',
                        'https',
                        'file',
                        'chrome',
                        'data',
                        'javascript',
                        'about',
                      };
                      if (!allowedSchemes.contains(uri.scheme)) {
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri,
                              mode: LaunchMode.externalApplication);
                        }
                        return NavigationActionPolicy.CANCEL;
                      }
                      return NavigationActionPolicy.ALLOW;
                    },
                    onLoadStart: (controller, url) async {
                      if (!mounted) {
                        return;
                      }
                      setState(() {
                        aUrl = url?.toString() ?? aUrl;
                      });
                    },
                    onLoadStop: (controller, url) async {
                      _endRefreshingSafely();
                      final strUrl = url.toString();
                      if (strUrl == 'https://www.v2ex.com/#' ||
                          strUrl == 'https://www.v2ex.com/' ||
                          strUrl == 'https://www.v2ex.com/2fa#' ||
                          strUrl == 'https://www.v2ex.com/2fa') {
                        final cookies =
                            await _cookieManager.getCookies(url: url!);
                        final res = await SetCookie.onSet(cookies, strUrl);
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
                    onReceivedError: (controller, request, error) {
                      _endRefreshingSafely();
                    },
                    onProgressChanged: (controller, progress) async {
                      if (progress == 100) {
                        _endRefreshingSafely();
                      }
                      if (!mounted) {
                        return;
                      }
                      setState(() {
                        this.progress = progress / 100;
                      });
                    },
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
