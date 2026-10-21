// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:async';
import 'package:flutter_v2ex/service/content_cache.dart';
import 'package:flutter_v2ex/service/page_request.dart';
import 'package:flutter_v2ex/components/common/load_more_retry.dart';
import 'package:flutter_v2ex/components/common/network_error.dart';
import 'package:flutter/services.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:flutter_v2ex/components/topic/main.dart';
import 'package:flutter_v2ex/pages/t/controller.dart';
import 'package:flutter_v2ex/service/i18n_keyword.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

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
import 'package:flutter_v2ex/utils/logger.dart';

enum SampleItem { thank, copy, share, browse, ignore, report }

class TopicDetail extends StatefulWidget {
  final dynamic topicDetail;
  final Future<TopicDetailModel> Function(String, int)? loadDetail;
  const TopicDetail({this.topicDetail, this.loadDetail, super.key});

  @override
  State<TopicDetail> createState() => _TopicDetailState();
}

class _TopicDetailState extends State<TopicDetail> with WidgetsBindingObserver {
  // TabTopicItem? topic;
  String topicId = '';
  dynamic _topicDetail;
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
  int _entryPage = 1;
  int _loadedStartPage = 1;
  final Map<String, int> _replyPages = {};
  final GlobalKey _readingViewportKey = GlobalKey();
  ReadingProgress? _lastVisibleProgress;
  ReadingProgress? _resumeProgress;
  late String _progressKey;
  late String _progressScope;
  bool _isJumping = false;
  bool _readingActivated = false;
  int _interactionVersion = 0;
  final _requests = PageRequest();
  String? _detailError;
  String? _pageError;
  bool _prefetchFailed = false;
  bool _paginationDemanded = false;
  bool _isLoadingMore = false;
  Worker? _topicSubscription;
  final GlobalKey _globalKey = GlobalKey();
  GlobalKey listGlobalKey = GlobalKey(); // 获取pin时的滚动条高度
  late StreamController<bool> backToTopStream;
  late StreamController<bool> titleStreamC; // appBar title

  // action
  bool reverseSort = false; // 倒序
  bool isLoading = false; // 请求状态 正序/倒序

  bool _showBackToTop = false;
  bool floorReplyVisible = false; // 查看回复
  String myUserName = ''; // 当前用户名

  SampleItem? selectedMenu;
  String platform = '';

  bool expendAppBar = GStorage().getExpendAppBar(); // 伸缩appBar

  bool _visibleTitle = false;
  double? pinScrollHeight;
  late AutoScrollController autoScrollController;

  // 消息页面进入
  String routerSource = '';
  int noticeFloorNumber = 0;
  int? _highlightedFloor;
  int _highlightVersion = 0;
  int _consumedHighlightVersion = 0;
  bool _entryLocationPending = false;

  String replyId = '';

  final TopicController _topicController = Get.put(TopicController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    autoScrollController = AutoScrollController(
        viewportBoundaryGetter: () => Rect.fromLTRB(
            0, _readingTopInset, 0, MediaQuery.of(context).padding.bottom),
        axis: Axis.vertical);

    _topicSubscription = ever(_topicController.topicId, (String value) async {
      if (!mounted || value == topicId) return;
      _saveReadingProgress();
      _requests.invalidate();
      topicId = value;
      _topicDetail = _topicController.topic.value;
      _detailModel = null;
      _currentPage = 0;
      _entryPage = 1;
      _replyList = [];
      _totalPage = 1;
      _detailError = null;
      _pageError = null;
      pinScrollHeight = null;
      routerSource = '';
      replyId = '';
      noticeFloorNumber = 0;
      _entryLocationPending = false;
      _highlightedFloor = null;
      reverseSort = false;
      _loadedStartPage = 1;
      _replyPages.clear();
      _readingActivated = false;
      _isJumping = false;
      _resetReadingProgress();
      if (mounted) {
        await getDetailInit();
      }
    });

    // setState(() {
    try {
      topicId = Get.parameters['topicId']!;
    } catch (e) {
      logDebug(
          '❌ :topic.dart line 111 Error: Get parameters don\'t have topicId');
    }
    if (widget.topicDetail != null) {
      _topicDetail = widget.topicDetail;
      topicId = widget.topicDetail.topicId;
    }

    if (Get.arguments != null) {
      _topicDetail = Get.arguments['topic'];
      heroTag = Get.arguments['heroTag'];
    }
    var keys = Get.parameters.keys;
    final linkPage = int.tryParse(Get.parameters['p'] ?? '');
    if (linkPage != null && linkPage > 0) _currentPage = linkPage - 1;
    // 从消息页面进入 跳转至指定楼层
    if (keys.contains('floorNumber')) {
      routerSource = Get.parameters['source'] ?? '';
      noticeFloorNumber = int.parse(Get.parameters['floorNumber'] ?? '0');
      _currentPage = ReadingProgress.pageForFloor(noticeFloorNumber) - 1;
      //  noticeReplyCount 小于等于100 直接请求第一页 大于100 请求
    }
    // 直接跳转指定楼层
    if (keys.contains('replyId')) {
      replyId = Get.parameters['replyId'] ?? '';
      _currentPage = int.parse(Get.parameters['p']!) - 1;
    }
    _entryPage = _currentPage < 0 ? 1 : _currentPage + 1;
    _entryLocationPending = noticeFloorNumber > 0 || replyId.isNotEmpty;
    _loadedStartPage = _entryPage;
    _resetReadingProgress();
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
      logDebug('eventON: $status');
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

    backToTopStream = StreamController<bool>();
    titleStreamC = StreamController<bool>();

    if (Platform.isAndroid) {
      platform = 'android';
    } else if (Platform.isIOS) {
      platform = 'ios';
    }
    if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      platform = 'desktop';
    }
  }

  void _resetReadingProgress() {
    _lastVisibleProgress = null;
    _progressScope = ContentCache.scope;
    _progressKey = ContentCache.key('topic:$topicId', 1);
    final cached = ContentCache.read(_progressKey);
    _resumeProgress =
        noticeFloorNumber > 0 || replyId.isNotEmpty ? null : cached?.progress;
    // Hydrate before the first build; the network request starts on a later turn.
    if (_detailModel == null && _entryPage == 1 && cached != null) {
      _detailModel = cached.data;
      _replyList = List.of(cached.data.replyList);
      _totalPage = cached.data.totalPage;
      _currentPage = 1;
      _loadedStartPage = 1;
      _replyPages.clear();
      for (final reply in _replyList) {
        _replyPages[reply.replyId] = 1;
      }
    }
  }

  Future<TopicDetailModel> _fetchPage(String id, int page) =>
      widget.loadDetail?.call(id, page) ??
      TopicWebApi.getTopicDetail(id, page, silent: true);

  bool _consumeHighlight(int version) {
    if (version != _highlightVersion || version <= _consumedHighlightVersion) {
      return false;
    }
    _consumedHighlightVersion = version;
    return true;
  }

  double get _readingTopInset {
    final header = listGlobalKey.currentContext?.findRenderObject();
    final headerHeight =
        header is RenderBox && header.hasSize ? header.size.height : 55.0;
    final toolbar = platform == 'android'
        ? MediaQuery.of(context).padding.top + 6
        : platform == 'ios'
            ? MediaQuery.of(context).padding.top - 2
            : kToolbarHeight;
    return headerHeight + (expendAppBar ? toolbar : 0);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) _saveReadingProgress();
  }

  ReadingProgress? _visibleReadingProgress() {
    // Dimension changes can dispatch scroll notifications during layout. Keep
    // the last stable snapshot instead of reading ancestor transforms mid-frame.
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      return null;
    }
    if (!autoScrollController.hasClients || _replyList.isEmpty) return null;
    final viewport = _readingViewportKey.currentContext?.findRenderObject();
    if (viewport is! RenderBox || !viewport.hasSize) return null;
    final top = viewport.localToGlobal(Offset.zero).dy + _readingTopInset;
    final bottom =
        viewport.localToGlobal(Offset.zero).dy + viewport.size.height;
    double? firstTop;
    int? firstIndex;
    for (final entry in autoScrollController.tagMap.entries) {
      if (entry.key < 0 || entry.key >= _replyList.length) continue;
      final box = entry.value.context.findRenderObject();
      if (box is! RenderBox || !box.hasSize || !box.attached) continue;
      final y = box.localToGlobal(Offset.zero).dy;
      if (y + box.size.height <= top || y >= bottom) continue;
      if (firstTop == null || y < firstTop) {
        firstTop = y;
        firstIndex = entry.key;
      }
    }
    if (firstIndex == null) return null;
    final reply = _replyList[firstIndex];
    if (reply.floorNumber <= 0) return null;
    return ReadingProgress(
        replyId: reply.replyId,
        floorNumber: reply.floorNumber,
        page: _replyPages[reply.replyId] ??
            ReadingProgress.pageForFloor(reply.floorNumber),
        offsetWithinReply: (top - firstTop!).clamp(0, double.infinity));
  }

  void _saveReadingProgress() {
    if (!_readingActivated ||
        _isJumping ||
        ContentCache.scope != _progressScope) {
      return;
    }
    final progress = _visibleReadingProgress() ?? _lastVisibleProgress;
    if (progress != null) {
      unawaited(ContentCache.saveProgress(_progressKey, progress));
    }
  }

  bool _onReadingScroll(ScrollNotification notification) {
    if (notification.depth != 0) return false;
    if ((notification is ScrollStartNotification &&
            notification.dragDetails != null) ||
        (notification is UserScrollNotification &&
            notification.direction != ScrollDirection.idle)) {
      _interactionVersion++;
      _entryLocationPending = false;
      if (!_isJumping) _readingActivated = true;
    }
    if (_readingActivated && !_isJumping) {
      _lastVisibleProgress = _visibleReadingProgress() ?? _lastVisibleProgress;
      if (notification is ScrollEndNotification) {
        _saveReadingProgress();
      }
    }
    return false;
  }

  Future<bool> _positionAt(int index, {double offset = 0}) async {
    final id = topicId;
    final scope = _progressScope;
    final interaction = _interactionVersion;
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted ||
        topicId != id ||
        ContentCache.scope != scope ||
        interaction != _interactionVersion ||
        !autoScrollController.hasClients ||
        index < 0 ||
        index >= _replyList.length) {
      return false;
    }
    await autoScrollController.scrollToIndex(index,
        preferPosition: AutoScrollPosition.begin,
        duration: const Duration(milliseconds: 150));
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted ||
        topicId != id ||
        ContentCache.scope != scope ||
        interaction != _interactionVersion ||
        !autoScrollController.hasClients ||
        index >= _replyList.length) {
      return false;
    }
    final box = autoScrollController.tagMap[index]?.context.findRenderObject();
    final viewport = _readingViewportKey.currentContext?.findRenderObject();
    if (box is RenderBox &&
        box.hasSize &&
        viewport is RenderBox &&
        viewport.hasSize) {
      final withinReply =
          offset.clamp(0, (box.size.height - 24).clamp(0, double.infinity));
      final desiredTop = viewport.localToGlobal(Offset.zero).dy +
          _readingTopInset +
          (offset > 0 ? -withinReply : 0);
      final correction = box.localToGlobal(Offset.zero).dy - desiredTop;
      autoScrollController.jumpTo((autoScrollController.offset + correction)
          .clamp(autoScrollController.position.minScrollExtent,
              autoScrollController.position.maxScrollExtent));
      return true;
    }
    return false;
  }

  Future<void> _jumpReplies(
      {ReadingProgress? progress,
      bool latest = false,
      bool earlier = false}) async {
    if (_isJumping || _detailModel == null) return;
    if (progress != null) {
      final index = progress.indexIn(_replyList);
      if (index != null &&
          (_replyList[index].replyId == progress.replyId ||
              _replyList[index].floorNumber == progress.floorNumber)) {
        _readingActivated = false;
        setState(() {
          _isJumping = true;
          _resumeProgress = null;
        });
        final id = topicId;
        final scope = _progressScope;
        try {
          final positioned = await _positionAt(index);
          if (mounted && topicId == id && ContentCache.scope == scope) {
            setState(() {
              if (positioned) {
                _highlightedFloor = _replyList[index].floorNumber;
                _highlightVersion++;
              } else {
                _resumeProgress = progress;
              }
            });
          }
        } finally {
          if (mounted && topicId == id) setState(() => _isJumping = false);
        }
        return;
      }
    }
    final id = topicId;
    final scope = _progressScope;
    final interaction = _interactionVersion;
    final anchor = earlier ? _visibleReadingProgress() : null;
    final target = earlier
        ? _loadedStartPage - 1
        : latest
            ? _totalPage
            : progress!.page.clamp(1, _totalPage);
    if (target < 1) return;
    _readingActivated = false;
    setState(() {
      _isJumping = true;
      _isLoadingMore = false;
    });
    await _requests.run((generation) async {
      bool active() =>
          mounted &&
          topicId == id &&
          ContentCache.scope == scope &&
          _requests.accepts(generation);
      try {
        var page = target;
        var model = await _fetchPage(id, page);
        if (!active() || interaction != _interactionVersion) return;
        if ((latest && page != model.totalPage) || page > model.totalPage) {
          page = model.totalPage.clamp(1, 1000000);
          model = await _fetchPage(id, page);
        }
        if (!active() || interaction != _interactionVersion) return;
        if (model.replyList.isEmpty) {
          SmartDialog.showToast('该页暂无回复');
          return;
        }
        final incoming = List<ReplyItem>.of(model.replyList);
        setState(() {
          for (final r in incoming) {
            _replyPages[r.replyId] = page;
          }
          if (earlier) {
            final ids = _replyList.map((r) => r.replyId).toSet();
            _replyList = [
              ...incoming.where((r) => !ids.contains(r.replyId)),
              ..._replyList
            ];
            _loadedStartPage = page;
          } else {
            _replyList = incoming;
            _replyPages.removeWhere(
                (key, _) => !incoming.any((r) => r.replyId == key));
            _entryPage = page;
            _currentPage = page;
            _loadedStartPage = page;
            reverseSort = false;
          }
          _detailModel = model;
          _totalPage = model.totalPage;
          _pageError = null;
          _detailError = null;
          _isLoadingMore = false;
          _resumeProgress = null;
        });
        await ContentCache.write(_progressKey, model, cacheReplies: page == 1);
        if (!active()) return;
        final position = earlier ? anchor : progress;
        final index =
            latest ? _replyList.length - 1 : position?.indexIn(_replyList) ?? 0;
        final sameReply =
            position != null && _replyList[index].replyId == position.replyId;
        if (progress != null &&
            !sameReply &&
            _replyList[index].floorNumber != progress.floorNumber) {
          SmartDialog.showToast('原回复已变化，已定位到附近楼层');
        }
        final positioned = await _positionAt(index,
            offset: earlier && sameReply ? position.offsetWithinReply : 0);
        if (active() && !earlier && positioned) {
          setState(() {
            _highlightedFloor = _replyList[index].floorNumber;
            _highlightVersion++;
          });
        }
      } catch (_) {
        if (active()) SmartDialog.showToast('定位失败，已保留当前内容，请重试');
      } finally {
        if (mounted && topicId == id && _requests.accepts(generation)) {
          setState(() => _isJumping = false);
        }
      }
    }, refresh: true);
  }

  Future<void> getDetailInit({bool userRefresh = false}) async {
    await _loadDetail(
        refresh: true, reversed: reverseSort, userRefresh: userRefresh);
    if (mounted && _detailModel != null) Read().add(_detailModel!);
  }

  Future<void> getDetail({dynamic type, bool prefetch = false}) => _loadDetail(
      refresh: type == 'init',
      reversed: reverseSort,
      prefetch: prefetch,
      userRefresh: type == 'init');

  Future<void> getDetailReverst({dynamic type, bool prefetch = false}) =>
      _loadDetail(
          refresh: type == 'init',
          reversed: true,
          prefetch: prefetch,
          userRefresh: type == 'init');

  Future<void> _loadDetail(
      {bool refresh = false,
      bool reversed = false,
      bool prefetch = false,
      bool userRefresh = false}) {
    if (_isJumping) return Future.value();
    if (ContentCache.scope != _progressScope) {
      _readingActivated = false;
      _resetReadingProgress();
    }
    final showRefreshToast = userRefresh && _detailModel != null;
    final id = topicId;
    if (id.isEmpty) return Future.value();
    final account = ContentCache.scope;
    final page = refresh
        ? (reversed ? _totalPage : _entryPage)
        : (reversed ? _currentPage : _currentPage + 1);
    if (page < 1 || (!refresh && page > _totalPage)) return Future.value();
    final key = ContentCache.key('topic:$id', 1);
    // Initialize before scheduling; a later end-of-list request may promote this
    // prefetch even before the deferred request callback has started.
    if (refresh || !_requests.isRunning) {
      _paginationDemanded = !refresh && !prefetch;
    } else if (!prefetch && !_paginationDemanded) {
      setState(() => _paginationDemanded = true);
    }
    return _requests.run((generation) async {
      bool active() =>
          mounted &&
          _requests.accepts(generation) &&
          topicId == id &&
          ContentCache.scope == account;
      if (!active()) return;
      setState(() {
        _isLoadingMore = true;
        _prefetchFailed = false;
        _detailError = null;
        _pageError = null;
      });
      void apply(TopicDetailModel model) {
        final replies = reversed
            ? model.replyList.reversed.toList()
            : List<ReplyItem>.of(model.replyList);
        setState(() {
          _detailModel = model;
          if (refresh || _replyList.isEmpty) {
            _replyList = replies;
            _loadedStartPage = page;
            _replyPages.clear();
          } else {
            final ids = _replyList.map((r) => r.replyId).toSet();
            _replyList.addAll(replies.where((r) => ids.add(r.replyId)));
          }
          _totalPage = model.totalPage;
          for (final reply in replies) {
            _replyPages[reply.replyId] = page;
          }
          _currentPage = reversed ? page - 1 : page;
          if (replyId.isNotEmpty) {
            final matches = model.replyList.where((r) => r.replyId == replyId);
            if (matches.isNotEmpty) {
              noticeFloorNumber = matches.first.floorNumber;
            }
          }
        });
      }

      final cached = page == 1 ? ContentCache.read(key) : null;
      if (_detailModel == null && cached?.data is TopicDetailModel) {
        apply(cached!.data);
      }
      try {
        final model = await _fetchPage(id, page);
        if (!active()) return;
        apply(model);
        await ContentCache.write(key, model, cacheReplies: page == 1);
        if (!active()) return;
        if (pinScrollHeight == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!active()) return;
            final box = listGlobalKey.currentContext?.findRenderObject();
            if (box is RenderBox) {
              pinScrollHeight = box.localToGlobal(Offset.zero).dy - 100;
            }
          });
          if (_entryLocationPending && noticeFloorNumber > 0) {
            _entryLocationPending = false;
            await _scrollToCounter();
          }
        }
        if (active() &&
            reversed &&
            refresh &&
            autoScrollController.hasClients &&
            pinScrollHeight != null) {
          await autoScrollController.animateTo(pinScrollHeight!,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut);
        }
      } catch (error) {
        if (!active()) return;
        setState(() {
          if (_detailModel == null) {
            _detailError = error.toString();
          } else if (!refresh) {
            _pageError = error.toString();
            _prefetchFailed = !_paginationDemanded;
          }
        });
        if (showRefreshToast) SmartDialog.showToast('刷新失败，已保留当前内容');
        if (!refresh && _detailModel != null && _paginationDemanded) {
          SmartDialog.showToast('加载失败，请上滑重试');
        }
      } finally {
        if (active()) setState(() => _isLoadingMore = false);
      }
    }, refresh: refresh);
  }

  void _listen() {
    _updateTitleVisibility();
    _updateReadingActions();
    if (_isJumping) return;
    if (_detailModel != null &&
        (!_requests.isRunning ||
            autoScrollController.position.extentAfter <= 72) &&
        (_pageError == null ||
            (_prefetchFailed &&
                autoScrollController.position.extentAfter <= 72)) &&
        _detailError == null &&
        autoScrollController.position.extentAfter <
            autoScrollController.position.viewportDimension * 1.5) {
      final prefetch = autoScrollController.position.extentAfter > 72;
      if (!reverseSort && _currentPage < _totalPage) {
        getDetail(prefetch: prefetch);
      }
      if (reverseSort && _currentPage > 0) getDetailReverst(prefetch: prefetch);
    }
  }

  void _updateTitleVisibility() {
    if (!autoScrollController.hasClients) return;
    if (autoScrollController.offset > 100 && !_visibleTitle) {
      _visibleTitle = true;
      titleStreamC.add(true);
    } else if (autoScrollController.offset <= 100 && _visibleTitle) {
      _visibleTitle = false;
      titleStreamC.add(false);
    }
  }

  void _updateReadingActions() {
    if (!autoScrollController.hasClients) return;
    final visible = autoScrollController.offset >
        autoScrollController.position.viewportDimension;
    if (visible == _showBackToTop) return;
    _showBackToTop = visible;
    backToTopStream.add(visible);
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
    logDebug('resultList: ${resultList[0].userName}');

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

  Future<ShareResult> onShareTopic() async {
    final box = context.findRenderObject() as RenderBox?;
    var result = await SharePlus.instance
        .share(ShareParams(
      text: 'https://www.v2ex.com/t/$topicId',
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    ))
        .whenComplete(() {
      logDebug("share completion block ");
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
                logDebug('54: $res');
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
    final index = ReadingProgress(
            replyId: replyId, floorNumber: noticeFloorNumber, page: _entryPage)
        .indexIn(_replyList);
    if (index != null && await _positionAt(index) && mounted) {
      setState(() {
        _highlightedFloor = _replyList[index].floorNumber;
        _highlightVersion++;
      });
    }
    // autoScrollController.highlight(5);
  }

  // 复制链接
  onCopyTopicLink() {
    Clipboard.setData(ClipboardData(text: 'https://www.v2ex.com/t/$topicId'));
  }

  void _scrollToTop() {
    if (!autoScrollController.hasClients) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!autoScrollController.hasClients) {
        return;
      }
      autoScrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _saveReadingProgress();
    WidgetsBinding.instance.removeObserver(this);
    _requests.invalidate();
    _topicSubscription?.dispose();
    _controller.dispose();
    autoScrollController.removeListener(_listen);
    autoScrollController.dispose();
    eventBus.off('topicReply');
    backToTopStream.close();
    titleStreamC.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) _saveReadingProgress();
        },
        child: Stack(
          children: [
            Scaffold(
              appBar: !expendAppBar
                  ? AppBar(
                      scrolledUnderElevation:
                          Breakpoints.mediumAndUp.isActive(context) ? 0 : 4,
                      centerTitle: false,
                      title: StreamBuilder(
                        stream: titleStreamC.stream,
                        initialData: _visibleTitle,
                        builder: (context, AsyncSnapshot snapshot) {
                          return AnimatedOpacity(
                            opacity: snapshot.data ? 1 : 0,
                            duration: const Duration(milliseconds: 300),
                            child: GestureDetector(
                              onTap: _scrollToTop,
                              child: Text(
                                _detailModel != null
                                    ? _detailModel!.topicTitle
                                    : '',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          );
                        },
                      ),
                      // actions: _detailModel != null ? appBarAction() : [],
                      actions: appBarAction(),
                    )
                  : null,
              body: _detailError != null && _detailModel == null
                  ? NetworkErrorPage(
                      message: '正文尚未缓存或更新失败，请联网后重试', onRetry: getDetailInit)
                  : _topicDetail == null && _detailModel == null
                      ? showLoading()
                      : Scrollbar(
                          radius: const Radius.circular(10),
                          controller: autoScrollController,
                          child: PullRefresh(
                            key: _globalKey,
                            onChildRefresh: () async =>
                                await getDetailInit(userRefresh: true),
                            // 上拉
                            onChildLoad: _pageError != null
                                ? null
                                : !reverseSort
                                    ? (_totalPage > 1 &&
                                            _currentPage < _totalPage
                                        ? () async => await getDetail()
                                        : null)
                                    : (_currentPage > 0
                                        ? () async => await getDetailReverst()
                                        : null),
                            currentPage: _currentPage,
                            totalPage: _totalPage,
                            ctr: _controller,
                            child: showRes(),
                          ),
                        ),
            ),
            Positioned(
              bottom: 18,
              right: 20,
              child: SafeArea(
                top: false,
                left: false,
                child: StreamBuilder<bool>(
                  stream: backToTopStream.stream,
                  initialData: _showBackToTop,
                  builder: (context, snapshot) => DetailReadingActions(
                    showBackToTop: snapshot.data ?? false,
                    onBackToTop: _scrollToTop,
                    onReply: _detailModel != null ? showReplySheet : null,
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  // Theme actions live in one menu; reading shortcuts stay near the thumb.
  List<Widget> appBarAction() {
    final model = _detailModel;
    Widget menuLabel(IconData icon, String text, {Color? color}) => Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 16),
            Flexible(
              child: Text(text,
                  style: color == null ? null : TextStyle(color: color)),
            ),
          ],
        );
    return [
      if (model != null)
        IconButton(
          onPressed: onFavTopic,
          tooltip: model.isFavorite ? '已收藏' : '收藏主题',
          icon: const Icon(Icons.bookmark_border_rounded),
          selectedIcon: Icon(Icons.bookmark_rounded,
              color: Theme.of(context).colorScheme.primary),
          isSelected: model.isFavorite,
        ),
      PopupMenuButton<SampleItem>(
        tooltip: '更多操作',
        enabled: model != null,
        position: PopupMenuPosition.under,
        onSelected: (action) {
          switch (action) {
            case SampleItem.thank:
              onThankTopic();
              break;
            case SampleItem.copy:
              onCopyTopicLink();
              break;
            case SampleItem.share:
              onShareTopic();
              break;
            case SampleItem.browse:
              Utils.openURL('https://www.v2ex.com/t/$topicId');
              break;
            case SampleItem.ignore:
              onIgnoreTopic();
              break;
            case SampleItem.report:
              onReportTopic();
              break;
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: SampleItem.thank,
            enabled: model != null && !model.isThank,
            child: menuLabel(
              model?.isThank == true
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              model?.isThank == true ? '已感谢' : '感谢主题',
              color: model?.isThank == true
                  ? Theme.of(context).colorScheme.primary
                  : null,
            ),
          ),
          PopupMenuItem(
            value: SampleItem.copy,
            child: menuLabel(Icons.link_rounded, '复制链接'),
          ),
          PopupMenuItem(
            value: SampleItem.share,
            child: menuLabel(Icons.share_outlined, I18nKeyword.topicShare.tr),
          ),
          PopupMenuItem(
            value: SampleItem.browse,
            child:
                menuLabel(Icons.language_rounded, I18nKeyword.openInBrowser.tr),
          ),
          const PopupMenuDivider(),
          PopupMenuItem(
            value: SampleItem.ignore,
            child: menuLabel(
                Icons.visibility_off_outlined, I18nKeyword.topicIgnore.tr),
          ),
          PopupMenuItem(
            value: SampleItem.report,
            child: menuLabel(Icons.report_outlined, I18nKeyword.topicReport.tr,
                color: Theme.of(context).colorScheme.error),
          ),
        ],
      ),
      const SizedBox(width: 12),
    ];
  }

  Widget showRes() {
    return LoadMoreRetry(
        hasError: _pageError != null,
        onRetry: () => reverseSort ? getDetailReverst() : getDetail(),
        child: NotificationListener<ScrollNotification>(
            onNotification: _onReadingScroll,
            child: CustomScrollView(
              key: _readingViewportKey,
              controller: autoScrollController,
              // key: listGlobalKey,
              slivers: [
                if (expendAppBar) ...[
                  SliverAppBar(
                    toolbarHeight: platform == 'android'
                        ? (MediaQuery.of(context).padding.top + 6)
                        : platform == 'ios'
                            ? MediaQuery.of(context).padding.top - 2
                            : kToolbarHeight,
                    expandedHeight:
                        kToolbarHeight + MediaQuery.of(context).padding.top,
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
                              initialData: _visibleTitle,
                              builder: (context, AsyncSnapshot snapshot) {
                                return AnimatedOpacity(
                                  opacity: snapshot.data ? 1 : 0,
                                  duration: const Duration(milliseconds: 300),
                                  child: GestureDetector(
                                    onTap: _scrollToTop,
                                    child: Text(
                                      _detailModel != null
                                          ? _detailModel!.topicTitle
                                          : '',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
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
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.6),
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
                                      if (res != null &&
                                          res['nodeDetail'].isNotEmpty) {
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
                if (_detailModel != null && _resumeProgress != null)
                  SliverToBoxAdapter(
                    child: ListTile(
                      dense: true,
                      leading:
                          const Icon(Icons.bookmark_border_rounded, size: 20),
                      title: Text('上次读到第 ${_resumeProgress!.floorNumber} 楼'),
                      trailing: TextButton(
                        onPressed: _isJumping
                            ? null
                            : () => _jumpReplies(progress: _resumeProgress),
                        child: Text(_isJumping ? '定位中…' : '继续阅读'),
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
                              Row(mainAxisSize: MainAxisSize.min, children: [
                                TextButton(
                                  onPressed: _isJumping
                                      ? null
                                      : () => _jumpReplies(latest: true),
                                  child: const Text('最新回复'),
                                ),
                                if (_replyList.length > 2) ...[
                                  RawChip(
                                    side: BorderSide.none,
                                    showCheckmark: false,
                                    labelPadding: const EdgeInsets.only(
                                        left: 1, right: 4),
                                    label: Text(
                                      '倒序查看',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge,
                                    ),
                                    avatar: const Icon(
                                      Icons.swap_vert,
                                      size: 19,
                                    ),
                                    onPressed: () => setState(() {
                                      if (_isJumping) return;
                                      _saveReadingProgress();
                                      _readingActivated = false;
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
                                              .surfaceContainerHighest),
                                    ),
                                    selectedColor: Theme.of(context)
                                        .colorScheme
                                        .outlineVariant,
                                    selected: reverseSort,
                                  ),
                                ]
                              ]),
                            ],
                          ),
                        ),
                      ),
                      pinned: true,
                    ),
                    if (!reverseSort && _loadedStartPage > 1)
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
                                TextButton(
                                  onPressed: _isJumping
                                      ? null
                                      : () => _jumpReplies(earlier: true),
                                  child: Text(
                                      '查看更早回复（前 ${_loadedStartPage - 1} 页）'),
                                ),
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
                              key: ValueKey(_replyList[index].replyId),
                              controller: autoScrollController,
                              index: index,
                              child:
                                  // noticeFloorNumber > 0 && index == 0 ? Text('123') :
                                  ReplyListItem(
                                reply: _replyList[index],
                                topicId: _detailModel!.topicId,
                                totalPage: _totalPage,
                                key: ValueKey(_replyList[index].replyId),
                                queryReplyList: (replyMemberList, floorNumber,
                                        resultList, totalPage) =>
                                    queryReplyList(replyMemberList, floorNumber,
                                        resultList, _totalPage),
                                source: 'topic',
                                replyList: _replyList,
                                floorNumber: _highlightedFloor ?? 0,
                                highlightVersion: _highlightVersion,
                                consumeHighlight: _consumeHighlight,
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
                  if (_pageError == null &&
                      _isLoadingMore &&
                      _paginationDemanded &&
                      _currentPage > 0)
                    const SliverToBoxAdapter(child: LoadMoreLoading()),
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
            )));
  }

  // 底部 没有更多
  Widget moreTopic({type = 'noMore'}) {
    return Container(
      width: double.infinity,
      height: 150 + MediaQuery.of(context).padding.bottom,
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 90),
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
        color: Theme.of(context).colorScheme.surface,
        boxShadow: overlapsContent
            ? [
                BoxShadow(
                  color: Theme.of(context)
                      .colorScheme
                      .background
                      .withValues(alpha: 0.15),
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
