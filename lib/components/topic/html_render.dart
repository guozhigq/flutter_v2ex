import 'package:flutter_html_table/flutter_html_table.dart';
import 'package:flutter_v2ex/utils/storage.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_v2ex/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_v2ex/pages/page_preview.dart';
import 'package:flutter_html_iframe/flutter_html_iframe.dart';
import 'package:flutter_v2ex/components/common/image_loading.dart';
import 'package:cached_network_image/cached_network_image.dart';

// ignore: must_be_immutable
class HtmlRender extends StatefulWidget {
  String? htmlContent;
  final int? imgCount;
  final List? imgList;
  final double? fs;

  HtmlRender(
      {this.htmlContent, this.imgCount, this.imgList, this.fs, super.key});

  @override
  _HtmlRenderState createState() => _HtmlRenderState();
}

class _HtmlRenderState extends State<HtmlRender> {
  double? htmlFs;

  @override
  void initState() {
    super.initState();
    if (widget.fs != null) {
      htmlFs = widget.fs;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Html(
      data: widget.htmlContent,
      onLinkTap: (url, buildContext, attributes, element) =>
          {openHrefByWebview(url!, context)},
      customRenders: {
        tagMatcher("iframe"): iframeRender(),
        tagMatcher("table"): tableRender(),
        tagMatcher("img"): CustomRender.widget(
          widget: (htmlContext, buildChildren) {
            String? imgUrl = htmlContext.tree.element!.attributes['src'];
            imgUrl = Utils().imageUrl(imgUrl!);
            // ignore: avoid_print
            // todo 多张图片轮播
            return SelectionContainer.disabled(
              child: GestureDetector(
                onTap: () {
                  Map<dynamic, dynamic> arguments = {
                    "imgList": widget.imgList!,
                    "initialPage": widget.imgList!.indexOf(imgUrl),
                  };
                  Get.toNamed('/imgPreview', arguments: arguments);
                },
                child: Container(
                  clipBehavior: Clip.hardEdge,
                  // margin: const EdgeInsets.only(top: 4, bottom: 4),
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(4)),
                  // child: CachedNetworkImage(
                  //   imageUrl: imgUrl,
                  //   httpHeaders: const {
                  //     'Referrer-Policy': 'no-referrer',
                  //     'sec-fetch-dest': 'image',
                  //     'accept': 'image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8'
                  //   },
                  //   // width: double.infinity,
                  //   // fit: BoxFit.fitHeight,
                  //   fadeOutDuration: const Duration(milliseconds: 500),
                  //   placeholder: (htmlContext, url) {
                  //     return Container(
                  //       width: double.infinity,
                  //       height: 60,
                  //       color: Theme.of(context).colorScheme.onInverseSurface,
                  //       child: const Center(
                  //         child: Text('图片加载中...'),
                  //       ),
                  //     );
                  //   },
                  // ),
                  child: ImageLoading(
                    imgUrl: imgUrl,
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
          fontSize: htmlFs != null ? FontSize(htmlFs!) : FontSize.medium,
          lineHeight: LineHeight.percent(140),
        ),
        "body": Style(margin: Margins.zero, padding: EdgeInsets.zero),
        "a": Style(
          color: Theme.of(context).colorScheme.primary,
          textDecoration: TextDecoration.none,
        ),
        "p": Style(
          margin: Margins.only(bottom: 0),
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
        "code > span": Style(textAlign: TextAlign.start),
        "hr": Style(
          margin: Margins.zero,
          padding: EdgeInsets.zero,
          border: Border(
            top: BorderSide(
              width: 1.0,
              color:
                  Theme.of(context).colorScheme.onBackground.withOpacity(0.3),
            ),
          ),
        ),
        'table': Style(
          border: Border(
            right: BorderSide(
              width: 0.5,
              color:
              Theme.of(context).colorScheme.onBackground.withOpacity(0.3),
            ),
            bottom: BorderSide(
              width: 0.5,
              color:
              Theme.of(context).colorScheme.onBackground.withOpacity(0.3),
            ),
          ),
        ),
        'tr': Style(
          border: Border(
            top: BorderSide(
              width: 1.0,
              color:
              Theme.of(context).colorScheme.onBackground.withOpacity(0.3),
            ),
            left: BorderSide(
              width: 1.0,
              color:
              Theme.of(context).colorScheme.onBackground.withOpacity(0.3),
            ),
          ),
        ),
        'thead': Style(
          backgroundColor: Theme.of(context).colorScheme.background,
        ),
        'th': Style(
          padding: const EdgeInsets.only(left: 3, right: 3),
        ),
        'td': Style(
          padding: const EdgeInsets.all(4.0),
          alignment: Alignment.center,
          textAlign: TextAlign.center,
        ),
        'blockquote': Style(
            margin: Margins.zero,
            padding: EdgeInsets.zero,
          // lineHeight: LineHeight.normal
        ),
      },
    );
  }

  // a标签webview跳转
  void openHrefByWebview(String? aUrl, BuildContext context) async {
    if (aUrl!.contains('base64Wechat')) {
      Clipboard.setData(ClipboardData(text: aUrl.split(':')[1]));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(milliseconds: 3000),
          // showCloseIcon: true,
          content: Text('已复制【${aUrl.split(':')[1]}】'),
        ),
      );
      return;
    }
    RegExp exp = RegExp(
        r"((https?:www\.)|(https?:\/\/)|(www\.))[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9]{1,6}(\/[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)?");
    bool isValidator = exp.hasMatch(aUrl!);
    if (isValidator) {
      // http(s) 网址
      if (aUrl.startsWith('www.v2ex.com/') ||
          aUrl.startsWith('https://v2ex.com') ||
          aUrl.startsWith('https://www.v2ex.com')) {
        // v2ex 链接 https://www.v2ex.com/t/919475#reply1
        List arr = aUrl.split('.com');
        // 获得链接 /t/919475#reply1
        var tHref = arr[1];
        if (tHref.startsWith('/t') ||
            tHref.startsWith('/go') ||
            tHref.startsWith('/member')) {
          if (tHref.contains('#')) {
            // 去掉回复数  /t/919475#reply1
            // 获得链接 /t/919475
            tHref = arr[1].split('#')[0];
          }
          Get.toNamed(tHref);
        } else {
          Utils.openURL(aUrl);
        }
      } else {
        await Utils.openURL(aUrl);
      }
    } else if (aUrl.startsWith('/member/') ||
        aUrl.startsWith('/go/') ||
        aUrl.startsWith('/t/')) {
      if (aUrl.contains('#')) {
        aUrl = aUrl.split('#')[0];
      }
      Get.toNamed(aUrl);
    } else {
      // sms tel email schemeUrl
      final Uri _url = Uri.parse(aUrl);
      if (await canLaunchUrl(_url)) {
        launchUrl(_url);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(milliseconds: 3000),
            // showCloseIcon: true,
            content: const Text('🔗链接打开失败'),
            action: SnackBarAction(
              label: '复制',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: aUrl));
              },
            ),
          ),
        );
        throw Exception('Could not launch $aUrl');
      }
    }
  }
}
