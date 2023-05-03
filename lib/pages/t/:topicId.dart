// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:flutter_v2ex/components/topic/main.dart';
import 'package:flutter_v2ex/pages/t/controller.dart';
import 'package:flutter_v2ex/service/i18n_keyword.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/rendering.dart';

import 'package:flutter_v2ex/components/topic/bottom_bar.dart';
import 'package:flutter_v2ex/components/topic/reply_item.dart';

import 'package:flutter_v2ex/models/web/model_topic_detail.dart';
import 'package:flutter_v2ex/models/web/item_topic_reply.dart';
import 'package:flutter_v2ex/components/common/pull_refresh.dart';
import 'package:flutter_v2ex/components/topic/reply_new.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_v2ex/utils/utils.dart';
import 'package:flutter_v2ex/utils/event_bus.dart';
import 'package:flutter_v2ex/utils/storage.dart';
import 'package:flutter_v2ex/components/topic/reply_sheet.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_v2ex/http/topic.dart';
import 'package:flutter_v2ex/service/read.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

enum SampleItem { ignore, share, report, browse }

class TopicDetail extends StatefulWidget {
  var topicDetail;
  TopicDetail({this.topicDetail,  super.key});

  @override
  State<TopicDetail> createState() => _TopicDetailState();
}

class _TopicDetailState extends State<TopicDetail>
    with TickerProviderStateMixin {
  // TabTopicItem? topic;
  String topicId = '';
  var _topicDetail;
  late EasyRefreshController _controller;

  // 待回复用户
  List replyMemberList = [];
  String heroTag = '';

  // 监听页面滚动
  // final ScrollController _scrollController = ScrollController();
  TopicDetailModel? _detailModel; // 主题详情
  late List<ReplyItem> _replyList = []; // 回复列表
  int _totalPage = 1; // 总页数
  int _currentPage = 0; // 当前页数
  final GlobalKey _globalKey = GlobalKey();
  GlobalKey listGlobalKey = GlobalKey(); // 获取pin时的滚动条高度
  late StreamController<bool> aStreamC; // bottomBar
  late StreamController<bool> titleStreamC; // appBar title

  // action
  bool reverseSort = false; // 倒序
  bool isLoading = false; // 请求状态 正序/倒序

  bool _isVisible = true;
  bool floorReplyVisible = false; // 查看回复
  String myUserName = ''; // 当前用户名

  SampleItem? selectedMenu;
  String platform = '';

  bool expendAppBar = GStorage().getExpendAppBar(); // 伸缩appBar

  late AnimationController animationController;
  bool _visibleTitle = false;
  double? pinScrollHeight;
  late AutoScrollController autoScrollController;

  // 消息页面进入
  String routerSource = '';
  int noticeFloorNumber = 0;

  String replyId = '';

  final TopicController _topicController = Get.put(TopicController());

  @override
  void initState() {
    super.initState();

    autoScrollController = AutoScrollController(
        viewportBoundaryGetter: () =>
            Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: Axis.vertical);

    _topicController.topicId.listen((value) async{
      topicId = value;
      _topicDetail = _topicController.topic.value;
      _detailModel = null;
      _currentPage = 0;
      if(mounted){
        await getDetailInit();
      }
    });

    // setState(() {
    try{
      topicId = Get.parameters['topicId']!;
    }catch(e){
      print('❌ :topic.dart line 111 Error: Get parameters don\'t have topicId');
    }
    if(widget.topicDetail != null){
      _topicDetail = widget.topicDetail;
      topicId = widget.topicDetail.topicId;
    }

    if (Get.arguments != null) {
      _topicDetail = Get.arguments['topic'];
      heroTag = Get.arguments['heroTag'];
    }
    var keys = Get.parameters.keys;
    // 从消息页面进入 跳转至指定楼层
    if (keys.contains('floorNumber')) {
      routerSource = Get.parameters['source'] ?? '';
      noticeFloorNumber = int.parse(Get.parameters['floorNumber'] ?? '0');
      _currentPage = (noticeFloorNumber / 100).ceil() - 1;
      //  noticeReplyCount 小于等于100 直接请求第一页 大于100 请求
    }
    // 直接跳转指定楼层
    if (keys.contains('replyId')) {
      replyId = Get.parameters['replyId'] ?? '';
      _currentPage = int.parse(Get.parameters['p']!) - 1;
    }
    myUserName = GStorage().getUserInfo().isNotEmpty
        ? GStorage().getUserInfo()['userName']
        : '';
    // });

    _controller = EasyRefreshController(
      controlFinishRefresh: true,
      controlFinishLoad: true,
    );

    // TODO build优化
    autoScrollController.addListener(_listen);
    getDetailInit();
    eventBus.on('topicReply', (status) {
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
    titleStreamC = StreamController<bool>();

    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));

    if (Platform.isAndroid) {
      platform = 'android';
    } else if (Platform.isIOS) {
      platform = 'ios';
    }
    if(Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      platform = 'desktop';
    }
  }

  Future getDetailInit() async {
    await getDetail(type: 'init');
    // 标记已读
    Read().add(_detailModel!);
  }

  Future getDetail({type}) async {
    if (type == 'init' && routerSource == '' && replyId == '') {
      // 初始化加载  正序首页为0 倒序首页为最后一页
      setState(() {
        _currentPage = !reverseSort ? 0 : _totalPage;
      });
    }
    if (reverseSort) {
      SmartDialog.showLoading(msg: '加载中ing');
    }
    TopicDetailModel topicDetailModel =
        await TopicWebApi.getTopicDetail(topicId, _currentPage + 1);
    setState(() {
      _detailModel = topicDetailModel;
      if (_currentPage == 0) {
        _replyList = topicDetailModel.replyList;
        _totalPage = topicDetailModel.totalPage;
      } else {
        _replyList.addAll(topicDetailModel.replyList);
      }
      if(replyId != ''){
        noticeFloorNumber = topicDetailModel.replyList.where((i) => i.replyId == replyId).first.floorNumber;
      }
      _currentPage += 1;
    });

    if (pinScrollHeight == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (listGlobalKey.currentContext != null) {
          final pinBox =
              listGlobalKey.currentContext?.findRenderObject() as RenderBox;
          final pinPosition = pinBox.localToGlobal(Offset.zero).dy - 100;
          setState(() {
            pinScrollHeight = pinPosition;
          });
        }
      });
      if (noticeFloorNumber > 0) {
        SmartDialog.showLoading(msg: '前往楼层');
        await _scrollToCounter();
        SmartDialog.dismiss();
      }
    }
    if (!topicDetailModel.isAuth) {
      SmartDialog.dismiss();
    }
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
        await TopicWebApi.getTopicDetail(topicId, _currentPage);
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
    if (type == 'init') {
      autoScrollController.animateTo(pinScrollHeight!,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeInOut);
    }
    SmartDialog.dismiss();
  }

  // 返回顶部并 todo 刷新
  Future onRefreshBtm() async {
    await autoScrollController.animateTo(0,
        duration: const Duration(milliseconds: 500), curve: Curves.ease);
    _controller.callRefresh();
  }

  void _listen() {
    final ScrollDirection direction =
        autoScrollController.position.userScrollDirection;
    if (direction == ScrollDirection.forward) {
      _show();
    } else if (direction == ScrollDirection.reverse) {
      _hide();
    }

    if (autoScrollController.offset > 100 && !_visibleTitle) {
      _visibleTitle = true;
      titleStreamC.add(true);
    } else if (autoScrollController.offset <= 100 && _visibleTitle) {
      _visibleTitle = false;
      titleStreamC.add(false);
    }
  }

  void _show() {
    if (!_isVisible) {
      // stream
      _isVisible = true;
      aStreamC.add(true);
      animationController.forward();
    }
  }

  void _hide() {
    if (_isVisible) {
      // stream
      _isVisible = false;
      aStreamC.add(false);
      animationController.reverse();
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
          replyList: _replyList,
        );
      },
    ).then((value) {
      // 回复成功取消回复取消选中状态
      if (value != null) {
        var list = _replyList;
        for (var item in _replyList) {
          item.isChoose = false;
        }
        setState(() {
          _replyList = list;
        });
        eventBus.emit('topicReply', value['replyStatus']);
      }
    });
  }

  // 查看楼中楼回复
  void queryReplyList(replyMemberList, floorNumber, resultList, totalPage) {
    // replyMemberList 被@的用户
    // resultList 当前楼层回复
    // [
    //  {'userName1': [ReplyItem, ReplyItem]},
    //  {'userName2': [ReplyItem, ReplyItem]},
    // ]
    print('resultList: ${resultList[0].userName}');

    // 获取之前楼层的所有回复
    List<ReplyItem> replyList =
        _replyList.where((e) => e.floorNumber < floorNumber).toList();
    // 根据@的用户数 创建指定长度的列表
    List<Map> multipleReplyList = List.filled(replyMemberList.length, {});
    // 循环评论列表
    bool queryFlag = false;
    for (var i in replyList) {
      if (replyMemberList.contains(i.userName)) {
        queryFlag = true;
        // 取出被@用户的回复
        // 插入指定位置
        int index = replyMemberList.indexOf(i.userName);
        Map replyListMap = {};
        List repliesList = [];
        repliesList.add(i); //放入多个 ReplyItem
        // repliesList.add(_replyList
        //     .where((value) => value.floorNumber == floorNumber)
        //     .toList()[0]);
        repliesList.add(resultList[0]); // 最后放入当前楼层
        replyListMap[i.userName] = repliesList;
        multipleReplyList[index] = replyListMap;
      }
    }

    /// 没有查询到@用户 只添加本楼回复
    if (!queryFlag) {
      multipleReplyList = [];
      Map replyListMap = {
        resultList[0].userName: [resultList[0]]
      };
      multipleReplyList.add(replyListMap);
      replyMemberList = [resultList[0].userName];
    }
    showfloorReply(multipleReplyList, replyMemberList, totalPage);
  }

  void showfloorReply(multipleReplyList, replyMemberList, totalPage) {
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
          totalPage: totalPage,
          replyList: _replyList,
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
                  var res = await TopicWebApi.onIgnoreTopic(topicId);
                  SmartDialog.dismiss();
                  SmartDialog.showToast(res ? '已忽略' : '操作失败');
                  if (res) {
                    eventBus.emit('ignoreTopic', topicId);
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
                  var res = await TopicWebApi.onReportTopic(topicId);
                  SmartDialog.dismiss();
                  SmartDialog.showToast(res ? '已举报' : '操作失败');
                  if (res) {
                    eventBus.emit('ignoreTopic', topicId);
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

  // 收藏
  Future<void> onFavTopic() async {
    var res = await TopicWebApi.favoriteTopic(
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
  }

  // 感谢
  Future<void> onThankTopic() async {
    if (_detailModel!.isThank) {
      SmartDialog.showToast('这个主题已经被感谢过了');
    } else {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('提示'),
          content: const Text('确认向本主题创建者表示感谢吗？'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'Cancel'),
              child: const Text('手误了'),
            ),
            TextButton(
              onPressed: (() async {
                Navigator.pop(context, 'OK');
                var res = await TopicWebApi.thankTopic(_detailModel!.topicId);
                print('54: $res');
                if (res) {
                  setState(() {
                    _detailModel!.isThank = true;
                  });
                  SmartDialog.showToast('感谢成功');
                }
              }),
              child: const Text('确定'),
            ),
          ],
        ),
      );
    }
  }

  Future _scrollToCounter() async {
    await autoScrollController.scrollToIndex(
      (noticeFloorNumber % 100) - 1,
      preferPosition: AutoScrollPosition.begin,
      duration: const Duration(milliseconds: 100),
    );
    // autoScrollController.highlight(5);
  }

  // 复制链接
  onCopyTopicLink() {
    Clipboard.setData(ClipboardData(text: 'https://www.v2ex.com/t/$topicId'));
  }

  @override
  void dispose() {
    _controller.dispose();
    autoScrollController.removeListener(_listen);
    autoScrollController.dispose();
    eventBus.off('topicReply');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: !expendAppBar
              ? AppBar(
                  scrolledUnderElevation: Breakpoints.mediumAndUp.isActive(context) ?  0 : 4,
                  centerTitle: false,
                  title: StreamBuilder(
                    stream: titleStreamC.stream,
                    initialData: false,
                    builder: (context, AsyncSnapshot snapshot) {
                      return AnimatedOpacity(
                        opacity: snapshot.data ? 1 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          _detailModel != null ? _detailModel!.topicTitle : '',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      );
                    },
                  ),
                  // actions: _detailModel != null ? appBarAction() : [],
                  actions: appBarAction(),
                )
              : null,
          body: _topicDetail == null && _detailModel == null
              ? showLoading()
              : Scrollbar(
                  radius: const Radius.circular(10),
                  controller: autoScrollController,
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
                    ctr: _controller,
                    child: showRes(),
                  ),
                ),
          bottomNavigationBar: StreamBuilder(
            stream: aStreamC.stream,
            initialData: false,
            builder: (context, AsyncSnapshot snapshot) {
              return DetailBottomBar(
                onRefresh: onRefreshBtm,
                isVisible: snapshot.data,
                detailModel: _detailModel,
                topicId: topicId,
              );
            },
          ),
        ),
        Positioned(
          bottom: 18,
          right: 20,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -0),
              end: const Offset(0, 0.05),
            ).animate(CurvedAnimation(
              parent: animationController,
              curve: Curves.easeInOut,
            )),
            child: FloatingActionButton(
              heroTag: null,
              elevation: 4,
              onPressed: _detailModel != null ? showReplySheet : null,
              tooltip: '回复',
              child: const Icon(Icons.edit),
            ),
          ),
        ),
      ],
    );
  }

  // 顶部操作栏
  List<Widget> appBarAction() {
    List<Widget>? list = [];
    if(_detailModel != null) {
      list.add(
        IconButton(
          onPressed: onFavTopic,
          tooltip: '收藏主题',
          icon: const Icon(Icons.bookmark_add_outlined),
          selectedIcon: Icon(
            Icons.bookmark_add_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
          isSelected: _detailModel!.isFavorite,
        ),
      );
    }
    list.add(
      PopupMenuButton<SampleItem>(
        tooltip: 'action',
        itemBuilder: (BuildContext context) => <PopupMenuEntry<SampleItem>>[
          PopupMenuItem<SampleItem>(
            value: SampleItem.share,
            onTap: onCopyTopicLink,
            child: const Text('复制链接'),
          ),
          PopupMenuItem<SampleItem>(
            value: SampleItem.ignore,
            onTap: onIgnoreTopic,
            child: Text(I18nKeyword.topicIgnore.tr),
          ),
          PopupMenuItem<SampleItem>(
            value: SampleItem.share,
            onTap: onShareTopic,
            child: Text(I18nKeyword.topicShare.tr),
          ),
          PopupMenuItem<SampleItem>(
            value: SampleItem.report,
            onTap: onReportTopic,
            child: Text(
              I18nKeyword.topicReport.tr,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.error.withAlpha(200)),
            ),
          ),
          const PopupMenuDivider(),
          PopupMenuItem<SampleItem>(
            value: SampleItem.browse,
            onTap: () => Utils.openURL('https://www.v2ex.com/t/$topicId'),
            child: Text(
              I18nKeyword.openInBrowser.tr,
            ),
          ),
        ],
      ),
    );
    list.add(const SizedBox(width: 12));
    return list;
  }

  Widget showRes() {
    return CustomScrollView(
      controller: autoScrollController,
      // key: listGlobalKey,
      slivers: [
        if (expendAppBar) ...[
          SliverAppBar(
            toolbarHeight: platform == 'android'
                ? (MediaQuery.of(context).padding.top + 6)
                : platform == 'ios' ? MediaQuery.of(context).padding.top - 2 : kToolbarHeight,
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
                    title: StreamBuilder(
                      stream: titleStreamC.stream,
                      initialData: false,
                      builder: (context, AsyncSnapshot snapshot) {
                        return AnimatedOpacity(
                          opacity: snapshot.data ? 1 : 0,
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            _detailModel != null
                                ? _detailModel!.topicTitle
                                : '',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        );
                      },
                    ),
                    // actions: _detailModel != null ? appBarAction() : [],
                    actions: appBarAction(),
                  ),
                ],
              ),
            ),
          ),
        ],
        if (_detailModel != null &&
            myUserName == _detailModel!.createdId &&
            (_detailModel!.isAPPEND ||
                _detailModel!.isEDIT ||
                _detailModel!.isMOVE))
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              color:
                  Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(' 对主题进行操作'),
                  Row(
                    children: [
                      if (_detailModel!.isAPPEND)
                        TextButton(
                            onPressed: () async {
                              var res = await Get.toNamed('/write',
                                  parameters: {
                                    'source': 'append',
                                    'topicId': _detailModel!.topicId
                                  });
                              if (res != null && res['refresh']) {
                                SmartDialog.showLoading(msg: '刷新中...');
                                getDetailInit();
                              }
                            },
                            child: const Text('增加附言')),
                      if (_detailModel!.isEDIT)
                        TextButton(
                            onPressed: () async {
                              var res = await Get.toNamed('/write',
                                  parameters: {
                                    'source': 'edit',
                                    'topicId': _detailModel!.topicId
                                  });
                              if (res != null && res['refresh']) {
                                SmartDialog.showLoading(msg: '刷新中...');
                                getDetailInit();
                              }
                            },
                            child: const Text('编辑主题')),
                      if (_detailModel!.isMOVE)
                        TextButton(
                            onPressed: () async {
                              var res = await Get.toNamed('/topicNodes',
                                  parameters: {
                                    'source': 'move',
                                    'topicId': _detailModel!.topicId
                                  });
                              if (res != null && res['nodeDetail'].isNotEmpty) {
                                setState(() {
                                  _detailModel!.nodeName =
                                      res['nodeDetail']['nodeName'];
                                  _detailModel!.nodeId =
                                      res['nodeDetail']['nodeId'];
                                });
                              }
                            },
                            child: const Text('移动节点')),
                    ],
                  ),
                ],
              ),
            ),
          ),
        SliverToBoxAdapter(
          child: TopicMain(
              detailModel: _detailModel,
              topicDetail: _topicDetail,
              heroTag: heroTag),
        ),
        if (_detailModel != null) ...[
          if (_replyList.isNotEmpty) ...[
            const SliverToBoxAdapter(
              child: SizedBox(height: 10),
            ),
            SliverPersistentHeader(
              delegate: _MySliverPersistentHeaderDelegate(
                child: Container(
                  key: listGlobalKey,
                  height: 60,
                  padding: const EdgeInsets.only(left: 15, right: 12),
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
                                    .surfaceVariant),
                          ),
                          selectedColor:
                              Theme.of(context).colorScheme.outlineVariant,
                          selected: reverseSort,
                        ),
                      ]
                    ],
                  ),
                ),
              ),
              pinned: true,
            ),
            if (noticeFloorNumber > 0 && _currentPage > 1)
              SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  height: 60,
                  color: Theme.of(context).colorScheme.onInverseSurface,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.commit,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(width: 6),
                        Text('前 ${_currentPage - 1} 页已隐藏')
                      ],
                    ),
                  ),
                ),
              ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                childCount: _replyList.length,
                (context, index) {
                  return AutoScrollTag(
                      key: ValueKey(index),
                      controller: autoScrollController,
                      index: index,
                      child:
                          // noticeFloorNumber > 0 && index == 0 ? Text('123') :
                          ReplyListItem(
                        reply: _replyList[index],
                        topicId: _detailModel!.topicId,
                        totalPage: _totalPage,
                        key: UniqueKey(),
                        queryReplyList: (replyMemberList, floorNumber,
                                resultList, totalPage) =>
                            queryReplyList(replyMemberList, floorNumber,
                                resultList, _totalPage),
                        source: 'topic',
                        replyList: _replyList,
                        floorNumber: noticeFloorNumber,
                      ));
                  // return ReplyListItem(
                  //   reply: _replyList[index],
                  //   topicId: _detailModel!.topicId,
                  //   totalPage: _totalPage,
                  //   key: UniqueKey(),
                  //   queryReplyList:
                  //       (replyMemberList, floorNumber, resultList, totalPage) =>
                  //           queryReplyList(replyMemberList, floorNumber,
                  //               resultList, _totalPage),
                  //   source: 'topic',
                  //   replyList: _replyList,
                  // );
                },
                // childCount: _replyList.length,
              ),
            ),
          ],
          // 没有更多
          SliverToBoxAdapter(
            child: Offstage(
              // when true hidden
              offstage: _detailModel!.replyCount != 0,
              child: moreTopic(type: 'null'),
            ),
          ),
          // 加载更多
          SliverToBoxAdapter(
            child: Offstage(
              // when true hidden
              // no reply hidden
              //
              offstage: _detailModel!.replyCount == 0 ||
                  (!reverseSort && (_currentPage < _totalPage)) ||
                  (reverseSort && (_currentPage > 0)),
              child: moreTopic(),
            ),
          )
        ],
        // 回复列表
      ],
    );
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
          type == 'noMore' ? I18nKeyword.noMoreResponses.tr : '还没有人回复',
          style: const TextStyle(fontSize: 13),
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

class _MySliverPersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double _minExtent = 55;
  final double _maxExtent = 55;
  final Widget child;

  _MySliverPersistentHeaderDelegate({required this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    //创建child子组件
    //shrinkOffset：child偏移值minExtent~maxExtent
    //overlapsContent：SliverPersistentHeader覆盖其他子组件返回true，否则返回false
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        boxShadow: overlapsContent
            ? [
                BoxShadow(
                  color: Theme.of(context)
                      .colorScheme
                      .background
                      .withOpacity(0.15),
                  spreadRadius: 2,
                  blurRadius: 20,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: child,
    );
  }

  //SliverPersistentHeader最大高度
  @override
  double get maxExtent => _maxExtent;

  //SliverPersistentHeader最小高度
  @override
  double get minExtent => _minExtent;

  @override
  bool shouldRebuild(covariant _MySliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
