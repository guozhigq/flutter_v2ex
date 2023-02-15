import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_v2ex/utils/web_uri.dart';

class WebView extends StatefulWidget {
  WebView({required this.aUrl, super.key});
  String aUrl;
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
  String url = "";
  double progress = 0;
  final urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(urlController.text),
        actions: [
          IconButton(onPressed: onShare, icon: const Icon(Icons.share_sharp)),
          IconButton(
              onPressed: onMore, icon: const Icon(Icons.more_vert_outlined))
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
                  initialUrlRequest: URLRequest(url: WebUri(widget.aUrl)),
                  onWebViewCreated: (controller) async {
                    webViewController = controller;
                    print(await controller.getHtml());
                  },
                  onLoadStart: (controller, url) async {
                    setState(() {
                      this.url = url.toString();
                      urlController.text = this.url;
                    });
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
}
