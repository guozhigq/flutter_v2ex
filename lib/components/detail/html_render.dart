import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_v2ex/pages/list_detail.dart';
import 'package:flutter_v2ex/pages/webview_page.dart';

// ignore: must_be_immutable
class HtmlRender extends StatelessWidget {
  String? htmlContent;
  HtmlRender({this.htmlContent, super.key});

  @override
  Widget build(BuildContext context) {
    return Html(
      data: htmlContent,
      onLinkTap: (url, buildContext, attributes, element) =>
          {openHrefByWebview(url!, context)},
      onImageTap: (String? url, RenderContext buildContext,
          Map<String, String> attributes, element) {
        openImageDialog(url, context);
        //open image in webview, or launch image in browser, or any other logic here
      },
      style: {
        "html": Style(
          // fontSize: FontSize(
          //     Theme.of(context).textTheme.bodyLarge!.fontSize!),
          textAlign: TextAlign.justify,
          lineHeight: const LineHeight(1.6),
        ),
        "a": Style(
          color: Theme.of(context).colorScheme.primary,
          textDecoration: TextDecoration.underline,
        ),
        "p": Style(
          margin: Margins.only(bottom: 0),
          // fontSize: FontSize(
          //     Theme.of(context).textTheme.titleLarge!.fontSize!),
        ),
        "li > p": Style(
          display: Display.inline,
        ),
        "li": Style(
          padding: const EdgeInsets.only(bottom: 4),
          textAlign: TextAlign.justify,
        ),
        "image": Style(margin: Margins.only(top: 4, bottom: 4)),
        "p > img": Style(margin: Margins.only(top: 4, bottom: 4)),
        "pre": Style(
          margin: Margins.only(top: 0),
          padding: const EdgeInsets.all(2),
          border: Border.all(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
        ),
        "code > span": Style(textAlign: TextAlign.start)
      },
    );
  }

  // a标签webview跳转
  void openHrefByWebview(String? aUrl, BuildContext context) async {
    RegExp exp = RegExp(r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+');
    bool isValidator = exp.hasMatch(aUrl!);
    if (isValidator) {
      if (aUrl.contains('www.v2ex.com/t/')) {
        List arr = aUrl.split('/');
        String topicId = arr[arr.length - 1];
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ListDetail(topicId: topicId),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WebView(aUrl: aUrl),
          ),
        );
      }
    } else {
      print('无效网址');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).snackBarTheme.backgroundColor,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: [
              Icon(
                Icons.error,
                color: Theme.of(context).colorScheme.errorContainer,
              ),
              const SizedBox(width: 6),
              const Text('无效网址')
            ],
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          action: SnackBarAction(
            label: '复制',
            textColor: Theme.of(context).colorScheme.onInverseSurface,
            onPressed: () {
              // Some code to undo the change.
            },
          ),
        ),
      );
    }
  }

  // 打开大图预览
  void openImageDialog(String? imgUrl, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return GestureDetector(
          behavior: HitTestBehavior.deferToChild,
          onVerticalDragUpdate: (details) => {Navigator.pop(context)},
          child: PhotoView(
            tightMode: true,
            imageProvider: NetworkImage(imgUrl!),
            heroAttributes: const PhotoViewHeroAttributes(tag: "someTag"),
            gestureDetectorBehavior: HitTestBehavior.translucent,
            loadingBuilder: (context, event) => Center(
              child: SizedBox(
                width: 30.0,
                height: 30.0,
                child: CircularProgressIndicator(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
