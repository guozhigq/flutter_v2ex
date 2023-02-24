// ignore_for_file: avoid_print

import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_v2ex/http/dio_web.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/rendering.dart';

import 'package:flutter_v2ex/components/topic/bottom_bar.dart';
import 'package:flutter_v2ex/components/topic/reply_item.dart';
import 'package:flutter_v2ex/components/common/avatar.dart';

import 'package:flutter_v2ex/models/web/model_topic_detail.dart';
import 'package:flutter_v2ex/models/web/item_topic_reply.dart';
import 'package:flutter_v2ex/components/topic/html_render.dart';
import 'package:flutter_v2ex/components/common/pull_refresh.dart';
import 'package:flutter_v2ex/components/topic/reply_new.dart';
import 'package:flutter_v2ex/components/common/node_tag.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_v2ex/utils/utils.dart';
import 'package:flutter_v2ex/utils/event_bus.dart';
import 'package:flutter_v2ex/utils/storage.dart';
import 'dart:math';
import 'package:flutter_v2ex/components/topic/reply_sheet.dart';
import 'package:share_plus/share_plus.dart';

enum SampleItem { ignore, share, report, browse }

class TopicDetail extends StatefulWidget {
  const TopicDetail({super.key});

  @override
  State<TopicDetail> createState() => _TopicDetailState();
}

class _TopicDetailState extends State<TopicDetail>
    with TickerProviderStateMixin {
  // TabTopicItem? topic;
  String topicId = '';
  late EasyRefreshController _controller;

  // 待回复用户
  List replyMemberList = [];
  String heroTag = Random().nextInt(999).toString();

  // 监听页面滚动
  final ScrollController _scrollController = ScrollController();
  TopicDetailModel? _detailModel;
  late List<ReplyItem> _replyList = []; // 回复列表
  int _totalPage = 1; // 总页数
  int _currentPage = 0; // 当前页数
  final GlobalKey _globalKey = GlobalKey();
  GlobalKey listGlobalKey = GlobalKey();
  late StreamController<bool> aStreamC;

  // action
  bool reverseSort = false; // 倒序
  bool isLoading = false; // 请求状态 正序/倒序

  // bool _showFab = true;
  // bool _isElevated = true;
  bool _isVisible = true;
  bool floorReplyVisible = false;
  String myUserName = '';

  SampleItem? selectedMenu;

  FloatingActionButtonLocation get _fabLocation => _isVisible
      ? FloatingActionButtonLocation.endContained
      : FloatingActionButtonLocation.endFloat;

  bool expendAppBar = GStorage().getExpendAppBar();
  @override
  void initState() {
    super.initState();

    setState(() {
      topicId = Get.parameters['topicId']!;
      myUserName = GStorage().getUserInfo().isNotEmpty
          ? GStorage().getUserInfo()['userName']
          : '';
    });

    _controller = EasyRefreshController(
      controlFinishRefresh: true,
      controlFinishLoad: true,
    );

    // TODO build优化
    _scrollController.addListener(_listen);
    getDetailInit();

    EventBus().on('topicReply', (status) {
      print('eventON: $status');
      String msg = '回复成功';
      if (status == 'cancel') {
        msg = '取消回复';
      }
      if (status == 'fail') {
        msg = '回复失败';
      }
      if (status == 'succes') {
        msg = '回复成功';
      }
      SmartDialog.showToast(msg);
      if (status != 'success') return;
      ReplyItem item = GStorage().getReplyItem();
      if (mounted) {
        setState(() {
          _replyList.add(item);
        });
      }
    });

    aStreamC = StreamController<bool>();
  }

  Future getDetailInit() async {
    getDetail(type: 'init');
  }

  Future getDetail({type}) async {
    if (type == 'init') {
      setState(() {
        _currentPage = !reverseSort ? 0 : _totalPage;
      });
    }
    if (reverseSort) {
      SmartDialog.showLoading(msg: '加载中ing');
    }
    TopicDetailModel topicDetailModel =
        await DioRequestWeb.getTopicDetail(topicId, _currentPage + 1);
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
    SmartDialog.dismiss();
  }

  // todo 下拉刷新逻辑优化  正倒序排列数据复用
  Future getDetailReverst({type}) async {
    if (type == 'init') {
      setState(() {
        _currentPage = _totalPage;
      });
      SmartDialog.showLoading(msg: '加载中ing');
    }
    if (!reverseSort || _currentPage == 0) {
      return;
    }
    // print('line 155: $_currentPage');
    TopicDetailModel topicDetailModel =
        await DioRequestWeb.getTopicDetail(topicId, _currentPage);
    setState(() {
      if (_currentPage == _totalPage) {
        _replyList = topicDetailModel.replyList.reversed.toList();
        _totalPage = topicDetailModel.totalPage;
      } else {
        _replyList.addAll(topicDetailModel.replyList.reversed);
      }
      _currentPage -= 1;
      print('---_totalPage---:$_totalPage');
    });
    SmartDialog.dismiss();
  }

  // 返回顶部并 todo 刷新
  Future onRefreshBtm() async {
    print('12');
    await _scrollController.animateTo(0,
        duration: const Duration(milliseconds: 500), curve: Curves.ease);
    _controller.callRefresh();
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
      // _isVisible = true;
      // aStreamC.add(true);
      setState(() => _isVisible = true);
    }
  }

  void _hide() {
    if (_isVisible) {
      // _isVisible = false;
      // aStreamC.add(false);
      setState(() => _isVisible = false);
    }
  }

  // 回复框
  void showReplySheet() {
    var replyList = List.from(_replyList);
    replyList.retainWhere((i) => i.isChoose);
    setState(() {
      replyMemberList = replyList;
    });
    showModalBottomSheet<Map>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return ReplyNew(
          replyMemberList: replyMemberList,
          topicId: _detailModel!.topicId,
          totalPage: _totalPage,
        );
      },
    ).then((value) => {
          if (value != null)
            {EventBus().emit('topicReply', value['replyStatus'])}
        });
  }

  // 查看楼中楼回复
  void queryReplyList(replyMemberList, floorNumber, resultList) {
    List<ReplyItem> replyList =
        _replyList.where((e) => e.floorNumber < floorNumber).toList();
    List<Map> multipleReplyList = List.filled(replyMemberList.length, {});
    for (var i in replyList) {
      if (replyMemberList.contains(i.userName)) {
        int index = replyMemberList.indexOf(i.userName);
        Map replyListMap = {};
        List repliesList = [];
        repliesList.add(i);
        repliesList.add(_replyList
            .where((value) => value.floorNumber == floorNumber)
            .toList()[0]);
        replyListMap[i.userName] = repliesList;
        multipleReplyList[index] = replyListMap;
      }
    }
    showfloorReply(multipleReplyList, replyMemberList);
  }

  void showfloorReply(multipleReplyList, replyMemberList) {
    setState(() {
      floorReplyVisible = true;
    });
    var statusHeight = MediaQuery.of(context).padding.top;
    var height = MediaQuery.of(context).size.height - statusHeight;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return ReplySheet(
          height: height,
          replyMemberList: replyMemberList,
          resultList: multipleReplyList,
          topicId: _detailModel!.topicId,
        );
      },
    ).then((value) {
      setState(() {
        floorReplyVisible = false;
      });
    });
  }

  // 忽略主题
  Future onIgnoreTopic() async {
    Future.delayed(
      const Duration(seconds: 0),
      () => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('操作提示'),
          content: const Text('确认忽略该主题吗？'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('取消')),
            TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  SmartDialog.showLoading();
                  var res = await DioRequestWeb.onIgnoreTopic(topicId);
                  SmartDialog.dismiss();
                  SmartDialog.showToast(res ? '已忽略' : '操作失败');
                  if (res) {
                    EventBus().emit('ignoreTopic', topicId);
                  }
                },
                child: const Text('确认'))
          ],
        ),
      ),
    );
  }

  // 举报主题
  Future onReportTopic() async {
    Future.delayed(
      const Duration(seconds: 0),
      () => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('操作提示'),
          content: const Text('确认举报该主题吗？'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('取消')),
            TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  SmartDialog.showLoading();
                  var res = await DioRequestWeb.onReportTopic(topicId);
                  SmartDialog.dismiss();
                  SmartDialog.showToast(res ? '已举报' : '操作失败');
                  if (res) {
                    EventBus().emit('ignoreTopic', topicId);
                  }
                },
                child: const Text('确认'))
          ],
        ),
      ),
    );
  }

  Future<void> onShareTopic() async {
    final box = context.findRenderObject() as RenderBox?;
    var result = await Share.share(
      'https://www.v2ex.com/t/$topicId',
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    ).whenComplete(() {
      print("share completion block ");
    });
    return result;
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.removeListener(_listen);
    _scrollController.dispose();
    EventBus().off('topicReply');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: !expendAppBar ?  AppBar(
            centerTitle: false,
            title: Text(
              _detailModel != null ? _detailModel!.topicTitle : '',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            actions: _detailModel != null ? appBarAction() : [],
          ) : null,
          body: _detailModel != null
              ? Scrollbar(
                  radius: const Radius.circular(10),
                  controller: _scrollController,
                  child: PullRefresh(
                    key: _globalKey,
                    onChildRefresh: getDetailInit,
                    // 上拉
                    onChildLoad: !reverseSort
                        ? (_totalPage > 1 && _currentPage < _totalPage
                            ? getDetail
                            : null)
                        : (_currentPage > 0 ? getDetailReverst : null),
                    currentPage: _currentPage,
                    totalPage: _totalPage,
                    child: showRes(),
                  ),
                )
              : showLoading(),
          floatingActionButton: Badge(
            isLabelVisible: false,
            alignment: AlignmentDirectional.topStart,
            label: const Text('1'),
            child: FloatingActionButton(
              onPressed: showReplySheet,
              tooltip: '回复',
              child: const Icon(Icons.edit),
            ),
          ),
          floatingActionButtonLocation: _fabLocation,
          bottomNavigationBar: DetailBottomBar(
              onRefresh: onRefreshBtm,
              isVisible: _isVisible,
              detailModel: _detailModel,
              topicId: topicId),
          // bottomNavigationBar: StreamBuilder(
          //   stream: aStreamC.stream,
          //   initialData: false,
          //   builder: (context, AsyncSnapshot snapshot) {
          //     return DetailBottomBar(
          //       onRefresh: onRefreshBtm,
          //       isVisible: snapshot.data,
          //       detailModel: _detailModel,
          //     );
          //   },
          // ),
        ),
      ],
    );
  }

  // 顶部操作栏
  List<Widget> appBarAction() {
    List<Widget>? list = [];
    list.add(
      IconButton(
        onPressed: (() async {
          var res = await DioRequestWeb.favoriteTopic(
              _detailModel!.isFavorite, _detailModel!.topicId);
          if (res) {
            setState(() {
              _detailModel!.isFavorite = !_detailModel!.isFavorite;
              _detailModel!.favoriteCount = _detailModel!.isFavorite
                  ? _detailModel!.favoriteCount + 1
                  : _detailModel!.favoriteCount - 1;
            });
            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_detailModel!.isFavorite ? '已添加到收藏' : '已取消收藏'),
                showCloseIcon: true,
              ),
            );
          }
        }),
        tooltip: '收藏主题',
        icon: const Icon(Icons.star_border_rounded),
        selectedIcon: Icon(
          Icons.star_rounded,
          color: Theme.of(context).colorScheme.primary,
        ),
        isSelected: _detailModel!.isFavorite,
      ),
    );
    // list.add(
    //   IconButton(onPressed: () {
    //     Get.toNamed('/write', parameters: {
    //       'source': 'edit',
    //       'topicId': _detailModel!.topicId
    //     });
    //   }, icon: const Icon(Icons.edit_note_rounded))
    // );
    list.add(
      PopupMenuButton<SampleItem>(
        tooltip: 'action',
        itemBuilder: (BuildContext context) => <PopupMenuEntry<SampleItem>>[
          PopupMenuItem<SampleItem>(
            value: SampleItem.ignore,
            onTap: onIgnoreTopic,
            child: const Text('忽略主题'),
          ),
          PopupMenuItem<SampleItem>(
            value: SampleItem.share,
            onTap: onShareTopic,
            child: const Text('分享'),
          ),
          PopupMenuItem<SampleItem>(
            value: SampleItem.report,
            onTap: onReportTopic,
            child: Text(
              '举报',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.error.withAlpha(200)),
            ),
          ),
          const PopupMenuDivider(),
          PopupMenuItem<SampleItem>(
            value: SampleItem.browse,
            onTap: () => Utils.openURL('https://www.v2ex.com/t/$topicId'),
            child: const Text('在浏览器中打开'),
          ),
        ],
      ),

    );
    list.add(const SizedBox(width: 12));
    return list;
  }

  Widget showRes() {
    return CustomScrollView(
      controller: _scrollController,
      key: listGlobalKey,
      slivers: [
        if(expendAppBar) ... [
          SliverAppBar(
            expandedHeight: kToolbarHeight + MediaQuery.of(context).padding.top,
            automaticallyImplyLeading: false,
            elevation: 1,
            pinned: true,
            floating: true,
            primary: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Column(
                children: [
                  AppBar(
                    centerTitle: false,
                    title: Text(
                      _detailModel != null ? _detailModel!.topicTitle : '',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    actions: _detailModel != null ? appBarAction() : [],
                  ),
                ],
              ),
            ),
          ),
        ],
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
                          margin: const EdgeInsets.only(right: 10),
                          child: GestureDetector(
                              onTap: () => Get.toNamed(
                                      '/member/${_detailModel!.createdId}',
                                      parameters: {
                                        'memberAvatar': _detailModel!.avatar,
                                        'heroTag': heroTag,
                                      }),
                              child: Hero(
                                tag: _detailModel!.createdId + heroTag,
                                child: CAvatar(
                                  url: _detailModel!.avatar,
                                  size: 45,
                                ),
                              )),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            if (myUserName != '' &&
                                myUserName == _detailModel!.createdId) ...[
                              Text(
                                _detailModel!.createdId,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary),
                              ),
                            ] else ...[
                              Text(
                                _detailModel!.createdId,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ],
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
                    top: 0, right: 18, bottom: 15, left: 18),
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
                    '${_detailModel!.visitorCount}次查看',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${_detailModel!.replyCount}条回复',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(width: 20)
                ],
              ),
              const SizedBox(height: 5),
              Divider(
                endIndent: 15,
                indent: 15,
                color: Theme.of(context).dividerColor.withOpacity(0.15),
              ),
              // 内容
              Container(
                padding: const EdgeInsets.only(
                    top: 5, right: 18, bottom: 10, left: 18),
                child: SelectionArea(
                  child: HtmlRender(
                      htmlContent: _detailModel!.contentRendered,
                      imgCount: _detailModel!.imgCount,
                      imgList: _detailModel!.imgList),
                ),
              ),
              // 附言
              if (_detailModel!.subtleList.isNotEmpty) ...[
                ...subList(_detailModel!.subtleList)
              ],
              //
              // Divider(
              //   color: Theme.of(context).dividerColor.withOpacity(0.15),
              // ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     SizedBox(width: 20),
              //     IconButton(onPressed: () {}, icon: Icon(Icons.messenger_outline_rounded)),
              //     IconButton(onPressed: () {}, icon: Icon(Icons.favorite_outline_rounded)),
              //     IconButton(onPressed: () {}, icon: Icon(Icons.star_outline_rounded, size: 29,)),
              //     IconButton(onPressed: () {}, icon: Icon(Icons.language_rounded)),
              //     IconButton(onPressed: () {}, icon: Icon(Icons.share_outlined)),
              //     SizedBox(width: 20),
              //   ],
              // ),
              if (_detailModel!.content.isNotEmpty)
                Divider(
                  color: Theme.of(context).dividerColor.withOpacity(0.15),
                ),
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
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(fontSize: 18),
                    ),
                    if (_replyList.length > 2) ...[
                      RawChip(
                        side: BorderSide.none,
                        showCheckmark: false,
                        labelPadding: const EdgeInsets.only(left: 1, right: 4),
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
                              color:
                                  Theme.of(context).colorScheme.surfaceVariant),
                        ),
                        selectedColor:
                            Theme.of(context).colorScheme.outlineVariant,
                        selected: reverseSort,
                      ),
                    ]
                  ],
                )),
          ),
        ],
        // 回复列表
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return ReplyListItem(
                  reply: _replyList[index],
                  topicId: _detailModel!.topicId,
                  totalPage: _totalPage,
                  key: UniqueKey(),
                  queryReplyList: (replyMemberList, floorNumber, resultList) =>
                      queryReplyList(replyMemberList, floorNumber, resultList));
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
                (reverseSort && (_currentPage > 0)),
            child: moreTopic(),
          ),
        )
      ],
    );
  }

  // 附言
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
              HtmlRender(
                htmlContent: i.content,
                imgCount: _detailModel!.imgCount,
                imgList: _detailModel!.imgList,
              )
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
      height: 100 + MediaQuery.of(context).padding.bottom,
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 40),
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
