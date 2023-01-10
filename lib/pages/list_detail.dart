import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_v2ex/http/dio_web.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter_v2ex/components/detail/bottom_bar.dart';
import 'package:flutter_v2ex/components/detail/reply_item.dart';
// import 'package:flutter_v2ex/components/common/avatar.dart';

import 'package:flutter_v2ex/models/web/item_tab_topic.dart';
import 'package:flutter_v2ex/models/web/model_topic_detail.dart';
import 'package:flutter_v2ex/models/web/item_topic_reply.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter_v2ex/pages/webview_page.dart';
// import 'package:flutter_v2ex/pages/list_detail.dart';

class ListDetail extends StatefulWidget {
  const ListDetail({this.topic, required this.topicId, super.key});
  final TabTopicItem? topic;
  final String topicId;

  @override
  State<ListDetail> createState() => _ListDetailState();
}

class _ListDetailState extends State<ListDetail> {
  late EasyRefreshController _controller;

  // action
  bool onlyOP = false; // 只看楼主
  bool reverseSort = false; // 倒序

  // late Future<TopicDetailModel>? _detailModel;
  TopicDetailModel? _detailModel;
  final List<ReplyItem> _replyList = [];
  int _totalPage = 0;
  final _MIProperties _headerProperties = _MIProperties(
    name: 'Header',
  );
  final _CIProperties _footerProperties = _CIProperties(
      name: 'Footer',
      disable: true,
      alignment: MainAxisAlignment.start,
      infinite: true);

  @override
  void initState() {
    super.initState();
    _controller = EasyRefreshController(
      controlFinishRefresh: true,
      controlFinishLoad: true,
    );

    getDetail();
  }

  Future getDetail() async {
    TopicDetailModel topicDetailModel =
        await DioRequestWeb.getTopicDetail(widget.topicId, _totalPage + 1);
    setState(() {
      _detailModel = topicDetailModel;
      _replyList.addAll(topicDetailModel.replyList);
      _totalPage = topicDetailModel.totalPage;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: (() => {}),
            icon: const Icon(Icons.refresh_sharp),
          ),
          IconButton(
            onPressed: (() => {}),
            icon: const Icon(Icons.star_border),
          ),
          IconButton(
            onPressed: (() => {}),
            icon: const Icon(Icons.more_vert),
          ),
        ],
        // shadowColor: Theme.of(context).colorScheme.shadow.withAlpha(100),
        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
      ),
      body: _detailModel != null
          ? Stack(
              children: [
                EasyRefresh(
                  header: MaterialHeader(
                    backgroundColor: ThemeData().canvasColor,
                    clamping: _headerProperties.clamping,
                    showBezierBackground: _headerProperties.background,
                    bezierBackgroundAnimation: _headerProperties.animation,
                    bezierBackgroundBounce: _headerProperties.bounce,
                    infiniteOffset: _headerProperties.infinite ? 100 : null,
                    springRebound: _headerProperties.listSpring,
                  ),
                  footer: ClassicFooter(
                    clamping: _footerProperties.clamping,
                    backgroundColor: _footerProperties.background
                        ? Theme.of(context).colorScheme.surfaceVariant
                        : null,
                    mainAxisAlignment: _footerProperties.alignment,
                    showMessage: _footerProperties.message,
                    showText: _footerProperties.text,
                    infiniteOffset: _footerProperties.infinite ? 70 : null,
                    triggerWhenReach: _footerProperties.immediately,
                    hapticFeedback: true,
                    dragText: 'Pull to load',
                    armedText: 'Release ready',
                    readyText: 'Loading...',
                    processingText: '加载中...',
                    succeededIcon: const Icon(Icons.auto_awesome),
                    processedText: '加载成功',
                    textStyle: const TextStyle(fontSize: 14),
                    noMoreText: '没有更多了',
                    noMoreIcon: const Icon(Icons.sentiment_dissatisfied_sharp),
                    failedText: '加载失败',
                    messageText: '上次更新 %T',
                  ),
                  // 下拉
                  // onRefresh: () async {
                  //   await getDetail();
                  //   _controller.finishRefresh();
                  //   _controller.resetFooter();
                  // },
                  // 上拉
                  // onLoad: () async {
                  //   // await Future.delayed(const Duration(seconds: 2), () {});
                  //   await getDetail();
                  //   _controller.finishLoad();
                  //   _controller.resetFooter();
                  //   return IndicatorResult.noMore;
                  // },
                  onRefresh: null,
                  onLoad: null,
                  child: showRes(),
                ),
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: DetailBottomBar(),
                ),
              ],
            )
          : showLoading(),
    );
  }

  Widget showRes() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.only(
                    top: 20, right: 20, bottom: 12, left: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          clipBehavior: Clip.antiAlias,
                          margin: const EdgeInsets.only(right: 10),
                          child: Image.network(
                            "https://desk-fd.zol-img.com.cn/t_s960x600c5/g6/M00/03/0E/ChMkKWDZLXSICljFAC1U9uUHfekAARQfgG_oL0ALVUO515.jpg",
                            fit: BoxFit.cover,
                            width: 42,
                            height: 42,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              _detailModel!.createdId,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            SizedBox(
                              height: 15,
                              child: _detailModel != null
                                  ? Text(
                                      _detailModel!.createdTime,
                                      style: const TextStyle(
                                        fontSize: 10.0,
                                        height: 1.3,
                                      ),
                                    )
                                  : null,
                            )
                          ],
                        ),
                      ],
                    ),
                    Material(
                      borderRadius: BorderRadius.circular(50),
                      color: Theme.of(context).appBarTheme.surfaceTintColor,
                      child: InkWell(
                        onTap: () {},
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 3.5, horizontal: 10),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                _detailModel!.nodeName,
                                style: const TextStyle(
                                  fontSize: 11.0,
                                  textBaseline: TextBaseline.ideographic,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              /// 主题标题
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(
                    top: 0, right: 18, bottom: 7, left: 18),
                child: Text(
                  _detailModel!.topicTitle,
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              ),

              /// action操作
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${_detailModel!.visitorCount}点击',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${_detailModel!.replyCount}回复',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(width: 16)
                ],
              ),

              const Divider(
                endIndent: 15,
                indent: 15,
              ),

              Html(
                data: _detailModel!.contentRendered,
                // tagsList: const ['span'],
                onLinkTap: (url, buildContext, attributes, element) =>
                    {openHrefByWebview(url!)},
                onImageTap: (String? url, RenderContext context,
                    Map<String, String> attributes, element) {
                  openImageDialog(url);
                  //open image in webview, or launch image in browser, or any other logic here
                },
                style: {
                  "html": Style(
                    fontSize: FontSize(14.5),
                    textAlign: TextAlign.justify,
                    lineHeight: const LineHeight(1.6),
                    padding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  ),
                  "a": Style(
                    color: Theme.of(context).colorScheme.primary,
                    textDecoration: TextDecoration.underline,
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
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.5)),
                  ),
                  "code > span": Style(textAlign: TextAlign.start)
                },
              ),
              // ignore: unnecessary_null_comparison
              if (_detailModel!.contentRendered != null) ...[
                const Divider(
                  endIndent: 15,
                  indent: 15,
                ),
              ]
              // Container(
              //   padding: const EdgeInsets.only(
              //       top: 20, right: 25, bottom: 9, left: 10),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.end,
              //     children: [
              //       OutlinedButton(
              //         onPressed: () {},
              //         child: Row(
              //           children: const [
              //             Icon(Icons.thumb_up_outlined),
              //             SizedBox(width: 4),
              //             Text('赞 999')
              //           ],
              //         ),
              //       ),
              //       const SizedBox(width: 14),
              //       OutlinedButton(
              //           onPressed: () {},
              //           child: Row(
              //             children: const [
              //               Icon(Icons.star_border),
              //               SizedBox(width: 4),
              //               Text('收藏')
              //             ],
              //           )),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
        if (_replyList.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Container(
                padding: const EdgeInsets.only(
                    top: 15, left: 15, bottom: 20, right: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_detailModel!.replyList.length}条回复',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(width: 6),
                    if (_replyList.length > 2) ...[
                      Row(
                        children: [
                          RawChip(
                            labelPadding:
                                const EdgeInsets.only(left: 1, right: 4),
                            label: Text(
                              '倒序查看',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            avatar: const Icon(
                              Icons.swap_vert,
                              size: 19,
                            ),
                            onPressed: () => setState(() {
                              reverseSort = !reverseSort;
                            }),
                            shape: StadiumBorder(
                                side: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceVariant)),
                            backgroundColor:
                                Theme.of(context).colorScheme.surfaceVariant,
                            selectedColor:
                                Theme.of(context).colorScheme.onInverseSurface,
                            selected: reverseSort,
                            showCheckmark: false,
                          ),
                        ],
                      )
                    ]
                  ],
                )),
          ),
        ],
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return ReplyListItem(reply: _replyList[index]);
            },
            childCount: _replyList.length,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100))
      ],
    );
  }

  Widget showLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          CircularProgressIndicator(
            strokeWidth: 3,
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  // a标签webview跳转
  void openHrefByWebview(String? aUrl) async {
    print(aUrl);
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
    }
  }

  // 打开大图预览
  void openImageDialog(String? imgUrl) {
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

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight > minHeight ? maxHeight : minHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

class _MIProperties {
  final String name;
  bool clamping = true;
  bool background = false;
  bool animation = false;
  bool bounce = false;
  bool infinite = false;
  bool listSpring = false;

  _MIProperties({
    required this.name,
  });
}

class _CIProperties {
  final String name;
  bool disable = false;
  bool clamping = false;
  bool background = false;
  MainAxisAlignment alignment;
  bool message = true;
  bool text = true;
  bool infinite;
  bool immediately = false;

  _CIProperties({
    required this.name,
    required this.alignment,
    required this.infinite,
    required disable,
  });
}
