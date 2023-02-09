import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_v2ex/pages/webview_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/idea.dart';
// import 'package:flutter_v2ex/pages/profile_page.dart';
import 'package:flutter_v2ex/utils/utils.dart';
import 'package:extended_image/extended_image.dart';
// import 'package:flutter_html_all/flutter_html_all.dart';
// import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:flutter_v2ex/pages/image_preview_page.dart';

// ignore: must_be_immutable
class HtmlRender extends StatelessWidget {
  String? htmlContent;
  final int? imgCount;
  final List? imgList;
  HtmlRender({this.htmlContent, this.imgCount, this.imgList, super.key});

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: Html(
        data: htmlContent,
        onLinkTap: (url, buildContext, attributes, element) =>
            {openHrefByWebview(url!, context)},
        customRenders: {
          // tagMatcher("iframe"): CustomRender.widget(
          // widget: (htmlContext, buildChildren) {
          //   return Text('Youtube video Player', style: Theme.of(context).textTheme.titleMedium,);
          // }
          // ),
          tagMatcher("img"): CustomRender.widget(
            widget: (htmlContext, buildChildren) {
              String? imgUrl = htmlContext.tree.element!.attributes['src'];
              imgUrl = Utils().imageUrl(imgUrl!);
              // todo 多张图片轮播
              return SelectionContainer.disabled(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImagePreview(imgList: imgList!, initialPage: imgList!.indexOf(imgUrl)
                        ),
                        fullscreenDialog: true,
                      ),
                    );
                  },
                  child: Container(
                    clipBehavior: Clip.hardEdge,
                    margin: const EdgeInsets.only(top: 4, bottom: 4),
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(4)),
                    child: Hero(
                      tag: imgUrl,
                      child: CachedNetworkImage(
                        imageUrl: imgUrl,
                        width: double.infinity,
                        fit: BoxFit.fitHeight,
                        fadeOutDuration: const Duration(milliseconds: 500),
                        placeholder: (htmlContext, url) {
                          return const SizedBox(
                            height: 30,
                            child: Center(
                              child: Text('图片加载中...'),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          // tagMatcher("pre"):
          //     CustomRender.widget(widget: (htmlContext, buildChildren) {
          //   var code = htmlContext.tree.element!.children[0].innerHtml;
          //   return HighlightView(
          //     code,
          //     language: 'clojure',
          //     theme: ideaTheme,
          //   );
          // }),
        },
        style: {
          "html": Style(
            // fontSize: FontSize(
            //     Theme.of(context).textTheme.bodyLarge!.fontSize!),
            fontSize: FontSize.medium,
            lineHeight: LineHeight.percent(140),
          ),
          "body": Style(margin: Margins.zero, padding: EdgeInsets.zero),
          "a": Style(
            color: Theme.of(context).colorScheme.primary,
            textDecoration: TextDecoration.none,
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
                color:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
          ),
          "code > span": Style(textAlign: TextAlign.start)
        },
      ),
    );
  }

  // a标签webview跳转
  void openHrefByWebview(String? aUrl, BuildContext context) async {
    RegExp exp = RegExp(r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+');
    bool isValidator = exp.hasMatch(aUrl!);
    if (isValidator) {
      // http(s) 网址
      if (aUrl.startsWith('www.v2ex.com/t/') ||
          aUrl.startsWith('https://v2ex.com/t')) {
        // v2ex 链接
        List arr = aUrl.split('/');
        String topicId = arr[arr.length - 1];
        Get.toNamed('/t/$topicId');
      } else {
        // 其他链接
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WebView(aUrl: aUrl),
          ),
        );
      }
    } else if (aUrl.startsWith('/member/') || aUrl.startsWith('/go/') || aUrl.startsWith('/t/')) {
      Get.toNamed(aUrl);
    } else {
      // ignore: avoid_print
      print('无效网址');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(showCloseIcon: true, content: Text('无效网址')),
      );
    }
  }

}
