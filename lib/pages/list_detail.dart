import 'package:flutter/material.dart';
import 'package:flutter_v2ex/http/dio_web.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter_v2ex/components/detail/bottom_bar.dart';
import 'package:flutter_v2ex/components/detail/reply_item.dart';
import 'package:flutter_v2ex/components/common/avatar.dart';

import 'package:flutter_v2ex/models/web/item_tab_topic.dart';
import 'package:flutter_v2ex/models/web/model_topic_detail.dart';
import 'package:flutter_v2ex/models/web/item_topic_reply.dart';
import 'package:flutter_v2ex/components/detail/html_render.dart';

enum SampleItem { itemOne, itemTwo, itemThree }

class ListDetail extends StatefulWidget {
  const ListDetail({this.topic, required this.topicId, super.key});
  final TabTopicItem? topic;
  final String topicId;

  @override
  State<ListDetail> createState() => _ListDetailState();
}

class _ListDetailState extends State<ListDetail> with TickerProviderStateMixin {
  late EasyRefreshController _controller;
  // 监听页面滚动
  final ScrollController _scrollController = ScrollController();
  // 动画
  late AnimationController _aniController;
  late Animation<double> btmAnimation;
  late Animation<double> fabAnimation;

  // action
  bool onlyOP = false; // 只看楼主
  bool reverseSort = false; // 倒序
  bool showToTopBtn = false; // 返回顶部
  bool showFabBtn = false; // 返回顶部
  late double lastOffset = 0;
  late double pbOffset = 30;

  // late Future<TopicDetailModel>? _detailModel;
  // init
  TopicDetailModel? _detailModel;
  // 回复列表
  late List<ReplyItem> _replyList = [];
  // 总页数
  int _totalPage = 0;
  // easy Refresh config
  final _MIProperties _headerProperties = _MIProperties(name: 'Header');
  final _CIProperties _footerProperties = _CIProperties(
    name: 'Footer',
    disable: true,
    alignment: MainAxisAlignment.start,
    infinite: true,
  );

  @override
  void initState() {
    super.initState();
    _controller = EasyRefreshController(
      controlFinishRefresh: true,
      controlFinishLoad: true,
    );

    _aniController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    //使用弹性曲线
    btmAnimation =
        CurvedAnimation(parent: _aniController, curve: Curves.bounceInOut);
    btmAnimation =
        Tween(begin: -80.0 - pbOffset, end: 0.0).animate(_aniController)
          ..addListener(() {
            setState(() => {});
          })
          ..addStatusListener(
            (status) => {
              if (status == AnimationStatus.completed)
                {
                  setState(() => {showToTopBtn = true})
                },
              if (status == AnimationStatus.dismissed)
                {
                  setState(() => {showToTopBtn = false})
                }
            },
          );
    fabAnimation =
        CurvedAnimation(parent: _aniController, curve: Curves.bounceInOut);
    fabAnimation = Tween(begin: 10.0, end: 16.0).animate(_aniController)
      ..addListener(() {
        setState(() => {});
      })
      ..addStatusListener(
        (status) => {
          if (status == AnimationStatus.completed)
            {
              setState(() => {showFabBtn = true})
            },
          if (status == AnimationStatus.dismissed)
            {
              setState(() => {showFabBtn = false})
            }
        },
      );

    //监听滚动事件，打印滚动位置
    // _scrollController.addListener(() {
    //   var offset = _scrollController.offset;
    //   if (offset > lastOffset && showToTopBtn) {
    //     _aniController.reverse();
    //   }
    //   if (offset < lastOffset && !showToTopBtn) {
    //     _aniController.forward();
    //   }
    //   setState(() {
    //     lastOffset = offset;
    //   });
    // });
    getDetail();
  }

  Future getDetail() async {
    TopicDetailModel topicDetailModel =
        await DioRequestWeb.getTopicDetail(widget.topicId, _totalPage + 1);
    setState(() {
      _detailModel = topicDetailModel;
      if (_totalPage == 0) {
        _replyList = topicDetailModel.replyList;
      } else {
        _replyList.addAll(topicDetailModel.replyList);
      }
      _totalPage = topicDetailModel.totalPage;
    });
  }

  void animationStart() {
    if (!showToTopBtn) {
      _aniController.forward();
    } else {
      _aniController.reverse();
    }
  }

  @override
  void dispose() {
    _aniController.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SampleItem? selectedMenu;

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
          // IconButton(
          //   onPressed: (() => {}),
          //   icon: const Icon(Icons.more_vert),
          // ),
          PopupMenuButton<SampleItem>(
            tooltip: 'action',
            initialValue: selectedMenu,
            color: Theme.of(context).colorScheme.background,
            // Callback that sets the selected popup menu item.
            onSelected: (SampleItem item) {
              setState(() {
                selectedMenu = item;
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<SampleItem>>[
              const PopupMenuItem<SampleItem>(
                value: SampleItem.itemThree,
                child: Text('分享'),
              ),
              PopupMenuItem<SampleItem>(
                value: SampleItem.itemThree,
                child: Text(
                  '举报',
                  style: TextStyle(
                      color:
                          Theme.of(context).colorScheme.error.withAlpha(200)),
                ),
              ),
              const PopupMenuDivider(height: 2),
              const PopupMenuItem<SampleItem>(
                value: SampleItem.itemThree,
                child: Text('在浏览器中打开'),
              ),
            ],
          ),
        ],
        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
      ),
      body: _detailModel != null
          ? Stack(
              children: [
                EasyRefresh(
                  clipBehavior: Clip.none,
                  controller: _controller,
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
                    triggerOffset: 100,
                  ),
                  // 下拉
                  onRefresh: () async {
                    setState(() {
                      _totalPage = 0;
                    });
                    await getDetail();
                    _controller.finishRefresh();
                    _controller.resetFooter();
                  },
                  // 上拉
                  onLoad: _detailModel!.totalPage > 1
                      ? () async {
                          // await Future.delayed(const Duration(seconds: 2), () {});
                          await getDetail();
                          _controller.finishLoad();
                          _controller.resetFooter();
                          return IndicatorResult.noMore;
                        }
                      : null,
                  // onRefresh: null,
                  // onLoad: null,
                  child: showRes(),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: btmAnimation.value,
                  child: DetailBottomBar(
                    onRefresh: onRefreshBtm,
                    onLoad: () => _controller.callLoad(),
                  ),
                ),
                Positioned(
                  right: 16,
                  bottom: MediaQuery.of(context).padding.bottom +
                      fabAnimation.value,
                  child: FloatingActionButton(
                    onPressed: animationStart,
                    child: const Icon(Icons.edit),
                  ),
                ),
              ],
            )
          : showLoading(),
    );
  }

  Widget showRes() {
    return CustomScrollView(
      controller: _scrollController,
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
                          child: CAvatar(
                            url: _detailModel!.avatar,
                            size: 42,
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
                  if (_detailModel!.favoriteCount > 0) ...[
                    Text(
                      '${_detailModel!.favoriteCount}人收藏',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(width: 16),
                  ],
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
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                child: HtmlRender(htmlContent: _detailModel!.contentRendered),
              ),
              if (_detailModel!.content.isNotEmpty) ...[
                const Divider(
                  endIndent: 15,
                  indent: 15,
                ),
              ]
            ],
          ),
        ),
        if (_replyList.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Container(
                padding: const EdgeInsets.only(
                    top: 0, left: 15, bottom: 20, right: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_detailModel!.replyCount}条回复',
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
        // const SliverToBoxAdapter(child: SizedBox(height: 100))
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

  Future onRefreshBtm() async {
    await _scrollController.animateTo(0,
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeOutBack);
    return _controller.callRefresh();
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
