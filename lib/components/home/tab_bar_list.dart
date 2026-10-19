// ignore_for_file: avoid_print

import 'dart:async';
import 'package:flutter_v2ex/service/content_cache.dart';
import 'package:flutter_v2ex/service/page_request.dart';
import 'package:flutter_v2ex/components/common/load_more_retry.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:flutter_v2ex/components/common/footer.dart';
import 'package:flutter_v2ex/http/dio_web.dart';
import 'package:flutter_v2ex/models/tabs.dart';
import 'package:flutter_v2ex/pages/page_home.dart';
import 'package:flutter_v2ex/models/web/item_tab_topic.dart';
import 'package:flutter_v2ex/components/home/list_item.dart';
import 'package:flutter_v2ex/components/common/skeleton_topic.dart';
import 'package:flutter_v2ex/components/common/network_error.dart';
import 'package:flutter_v2ex/utils/storage.dart';
import 'package:get/get.dart';
import 'package:flutter_v2ex/pages/home/controller.dart';

class TabBarList extends StatefulWidget {
  final TabModel tabItem;
  final int tabIndex;
  const TabBarList({
    Key? key,
    required this.tabItem,
    this.tabIndex = 0,
  }) : super(key: key);

  @override
  State<TabBarList> createState() => _TabBarListState();
}

class _TabBarListState extends State<TabBarList>
    with AutomaticKeepAliveClientMixin {
  late final ScrollController _controller = ScrollController();
  List<TabTopicItem> topicList = [];
  List childNodeList = [];
  bool _isLoading = true; // 请求状态
  bool _isLoadingMore = false; // 请求状态
  final _requests = PageRequest();
  bool _hasMore = true;
  String? _loadMoreError;
  bool _prefetchFailed = false;
  bool _paginationDemanded = false;
  int _currentPage = 0;
  bool showBackTopBtn = false;
  bool _isReturningToTop = false;
  bool _dioError = false;
  String _dioErrorMsg = '';
  // late TabStateController? _tabStateController;
  final TabStateController _tabStateController = Get.put(TabStateController());
  Worker? _tabSubscription;
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    // _tabStateController = Get.put(TabStateController());
    super.initState();
    // _controller = ScrollController();
    getTopics();
    StreamController<bool> homeStream =
        Get.find<HomeController>().searchBarStream;
    _controller.addListener(
      () {
        if (widget.tabItem.id == 'recent' &&
            _hasMore &&
            (!_requests.isRunning || _controller.position.extentAfter <= 72) &&
            (_loadMoreError == null ||
                (_prefetchFailed && _controller.position.extentAfter <= 72)) &&
            _controller.position.extentAfter <
                _controller.position.viewportDimension * 1.5) {
          getTopics(prefetch: _controller.position.extentAfter > 72);
        }

        var screenHeight = MediaQuery.of(context).size.height;
        if (!_isReturningToTop &&
            _controller.offset >= screenHeight &&
            showBackTopBtn == false) {
          setState(() {
            showBackTopBtn = true;
          });
        } else if (!_isReturningToTop &&
            _controller.offset < screenHeight &&
            showBackTopBtn) {
          setState(() {
            showBackTopBtn = false;
          });
        }

        final ScrollDirection direction =
            _controller.position.userScrollDirection;
        // Programmatic scrolling does not report a forward user gesture.
        if (_isReturningToTop ||
            _controller.offset <= _controller.position.minScrollExtent ||
            direction == ScrollDirection.forward) {
          homeStream.add(true);
        } else if (direction == ScrollDirection.reverse) {
          homeStream.add(false);
        }
      },
    );

    _tabSubscription = ever(_tabStateController.tabIndex, (int value) {
      if (value == widget.tabIndex) {
        animateToTop();
      }
    });
  }

  @override
  void dispose() {
    _requests.invalidate();
    _tabSubscription?.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant TabBarList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tabItem.id != widget.tabItem.id ||
        oldWidget.tabItem.type != widget.tabItem.type) {
      _requests.invalidate();
      topicList = [];
      childNodeList = [];
      _currentPage = 0;
      _hasMore = true;
      _dioError = false;
      getTopics(refresh: true);
    }
  }

  Future<void> getTopics({bool refresh = false, bool prefetch = false}) {
    final showRefreshToast = refresh && topicList.isNotEmpty;
    if (!refresh && !_hasMore) return Future.value();
    final account = ContentCache.scope;
    final page = refresh ? 1 : _currentPage + 1;
    final key = ContentCache.key(
        'home:${widget.tabItem.type}:${widget.tabItem.id}', page);
    // Initialize before scheduling; a later end-of-list request may promote this
    // prefetch even before the deferred request callback has started.
    if (refresh || !_requests.isRunning) {
      _paginationDemanded = !prefetch;
    } else if (!prefetch && !_paginationDemanded) {
      setState(() => _paginationDemanded = true);
    }
    return _requests.run((generation) async {
      bool active() =>
          mounted &&
          _requests.accepts(generation) &&
          ContentCache.scope == account;
      if (!active()) return;
      setState(() {
        _prefetchFailed = false;
        _isLoadingMore = true;
        _loadMoreError = null;
        if (topicList.isEmpty) _isLoading = true;
      });
      void apply(Map data) {
        final incoming = List<TabTopicItem>.from(data['topicList']);
        setState(() {
          if (page == 1) {
            topicList = List.of(incoming);
            childNodeList = List.from(data['childNodeList'] ?? []);
          } else {
            final ids = topicList.map((e) => e.topicId).toSet();
            topicList.addAll(incoming.where((e) => ids.add(e.topicId)));
          }
          _currentPage = page;
          _hasMore = widget.tabItem.id == 'recent' && incoming.isNotEmpty;
          _isLoading = false;
          _dioError = false;
        });
      }

      var cached = page == 1 ? ContentCache.read(key) : null;
      try {
        if (cached != null) {
          final data = cached.data as Map;
          List<TabTopicItem>.from(data['topicList']);
          List.from(data['childNodeList'] ?? []);
          if (page == 1 && topicList.isEmpty) {
            apply(data);
          }
        }
      } catch (_) {
        cached = null;
      }
      try {
        final res = await DioRequestWeb.getTopicsByTabKey(
            widget.tabItem.type, widget.tabItem.id, page,
            silent: true);
        if (!active()) return;
        apply(res as Map);
        if (page == 1) unawaited(ContentCache.write(key, res));
        _tabStateController.setActionCounts(res['actionCounts'] ?? []);
        _tabStateController.setBalance(res['balance'] ?? '');
        final user = GStorage().getUserInfo();
        if (page == 1 && user.isNotEmpty && GStorage().getAutoSign()) {
          DioRequestWeb.dailyMission();
        }
      } catch (error) {
        if (!active()) return;
        setState(() {
          _isLoading = false;
          if (topicList.isEmpty) {
            _dioError = true;
            _dioErrorMsg = error.toString();
          } else if (page > 1) {
            _loadMoreError = error.toString();
            _prefetchFailed = !_paginationDemanded;
          }
        });
        if (showRefreshToast) SmartDialog.showToast('刷新失败，已保留当前内容');
        if (page > 1 && _paginationDemanded) {
          SmartDialog.showToast('加载失败，请上滑重试');
        }
      } finally {
        if (active()) setState(() => _isLoadingMore = false);
      }
    }, refresh: refresh);
  }

  Future<List<TabTopicItem>> dateFormat(
      List<TabTopicItem> last, List<TabTopicItem> current) async {
    List<TabTopicItem> res = [];
    for (var i in last) {
      for (var j in current) {
        if (j.topicId != i.topicId) {
          res.add(j);
        }
      }
    }
    return res;
  }

  Future<void> animateToTop() async {
    Get.find<HomeController>().searchBarStream.add(true);
    if (!_controller.hasClients || _isReturningToTop) return;

    setState(() => _isReturningToTop = true);
    try {
      if (MediaQuery.disableAnimationsOf(context)) {
        _controller.jumpTo(_controller.position.minScrollExtent);
      } else {
        await _controller.animateTo(_controller.position.minScrollExtent,
            duration: const Duration(milliseconds: 500),
            curve: const Cubic(0.22, 1, 0.36, 1));
      }
    } finally {
      _isReturningToTop = false;
      if (mounted && _controller.hasClients) {
        setState(() {
          showBackTopBtn =
              _controller.offset >= MediaQuery.sizeOf(context).height;
        });
        _tabStateController.setTabIndex(999);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _isLoading
        ? const TopicSkeleton()
        : _dioError
            ? NetworkErrorPage(
                message: _dioErrorMsg, onRetry: () => getTopics(refresh: true))
            : topicList.isNotEmpty
                ? showRes()
                : emptyData();
  }

  Widget showRes() {
    return Stack(
      children: [
        Scrollbar(
          radius: const Radius.circular(10),
          controller: _controller,
          child: Container(
            clipBehavior: Clip.antiAlias,
            margin: EdgeInsets.only(
                right: Breakpoints.large.isActive(context) ? 0 : 12,
                top: 8,
                left: 12),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            child: LoadMoreRetry(
              hasError: _loadMoreError != null,
              onRetry: () => getTopics(),
              child: RefreshIndicator(
                onRefresh: () => getTopics(refresh: true),
                // desktop ListView scrollBar
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context)
                      .copyWith(scrollbars: false),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 1, bottom: 0),
                    physics: const AlwaysScrollableScrollPhysics(
                        // parent: BouncingScrollPhysics(), // iOS
                        parent: ClampingScrollPhysics() // Android
                        ),
                    //重要
                    itemCount: topicList.length + 1,
                    controller: _controller,
                    itemBuilder: (BuildContext context, int index) {
                      if (index == topicList.length) {
                        if (_loadMoreError != null) {
                          return const SizedBox(height: 48);
                        }
                        if (childNodeList.isNotEmpty) {
                          return ChildNodes(childNodeList: childNodeList);
                        } else {
                          return _hasMore
                              ? _isLoadingMore && _paginationDemanded
                                  ? const LoadMoreLoading()
                                  : const SizedBox(height: 48)
                              : const FooterTips(type: 'noMore');
                        }
                      } else {
                        return ListItem(
                          topic: topicList[index],
                          key: ValueKey(topicList[index].topicId),
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          right: 20,
          bottom: 20,
          child: IgnorePointer(
            ignoring: !showBackTopBtn || _isReturningToTop,
            child: AnimatedOpacity(
              opacity: showBackTopBtn ? 1 : 0,
              duration: Duration(
                  milliseconds:
                      MediaQuery.disableAnimationsOf(context) ? 0 : 180),
              child: AnimatedScale(
                scale: showBackTopBtn ? 1 : 0.65,
                curve: Curves.easeOut,
                duration: Duration(
                    milliseconds:
                        MediaQuery.disableAnimationsOf(context) ? 0 : 220),
                child: GestureDetector(
                  // 长按回顶刷新，与点击共用顶部栏恢复逻辑。
                  onLongPress: () async {
                    await animateToTop();
                    if (mounted) getTopics(refresh: true);
                  },
                  child: FloatingActionButton(
                    heroTag: null,
                    tooltip: '返回顶部',
                    onPressed: animateToTop,
                    child: const Icon(Icons.vertical_align_top_rounded),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget emptyData() {
    return RefreshIndicator(
      onRefresh: () => getTopics(refresh: true),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 150),
          Center(
            child: Text('没有数据，下拉刷新看看'),
          )
        ],
      ),
    );
  }
}

class ChildNodes extends StatelessWidget {
  final List childNodeList;
  const ChildNodes({Key? key, required this.childNodeList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var line = Expanded(
        child: Divider(
      color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
    ));

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 25),
          Container(
            width: double.infinity,
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                line,
                const SizedBox(width: 8),
                Text('相关节点', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(width: 8),
                line
              ],
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            children: [
              for (var i in childNodeList)
                TextButton(
                    onPressed: () async {
                      await Future.delayed(const Duration(milliseconds: 200));
                      Get.toNamed('/go/${i['nodeId']}');
                    },
                    child: Text(i['nodeName']))
            ],
          ),
        ],
      ),
    );
  }
}
