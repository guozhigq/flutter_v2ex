// ignore_for_file: avoid_print

import 'dart:async';
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
  List<TabTopicItem> tempTopicList = []; // 临时话题列表
  List childNodeList = [];
  bool _isLoading = true; // 请求状态
  bool _isLoadingMore = false; // 请求状态
  int _currentPage = 0;
  bool showBackTopBtn = false;
  bool _dioError = false;
  String _dioErrorMsg = '';
  // late TabStateController? _tabStateController;
  final TabStateController _tabStateController = Get.put(TabStateController());
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
        if (widget.tabItem.id == 'recent') {
          if (_controller.position.pixels >=
              _controller.position.maxScrollExtent - 100) {
            if (!_isLoadingMore) {
              setState(() {
                _isLoadingMore = true;
              });
              getTopics();
            }
          }
        }

        var screenHeight = MediaQuery.of(context).size.height;
        if (_controller.offset >= screenHeight && showBackTopBtn == false) {
          setState(() {
            showBackTopBtn = true;
          });
        } else if (_controller.offset < screenHeight && showBackTopBtn) {
          setState(() {
            showBackTopBtn = false;
          });
        }

        final ScrollDirection direction =
            _controller.position.userScrollDirection;
        if (direction == ScrollDirection.forward) {
          homeStream.add(true);
        } else if (direction == ScrollDirection.reverse) {
          homeStream.add(false);
        }
      },
    );

    _tabStateController.tabIndex.listen((value) {
      if (value == widget.tabIndex) {
        animateToTop();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future getTopics() async {
    if (_currentPage == 0 && topicList.isEmpty) {
      // 没有数据时下拉，显示骨架屏
      setState(() {
        _isLoading = true;
      });
    }
    var id = widget.tabItem.id;
    var type = widget.tabItem.type;
    try {
      var res =
          await DioRequestWeb.getTopicsByTabKey(type, id, _currentPage + 1);
      setState(() {
        if (_currentPage == 0) {
          topicList = res['topicList'];
          _dioError = false;
          tempTopicList = res['topicList'];
          childNodeList = res['childNodeList'];
        } else {
          // 去除重复数据
          List<TabTopicItem> result = List.from(res['topicList']);
          try {
            for (var i in tempTopicList) {
              result.removeWhere((j) => j.topicId == i.topicId);
            }
          } catch (err) {
            print('list去重： $err');
          }
          topicList.addAll(result);
          tempTopicList = result;
          _dioError = false;
        }
        _isLoading = false;
        Timer(const Duration(milliseconds: 500), () {
          _isLoadingMore = false;
        });
        _currentPage += 1;

        var userInfo = GStorage().getUserInfo();
        if (userInfo.isNotEmpty) {
          // 登录状态自动签到 补充用
          DioRequestWeb.dailyMission();
        }

        _tabStateController.setActionCounts(res['actionCounts']);
        _tabStateController.setBalance(res['balance']);
      });
    } catch (err) {
      if (_currentPage == 0) {
        setState(() {
          _dioErrorMsg = err.toString();
          _dioError = true;
          _isLoading = false;
        });
      }
    }
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

  void animateToTop() async {
    await _controller.animateTo(0,
        duration: const Duration(milliseconds: 500), curve: Curves.ease);
    _tabStateController.setTabIndex(999);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _isLoading
        ? const TopicSkeleton()
        : _dioError
            ? NetworkErrorPage(
                message: _dioErrorMsg, onRetry: () => getTopics())
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
            child: RefreshIndicator(
              onRefresh: () {
                setState(() {
                  _currentPage = 0;
                });
                return getTopics();
              },
              // desktop ListView scrollBar
              child: ScrollConfiguration(
                behavior:
                    ScrollConfiguration.of(context).copyWith(scrollbars: false),
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
                      if (childNodeList.isNotEmpty) {
                        return ChildNodes(childNodeList: childNodeList);
                      } else {
                        return FooterTips(
                            type: widget.tabItem.id == 'recent'
                                ? 'loading'
                                : 'noMore');
                      }
                    } else {
                      return ListItem(
                        topic: topicList[index],
                        key: UniqueKey(),
                      );
                    }
                  },
                ),
              ),
            ),
          ),
        ),
        Positioned(
          right: 20,
          bottom: 20,
          child: AnimatedScale(
            scale: showBackTopBtn ? 1 : 0,
            curve: Curves.easeInOut,
            duration: const Duration(milliseconds: 300),
            child: GestureDetector(
              // 长按回顶刷新
              onLongPress: () {
                _controller.animateTo(0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.ease);
                setState(() {
                  _currentPage = 0;
                });
                getTopics();
              },
              child: FloatingActionButton(
                heroTag: null,
                child: const Icon(Icons.vertical_align_top_rounded),
                onPressed: () => animateToTop(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget emptyData() {
    return RefreshIndicator(
      onRefresh: () {
        setState(() {
          _currentPage = 0;
        });
        return getTopics();
      },
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
      color: Theme.of(context).primaryColor.withOpacity(0.1),
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
