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
import 'package:flutter_v2ex/components/common/node_tag.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_v2ex/pages/tabs/mine_page.dart';

enum SampleItem { itemOne, itemTwo, itemThree, itemFour }

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
    if (reverseSort) {
      SmartDialog.showLoading(msg: '请稍等...');
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
      // print('line 89---_totalPage---:$_totalPage');
      // print(reverseSort);
      // print(_totalPage);
      // print(_currentPage);
    });
    SmartDialog.dismiss();
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
    SmartDialog.showLoading(msg: '请稍等...');
    // print('line 155: $_currentPage');
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
      // print('---_totalPage---:$_totalPage');
    });
    SmartDialog.dismiss();
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
    return Stack(
      children: [
        Scaffold(
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
          floatingActionButtonLocation: _fabLocation,
          bottomNavigationBar: DetailBottomBar(
              onRefresh: onRefreshBtm,
              isVisible: _isVisible,
              detailModel: _detailModel),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.bounceIn,
          child: Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).padding.top,
              color: _isVisible
                  ? Theme.of(context).appBarTheme.foregroundColor
                  : Theme.of(context).colorScheme.background,
            ),
          ),
        ),
      ],
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
        onPressed: (() async {
          var res = await DioRequestWeb.favoriteTopic(
              _detailModel!.isFavorite, _detailModel!.topicId);
          if (res) {
            setState(() {
              _detailModel!.isFavorite = !_detailModel!.isFavorite;
            });
            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_detailModel!.isFavorite ? '已添加到收藏' : '已取消收藏'),
                duration: const Duration(milliseconds: 500),
                showCloseIcon: true,
              ),
            );
          }
        }),
        tooltip: '收藏主题',
        icon: const Icon(Icons.star_border),
        selectedIcon: Icon(
          Icons.star,
          color: Theme.of(context).colorScheme.primary,
        ),
        isSelected: _detailModel!.isFavorite,
      ),
    );
    // list.add(
    //   IconButton(
    //     onPressed: (() =>
    //         Clipboard.setData(ClipboardData(text: _detailModel!.topicId))),
    //     tooltip: '使用浏览器打开',
    //     icon: const Icon(Icons.copy_rounded),
    //   ),
    // );
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
          PopupMenuItem<SampleItem>(
            value: SampleItem.itemThree,
            onTap: () => {print('忽略主题')},
            // onTap: () => showDialog<String>(
            //   context: context,
            //   builder: (BuildContext context) => AlertDialog(
            //     title: const Text('提示'),
            //     content: const Text('确定不想再看到这个主题？'),
            //     actions: <Widget>[
            //       TextButton(
            //         onPressed: () => Navigator.pop(context, 'Cancel'),
            //         child: const Text('手误了'),
            //       ),
            //       TextButton(
            //         // onPressed: () => Navigator.pop(context, 'OK'),
            //         onPressed: (() async {
            //           var res = await DioRequestWeb.ignoreTopic(
            //               _detailModel!.topicId);
            //           if (res) {
            //             // ignore: use_build_context_synchronously
            //             Navigator.pop(context, 'OK');
            //             setState(() {
            //               _detailModel!.isThank = true;
            //             });
            //             // ignore: use_build_context_synchronously
            //             ScaffoldMessenger.of(context).showSnackBar(
            //               SnackBar(
            //                 content:
            //                     Text('已完成对 ${_detailModel!.topicId} 号主题的忽略'),
            //                 duration: const Duration(milliseconds: 500),
            //                 showCloseIcon: true,
            //               ),
            //             );
            //             // ignore: use_build_context_synchronously
            //           }
            //         }),
            //         child: const Text('确定'),
            //       ),
            //     ],
            //   ),
            // ),
            child: const Text('忽略主题'),
          ),
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
          const PopupMenuDivider(),
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
        SliverAppBar(
          pinned: false,
          floating: true,
          title: Text(_detailModel!.topicTitle),
          titleTextStyle: Theme.of(context).textTheme.titleMedium,
          actions: appBarAction(),
        ),
        SliverToBoxAdapter(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.only(
                    top: 20, right: 20, bottom: 22, left: 20),
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
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                MinePage(memberId: _detailModel!.createdId),
                              ));
                            },
                            child: CAvatar(
                              url: _detailModel!.avatar,
                              size: 45,
                            ),
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
                    NodeTag(
                        nodeId: _detailModel!.nodeId,
                        nodeName: _detailModel!.nodeName,
                        route: 'detail')
                  ],
                ),
              ),

              /// 主题标题
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(
                    top: 0, right: 18, bottom: 12, left: 18),
                child: Text(
                  _detailModel!.topicTitle,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(fontWeight: FontWeight.w500),
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
                    top: 5, right: 18, bottom: 10, left: 18),
                child: HtmlRender(htmlContent: _detailModel!.contentRendered),
              ),
              if (_detailModel!.subtleList.isNotEmpty) ...[
                ...subList(_detailModel!.subtleList)
              ],

              if (_detailModel!.content.isNotEmpty) ...[
                Divider(
                  endIndent: 15,
                  indent: 15,
                  height: 1,
                  color: Theme.of(context).dividerColor.withOpacity(0.15),
                ),
              ]
            ],
          ),
        ),
        if (_replyList.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Container(
                padding: const EdgeInsets.only(
                    top: 20, left: 15, bottom: 18, right: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_detailModel!.replyCount}条回复',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (_replyList.length > 2) ...[
                      Row(
                        children: [
                          RawChip(
                            side: BorderSide.none,
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
                            // backgroundColor:
                            //     Theme.of(context).colorScheme.surfaceVariant,
                            selectedColor:
                                Theme.of(context).colorScheme.onInverseSurface,
                            selected: reverseSort,
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
            // no reply hidden
            //
            offstage: _detailModel!.replyCount == '0' ||
                (!reverseSort && (_currentPage < _totalPage)) ||
                (reverseSort && (_currentPage > 1)),
            child: moreTopic(),
          ),
        )
      ],
    );
  }

  List<Widget> subList(data) {
    List<Widget>? list = [];
    for (var i in data) {
      list.add(
        Container(
          padding:
              const EdgeInsets.only(top: 4, left: 18, right: 18, bottom: 10),
          // color: Theme.of(context).colorScheme.onInverseSurface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Divider(
                height: 1,
                color: Theme.of(context).dividerColor.withOpacity(0.15),
              ),
              const SizedBox(
                height: 12,
              ),
              Text(
                i.fade,
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    color: Theme.of(context).colorScheme.onSecondary,
                    backgroundColor: Theme.of(context).colorScheme.secondary),
              ),
              const SizedBox(
                height: 10,
              ),
              HtmlRender(htmlContent: i.content)
            ],
          ),
        ),
      );
    }
    return list;
  }

  // 底部 没有更多
  Widget moreTopic({type = 'noMore'}) {
    return Container(
      width: double.infinity,
      height: 80 + MediaQuery.of(context).padding.bottom,
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 20),
      child: Center(
        // child: TextField(),
        child: Text(
          type == 'noMore' ? '没有更多回复了' : '还没有人回复',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
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
