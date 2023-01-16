import 'package:flutter/material.dart';
import 'package:flutter_v2ex/http/dio_web.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'package:flutter_v2ex/components/detail/bottom_bar.dart';
import 'package:flutter_v2ex/components/detail/reply_item.dart';
import 'package:flutter_v2ex/components/common/avatar.dart';

import 'package:flutter_v2ex/models/web/item_tab_topic.dart';
import 'package:flutter_v2ex/models/web/model_topic_detail.dart';
import 'package:flutter_v2ex/models/web/item_topic_reply.dart';
import 'package:flutter_v2ex/components/detail/html_render.dart';
import 'package:flutter_v2ex/components/common/pull_refresh.dart';
import 'package:flutter_v2ex/components/detail/reply_new.dart';

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

  TopicDetailModel? _detailModel;
  late List<ReplyItem> _replyList = []; // 回复列表
  int _totalPage = 1; // 总页数
  int _currentPage = 0; // 当前页数

  // action
  bool reverseSort = false; // 倒序
  bool isLoading = false; // 请求状态 正序/倒序

  // bool _showFab = true;
  // bool _isElevated = true;
  bool _isVisible = true;

  SampleItem? selectedMenu;
  FloatingActionButtonLocation get _fabLocation => _isVisible
      ? FloatingActionButtonLocation.endContained
      : FloatingActionButtonLocation.endFloat;

  @override
  void initState() {
    super.initState();
    _controller = EasyRefreshController(
      controlFinishRefresh: true,
      controlFinishLoad: true,
    );
    _scrollController.addListener(_listen);
    getDetailInit();
  }

  Future getDetailInit() async {
    getDetail(type: 'init');
  }

  Future getDetail({type}) async {
    if (type == 'init') {
      setState(() {
        _currentPage = 0;
      });
    }
    TopicDetailModel topicDetailModel =
        await DioRequestWeb.getTopicDetail(widget.topicId, _currentPage + 1);
    setState(() {
      _detailModel = topicDetailModel;
      if (_currentPage == 0) {
        _replyList = topicDetailModel.replyList;
        _totalPage = topicDetailModel.totalPage;
      } else {
        _replyList.addAll(topicDetailModel.replyList);
      }
      _currentPage += 1;
    });
  }

  // todo 下拉刷新逻辑优化  正倒序排列数据复用
  Future getDetailReverst({type}) async {
    if (type == 'init') {
      setState(() {
        _currentPage = _totalPage;
      });
    }
    if (!reverseSort || _currentPage == 0) {
      return;
    }
    print('line 155: $_currentPage');
    TopicDetailModel topicDetailModel =
        await DioRequestWeb.getTopicDetail(widget.topicId, _currentPage);
    setState(() {
      if (_currentPage == _totalPage) {
        _replyList = topicDetailModel.replyList.reversed.toList();
        _totalPage = topicDetailModel.totalPage;
      } else {
        _replyList.addAll(topicDetailModel.replyList.reversed);
      }
      _currentPage -= 1;
    });
  }

  // 返回顶部并 todo 刷新
  Future onRefreshBtm() async {
    await _scrollController.animateTo(0,
        duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    return _controller.callRefresh();
  }

  void _listen() {
    final ScrollDirection direction =
        _scrollController.position.userScrollDirection;
    if (direction == ScrollDirection.forward) {
      _show();
    } else if (direction == ScrollDirection.reverse) {
      _hide();
    }
  }

  void _show() {
    if (!_isVisible) {
      setState(() => _isVisible = true);
    }
  }

  void _hide() {
    if (_isVisible) {
      setState(() => _isVisible = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.removeListener(_listen);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var statusHeight = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
      appBar: AppBar(
        actions: appBarAction(),
        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
      ),
      body: _detailModel != null
          ? PullRefresh(
              onChildRefresh: getDetailInit,
              // 上拉
              onChildLoad: !reverseSort
                  ? (_totalPage > 1 && _currentPage < _totalPage
                      ? getDetail
                      : null)
                  : (_currentPage > 1 ? getDetailReverst : null),
              currentPage: _currentPage,
              totalPage: _totalPage,
              child: showRes(),
            )
          : showLoading(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            builder: (BuildContext context) {
              return ReplyNew(statusHeight: statusHeight);
            },
          );
        },
        tooltip: '回复',
        child: const Icon(Icons.edit),
      ),
      // floatingActionButtonAnimator: _favAnimation,
      floatingActionButtonLocation: _fabLocation,
      bottomNavigationBar:
          DetailBottomBar(onRefresh: onRefreshBtm, isVisible: _isVisible),
    );
  }

  // 顶部操作栏
  List<Widget> appBarAction() {
    List<Widget>? list = [];
    // list.add(
    //   IconButton(
    //     onPressed: (() => {}),
    //     tooltip: '刷新主题',
    //     icon: const Icon(Icons.refresh_sharp),
    //   ),
    // );
    list.add(
      IconButton(
        onPressed: (() => {}),
        tooltip: '收藏主题',
        icon: const Icon(Icons.star_border),
      ),
    );
    list.add(
      IconButton(
        onPressed: (() =>
            Clipboard.setData(ClipboardData(text: _detailModel!.topicId))),
        tooltip: '使用浏览器打开',
        icon: const Icon(Icons.copy_rounded),
      ),
    );
    list.add(
      PopupMenuButton<SampleItem>(
        tooltip: 'action',
        initialValue: selectedMenu,
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
                  color: Theme.of(context).colorScheme.error.withAlpha(200)),
            ),
          ),
          const PopupMenuDivider(height: 2),
          const PopupMenuItem<SampleItem>(
            value: SampleItem.itemThree,
            child: Text('在浏览器中打开'),
          ),
        ],
      ),
    );
    return list;
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
                            size: 45,
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
                                  ? Text(_detailModel!.createdTime,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall!
                                          .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .outline))
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
                  style: Theme.of(context).textTheme.titleMedium,
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
                  const SizedBox(width: 20)
                ],
              ),
              const SizedBox(height: 10),
              Divider(
                endIndent: 15,
                indent: 15,
                color: Theme.of(context).dividerColor.withOpacity(0.15),
              ),
              Container(
                padding: const EdgeInsets.only(
                    top: 5, right: 10, bottom: 0, left: 10),
                child: HtmlRender(htmlContent: _detailModel!.contentRendered),
              ),

              ListView.builder(
                shrinkWrap: true,
                itemCount: _detailModel!.subtleList.length,
                itemBuilder: (context, index) => Column(
                  children: [
                    Divider(
                      endIndent: 15,
                      indent: 15,
                      color: Theme.of(context).dividerColor.withOpacity(0.15),
                    ),
                    HtmlRender(
                        htmlContent: _detailModel!.subtleList[index].content)
                  ],
                ),
              ),
              if (_detailModel!.content.isNotEmpty) ...[
                Divider(
                  endIndent: 15,
                  indent: 15,
                  height: 25,
                  color: Theme.of(context).dividerColor,
                ),
              ]
            ],
          ),
        ),
        if (_replyList.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Container(
                padding: const EdgeInsets.only(
                    top: 20, left: 15, bottom: 14, right: 15),
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
                              if (reverseSort) {
                                getDetailReverst(type: 'init');
                              } else {
                                getDetail(type: 'init');
                              }
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
        // 回复列表
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return ReplyListItem(reply: _replyList[index]);
            },
            childCount: _replyList.length,
          ),
        ),
        // 没有更多
        SliverToBoxAdapter(
          child: Offstage(
            // when true hidden
            offstage: _detailModel!.replyCount != '0',
            child: moreTopic(type: 'null'),
          ),
        ),
        // 加载更多
        SliverToBoxAdapter(
          child: Offstage(
            // when true hidden
            offstage: _detailModel!.replyCount == '0' ||
                (!reverseSort && (_totalPage - 1 == _currentPage)) ||
                (reverseSort && (_currentPage > 1)),
            child: moreTopic(),
          ),
        )
      ],
    );
  }

  // 底部 没有更多
  Widget moreTopic({type = 'noMore'}) {
    return Container(
      width: double.infinity,
      height: 80 + MediaQuery.of(context).padding.bottom,
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 5),
      child: Center(
        // child: TextField(),
        child: Text(type == 'noMore' ? '没有更多回复了' : '还没有人回复'),
      ),
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
