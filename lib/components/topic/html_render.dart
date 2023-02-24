import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_v2ex/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_v2ex/pages/page_preview.dart';
import 'package:flutter_html_iframe/flutter_html_iframe.dart';
import 'package:cached_network_image/cached_network_image.dart';

// ignore: must_be_immutable
class HtmlRender extends StatefulWidget {
  String? htmlContent;
  final int? imgCount;
  final List? imgList;

  HtmlRender({this.htmlContent, this.imgCount, this.imgList, super.key});

  @override
  _HtmlRenderState createState() => _HtmlRenderState();
}

class _HtmlRenderState extends State<HtmlRender> {

  @override
  void initState() {
    // rootBundle.load('assets/images/flutter-logo.png').then((actionButtonIcon) {
    //   browser.setActionButton(ChromeSafariBrowserActionButton(
    //       id: 1,
    //       description: 'Action Button description',
    //       icon: actionButtonIcon.buffer.asUint8List(),
    //       onClick: (url, title) {
    //         print('Action Button 1 clicked!');
    //         print(url);
    //         print(title);
    //       }));
    // });

    // browser.addMenuItem(ChromeSafariBrowserMenuItem(
    //     id: 2,
    //     label: 'Custom item menu 1',
    //     image: UIImage(systemName: "sun.max"),
    //     onClick: (url, title) {
    //       print('Custom item menu 1 clicked!');
    //       print(url);
    //       print(title);
    //     }));
    // browser.addMenuItem(ChromeSafariBrowserMenuItem(
    //     id: 3,
    //     label: 'Custom item menu 2',
    //     image: UIImage(systemName: "pencil"),
    //     onClick: (url, title) {
    //       print('Custom item menu 2 clicked!');
    //       print(url);
    //       print(title);
    //     }));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Html(
      data: widget.htmlContent,
      onLinkTap: (url, buildContext, attributes, element) =>
          {openHrefByWebview(url!, context)},
      customRenders: {
        tagMatcher("iframe"): iframeRender(),
        tagMatcher("img"): CustomRender.widget(
          widget: (htmlContext, buildChildren) {
            String? imgUrl = htmlContext.tree.element!.attributes['src'];
            imgUrl = Utils().imageUrl(imgUrl!);
            // ignore: avoid_print
            print(imgUrl);
            // todo 多张图片轮播
            return SelectionContainer.disabled(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ImagePreview(
                          imgList: widget.imgList!,
                          initialPage: widget.imgList!.indexOf(imgUrl)),
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
                      // width: double.infinity,
                      // fit: BoxFit.fitHeight,
                      fadeOutDuration: const Duration(milliseconds: 500),
                      placeholder: (htmlContext, url) {
                        return Container(
                          width: double.infinity,
                          height: 60,
                          color: Theme.of(context).colorScheme.onInverseSurface,
                          child: const Center(
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
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
        ),
        "code > span": Style(textAlign: TextAlign.start)
      },
    );
  }

  // a标签webview跳转
  void openHrefByWebview(String? aUrl, BuildContext context) async {
    RegExp exp = RegExp(r"((https?:www\.)|(https?:\/\/)|(www\.))[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9]{1,6}(\/[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)?");
    bool isValidator = exp.hasMatch(aUrl!);
    if (isValidator) {
      // http(s) 网址
      if (aUrl.startsWith('www.v2ex.com/') ||
          aUrl.startsWith('https://v2ex.com') ||
          aUrl.startsWith('https://www.v2ex.com')) {
        // v2ex 链接
        List arr = aUrl.split('.com');
        var tHref = arr[1];
        if (arr[1].contains('#')) {
          tHref = arr[1].split('#')[0];
        }
        Get.toNamed(tHref);
      } else {
        await Utils.openURL(aUrl);
      }
    } else if (aUrl.startsWith('/member/') ||
        aUrl.startsWith('/go/') ||
        aUrl.startsWith('/t/')) {
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
