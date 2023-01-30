import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_v2ex/http/dio_web.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter_v2ex/components/detail/bottom_bar.dart';
import 'package:flutter_v2ex/components/detail/reply_item.dart';
import 'package:flutter_v2ex/components/common/avatar.dart';

import 'package:flutter_v2ex/models/web/model_topic_detail.dart';

class ListDetail extends StatefulWidget {
  const ListDetail({this.topicId = '1', super.key});

  final String topicId;

  @override
  State<ListDetail> createState() => _ListDetailState();
}

class _ListDetailState extends State<ListDetail> {
  late EasyRefreshController _controller;

  // late Future<TopicDetailModel>? _detailModel;
  TopicDetailModel? _detailModel;
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

    // _detailModel = getDetail();
    getDetail();
  }

  // Future<TopicDetailModel> getDetail() async {
  //   return await DioRequestWeb.getTopicDetail(widget.topicId, 0);
  // }
  Future getDetail() async {
    TopicDetailModel topicDetailModel =
        await DioRequestWeb.getTopicDetail(widget.topicId, 0);
    setState(() {
      _detailModel = topicDetailModel;
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
        title: const Text('详情', style: TextStyle(fontSize: 15)),
        actions: [
          IconButton(
            onPressed: (() => {}),
            icon: const Icon(Icons.more_vert),
          ),
        ],
        shadowColor: Theme.of(context).colorScheme.shadow.withAlpha(100),
        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
      ),
      body: _detailModel != null
          ? Stack(
              children: [
                EasyRefresh(
                  // clipBehavior: Clip.none,
                  // controller: _controller,
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
                  onRefresh: () async {
                    await Future.delayed(const Duration(seconds: 5));
                    if (!mounted) {
                      return;
                    }

                    _controller.finishRefresh();
                    _controller.resetFooter();
                  },
                  // 上拉
                  // onLoad: () async {
                  //   await Future.delayed(const Duration(seconds: 2), () {});
                  //   _controller.finishLoad();
                  //   _controller.resetFooter();
                  //   return IndicatorResult.noMore;
                  // },
                  onLoad: null,
                  // child: FutureBuilder<TopicDetailModel>(
                  //   future: _detailModel,
                  //   builder: (context, snapshot) {
                  //     Widget widget;
                  //     if (snapshot.connectionState == ConnectionState.done) {
                  //       if (snapshot.hasError) {
                  //         widget = const Text('topic detail Request Error');
                  //       } else {
                  //         widget = showRes(snapshot);
                  //       }
                  //     } else {
                  //       widget = showLoading();
                  //     }
                  //     return widget;
                  //   },
                  // ),
                  child: showRes(_detailModel),
                ),
                // const Positioned(
                //   left: 0,
                //   right: 0,
                //   bottom: 0,
                //   child: DetailBottomBar(),
                // ),
              ],
            )
          : showLoading(),
    );
  }

  Widget showRes(snapshot) {
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
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
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
                      children: [
                        Container(
                          color: null,
                          child: Text(
                            snapshot.createdId,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: const TextStyle(
                              fontSize: 14.0,
                              height: 1.5,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        Text(
                          snapshot.createdTime,
                          style: const TextStyle(
                            fontSize: 10.0,
                            height: 1.3,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.only(
                    top: 0, right: 18, bottom: 0, left: 18),
                child: Row(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.visibility_outlined,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(snapshot.visitorCount)
                      ],
                    ),
                    const SizedBox(width: 14),
                    Row(
                      children: [
                        const Icon(Icons.sms_outlined, size: 18),
                        const SizedBox(width: 4),
                        Text(snapshot.replyCount),
                      ],
                    )
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                // decoration: BoxDecoration(border: Border.all()),
                padding: const EdgeInsets.only(
                    top: 12, right: 18, bottom: 4, left: 18),
                child: Text(
                  snapshot.topicTitle,
                  style: const TextStyle(fontSize: 15.5, height: 1.5),
                ),
              ),
              const Divider(
                endIndent: 15,
                indent: 15,
              ),
              Html(
                data: snapshot.contentRendered,
                style: {
                  "html": Style(
                    fontSize: FontSize(14),
                    textAlign: TextAlign.justify,
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
                },
              ),
              Container(
                padding: const EdgeInsets.only(
                    top: 20, right: 25, bottom: 9, left: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () {},
                      child: Row(
                        children: const [
                          Icon(Icons.thumb_up_outlined),
                          SizedBox(width: 4),
                          Text('赞 999')
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    OutlinedButton(
                        onPressed: () {},
                        child: Row(
                          children: const [
                            Icon(Icons.star_border),
                            SizedBox(width: 4),
                            Text('收藏')
                          ],
                        )),
                  ],
                ),
              ),
              const Divider(
                endIndent: 15,
                indent: 15,
              ),
            ],
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return ReplyListItem(
                reply: snapshot.replyList![index],
                topicId: _detailModel!.topicId,
              );
            },
            childCount: snapshot.replyList.length,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 80))
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
