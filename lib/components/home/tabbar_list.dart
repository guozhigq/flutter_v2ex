// ignore_for_file: avoid_print

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:flutter_v2ex/components/common/footer.dart';
import 'package:flutter_v2ex/http/dio_web.dart';
import 'package:flutter_v2ex/models/tabs.dart';
import 'package:flutter_v2ex/utils/storage.dart';
import 'package:flutter_v2ex/utils/event_bus.dart';
import 'package:flutter_v2ex/models/web/item_tab_topic.dart';
import 'package:flutter_v2ex/components/home/list_item.dart';
import 'package:flutter_v2ex/components/common/skeleton_topic.dart';
import 'package:flutter_v2ex/components/common/network_error.dart';

class TabBarList extends StatefulWidget {
  final TabModel tabItem;

  const TabBarList(this.tabItem, {super.key});

  @override
  State<TabBarList> createState() => _TabBarListState();
}

class _TabBarListState extends State<TabBarList>
    with AutomaticKeepAliveClientMixin {
  late final ScrollController _controller = ScrollController();
  List<TabTopicItem> topicList = [];
  List<TabTopicItem> tempTopicList = []; // 临时话题列表
  bool _isLoading = true; // 请求状态
  bool _isLoadingMore = false; // 请求状态
  int _currentPage = 0;
  bool showBackTopBtn = false;
  bool _dioError = false;
  String _dioErrorMsg = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // _controller = ScrollController();
    getTopics();

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
      },
    );

    eventBus.on('ignoreTopic', (arg) => {print('69: $arg')});
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
          topicList = res;
          _dioError = false;
          tempTopicList = res;
        } else {
          // 去除重复数据
          List<TabTopicItem> result = List.from(res);
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
          // 确保dio完成了初始化
          // 登录状态自动签到
          DioRequestWeb.dailyMission();
        }
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
            margin: EdgeInsets.only(right: Breakpoints.mediumAndUp.isActive(context) ? 0 : 12, top: 8, left: 12),
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
                  // prototypeItem: ListItem(topic: snapshot[0]),
                  itemBuilder: (BuildContext context, int index) {
                    if (index == topicList.length) {
                      if (widget.tabItem.id == 'recent') {
                        return Container(
                          padding: const EdgeInsets.all(30),
                          child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onBackground,
                                          strokeWidth: 2.0)),
                                  const SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('加载中...',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelLarge),
                                      const SizedBox(height: 4),
                                      Text(
                                        '最后更新于刚刚',
                                        style:
                                        Theme.of(context).textTheme.bodySmall,
                                      )
                                    ],
                                  )
                                ],
                              )),
                        );
                      } else {
                        return const FooterTips();
                      }
                    } else {
                      return ListItem(
                          topic: topicList[index], key: UniqueKey());
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
                onPressed: () {
                  _controller.animateTo(0,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.ease);
                },
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
