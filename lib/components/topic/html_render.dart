import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_html_table/flutter_html_table.dart';
import 'package:flutter_v2ex/utils/string.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_v2ex/utils/utils.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_iframe/flutter_html_iframe.dart';
import 'package:flutter_v2ex/components/common/image_loading.dart';

// ignore: must_be_immutable
class HtmlRender extends StatelessWidget {
  String? htmlContent;
  final int? imgCount;
  final List? imgList;
  final double? fs;

  HtmlRender(
      {this.htmlContent, this.imgCount, this.imgList, this.fs, super.key});

  @override
  Widget build(BuildContext context) {
    return Html(
      data: htmlContent,
      // tagsList: Html.tags..addAll(["form", "label", "input"]),
      onLinkTap: (url, buildContext, attributes) =>
          {Utils.openHrefByWebview(url!, context)},

      extensions: [
        // TagExtension(
        //   tagsToExtend: {"iframe"},
        //   builder: (extensionContext) {
        //     return iframeRender();
        //   },
        // ),
        //           IframeHtmlExtension(
        //   navigationDelegate: (request) {
        //     //Return decision here
        //     return Text('123');
        //   },
        // ),
        // TagExtension(
        //   tagsToExtend: {"table"},
        //   builder: (extensionContext) {
        //     return SingleChildScrollView(
        //       scrollDirection: Axis.horizontal,
        //       child:
        //           tableRender.call().widget!.call(extensionContext, buildChildren),
        //     );
        //   },
        // ),
        const IframeHtmlExtension(),
        const TableHtmlExtension(),
        TagExtension(
          tagsToExtend: {"img"},
          builder: (extensionContext) {
            String? imgUrl = extensionContext.attributes['src'];
            imgUrl = Utils().imageUrl(imgUrl!);
            // ignore: avoid_print
            // todo 多张图片轮播
            return SelectionContainer.disabled(
              child: Strings.coolapkEmoticon.values.contains(imgUrl)
                  ? SizedBox(
                      width: 28,
                      height: 28,
                      child: ImageLoading(
                        imgUrl: imgUrl,
                      ),
                    )
                  : GestureDetector(
                      onTap: () {
                        Map<dynamic, dynamic> arguments = {
                          "imgList": imgList!,
                          "initialPage": imgList!.indexOf(imgUrl),
                        };
                        Get.toNamed('/imgPreview', arguments: arguments);
                      },
                      child: Container(
                        clipBehavior: Clip.hardEdge,
                        // margin: const EdgeInsets.only(top: 4, bottom: 4),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4)),
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
                          quality: 'preview',
                        ),
                      ),
                    ),
            );
          },
        ),
        TagExtension(
            tagsToExtend: {"pre"},
            builder: (extensionContext) {
              return Container(
                margin: const EdgeInsets.only(top: 10, bottom: 10),
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Theme.of(context).colorScheme.onInverseSurface,
                    border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.3))),
                child: Html(data: extensionContext.innerHtml),
              );
            }),
        TagExtension(
            tagsToExtend: {"input"},
            builder: (extensionContext) {
              switch (extensionContext.attributes["type"]) {
                case "text":
                  return TextField(
                      controller: TextEditingController(
                          text: extensionContext.attributes["value"]));
                case "checkbox":

                  /// TODO 渲染多选框
                  // return Checkbox(
                  //     value:
                  //         extensionContext.attributes["checked"] == "checked",
                  //     onChanged: null);
                  return SizedBox();
                default:
                  return extensionContext.parser;
              }
            })
      ],
      style: {
        "html": Style(
          fontSize: fs != null ? FontSize(fs!) : FontSize.medium,
          lineHeight: LineHeight.percent(140),
        ),
        "body": Style(margin: Margins.zero, padding: HtmlPaddings.zero),
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
          padding: HtmlPaddings.only(bottom: 4),
          textAlign: TextAlign.justify,
        ),
        "image": Style(margin: Margins.only(top: 4, bottom: 4)),
        "p > img": Style(margin: Margins.only(top: 4, bottom: 4)),
        "code": Style(
            backgroundColor: Theme.of(context).colorScheme.onInverseSurface),
        "code > span": Style(textAlign: TextAlign.start),
        "hr": Style(
          margin: Margins.zero,
          padding: HtmlPaddings.zero,
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
          padding: HtmlPaddings.only(left: 3, right: 3),
        ),
        'td': Style(
          padding: HtmlPaddings.all(4.0),
          alignment: Alignment.center,
          textAlign: TextAlign.center,
        ),
        'blockquote': Style(
          margin: Margins.zero,
          padding: HtmlPaddings.zero,
          // lineHeight: LineHeight.normal
        ),
      },
    );
  }
}
