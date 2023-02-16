import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_v2ex/pages/page_webView.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/idea.dart';

// import 'package:flutter_v2ex/pages/profile_page.dart';
import 'package:flutter_v2ex/utils/utils.dart';
import 'package:extended_image/extended_image.dart';

// import 'package:flutter_html_all/flutter_html_all.dart';
// import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:flutter_v2ex/pages/page_preview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_html_iframe/flutter_html_iframe.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/services.dart';

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
  final ChromeSafariBrowser browser = MyChromeSafariBrowser();

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
        // 1. openWithSystemBrowser
        // await InAppBrowser.openWithSystemBrowser(
        //     url: WebUri(aUrl)
        // );

        // 2. openWithAppBrowser
        await browser.open(
          url: WebUri(aUrl),
          settings: ChromeSafariBrowserSettings(
              shareState: CustomTabsShareState.SHARE_STATE_OFF,
              isSingleInstance: false,
              isTrustedWebActivity: false,
              keepAliveEnabled: true,
              startAnimations: [
                AndroidResource.anim(
                    name: "slide_in_left", defPackage: "android"),
                AndroidResource.anim(
                    name: "slide_out_right", defPackage: "android")
              ],
              exitAnimations: [
                AndroidResource.anim(
                    name: "abc_slide_in_top",
                    defPackage:
                        "com.pichillilorenzo.flutter_inappwebviewexample"),
                AndroidResource.anim(
                    name: "abc_slide_out_top",
                    defPackage:
                        "com.pichillilorenzo.flutter_inappwebviewexample")
              ],
              dismissButtonStyle: DismissButtonStyle.CLOSE,
              presentationStyle: ModalPresentationStyle.OVER_FULL_SCREEN),
        );
      }
    } else if (aUrl.startsWith('/member/') ||
        aUrl.startsWith('/go/') ||
        aUrl.startsWith('/t/')) {
      Get.toNamed(aUrl);
    } else {
      // sms tel email schemeUrl
      final Uri _url = Uri.parse(aUrl);
      if (!await launchUrl(_url)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(showCloseIcon: true, content: Text('无效网址')),
        );
        throw Exception('Could not launch $aUrl');
      }
    }
  }
}

// 初始化
class MyChromeSafariBrowser extends ChromeSafariBrowser {
  @override
  void onOpened() {
    print("ChromeSafari browser opened");
  }

  @override
  void onCompletedInitialLoad(didLoadSuccessfully) {
    print("ChromeSafari browser initial load completed");
  }

  @override
  void onClosed() {
    print("ChromeSafari browser closed");
  }
}
