import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_v2ex/http/dio_web.dart';

import 'package:flutter_v2ex/models/web/item_tab_topic.dart';
import 'package:flutter_v2ex/components/home/list_item.dart';
import 'package:flutter_v2ex/components/common/skeleton.dart';

class TabBarList extends StatefulWidget {
  final Map<dynamic, dynamic> tabItem;
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

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // _controller = ScrollController();
    getTopics();
    if (widget.tabItem['id'] == 'recent') {
      _controller.addListener(() {
        if (_controller.position.pixels >=
            _controller.position.maxScrollExtent) {
          if (!_isLoadingMore) {
            setState(() {
              _isLoadingMore = true;
            });
            getTopics();
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future getTopics() async {
    var id = widget.tabItem['id'] ?? 'all';
    var type = widget.tabItem['type'] ?? 'all';
    var res = await DioRequestWeb.getTopicsByTabKey(type, id, _currentPage + 1);
    setState(() {
      if (_currentPage == 0) {
        topicList = res;
        tempTopicList = res;
      } else {
        // 去除重复数据
        List<TabTopicItem> result = List.from(res);
        for (var i in tempTopicList) {
          for (var j in res) {
            if (j.topicId == i.topicId) {
              result.removeAt(res.indexOf(j));
            }
          }
        }
        print(result[0]);
        topicList.addAll(result);
        tempTopicList = result;
      }
      _isLoading = false;
      Timer(const Duration(milliseconds: 500), () {
        _isLoadingMore = false;
      });
      _currentPage += 1;
    });
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
        ? Skeleton(
            isLoading: true,
            child: buildSkeleton(),
          )
        : topicList.isNotEmpty
            ? showRes(topicList)
            : emptyData();
  }

  Widget showRes(snapshot) {
    return Container(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(right: 12, top: 8, left: 12),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      child: RefreshIndicator(
        onRefresh: () {
          setState(() {
            _currentPage = 0;
          });
          return getTopics();
        },
        child: ListView.builder(
          padding: const EdgeInsets.only(top: 1, bottom: 0),
          physics: const AlwaysScrollableScrollPhysics(), //重要
          itemCount: snapshot.length + 1,
          controller: _controller,
          // prototypeItem: ListItem(topic: snapshot[0]),
          itemBuilder: (BuildContext context, int index) {
            if (index == snapshot.length) {
              if (widget.tabItem['id'] == 'recent') {
                // return moreTopic('正在加载更多...');
                return Container(
                  padding: const EdgeInsets.all(30),
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2.0),
                  ),
                );
              } else {
                return moreTopic('全部加载完成');
              }
            } else {
              return ListItem(topic: snapshot[index]);
            }
          },
        ),
      ),
    );
  }

  Widget moreTopic(text) {
    return Container(
      width: double.infinity,
      height: 80 + MediaQuery.of(context).padding.bottom,
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 10),
      child: Center(
          // child: ElevatedButton(
          //   onPressed: () => {},
          //   child: const Text('更多相关主题'),
          // ),
          child: Text(text)),
    );
  }

  Widget buildSkeleton() {
    List<Widget> list = [];
    int count = MediaQuery.of(context).size.height ~/ 110;
    var arr = List.filled(count, 1, growable: false);

    Widget content;
    // ignore: unused_local_variable
    for (int i in arr) {
      list.add(skeletonItem());
    }
    content = ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: arr.length,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        return skeletonItem();
      },
    );
    return content;
  }

  Widget skeletonItem() {
    var commonColor = Theme.of(context).colorScheme.surfaceVariant;

    return Container(
      // height: 108,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).colorScheme.onInverseSurface,
      ),
      margin: const EdgeInsets.only(top: 8, right: 12, bottom: 0, left: 12),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 33,
                    height: 33,
                    decoration: BoxDecoration(
                      color: commonColor,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    clipBehavior: Clip.antiAlias,
                    margin: const EdgeInsets.only(right: 10),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 80,
                        height: 10,
                        margin: const EdgeInsets.only(bottom: 6),
                        color: commonColor,
                      ),
                      Row(
                        children: [
                          Container(
                            width: 35,
                            height: 10,
                            color: commonColor,
                          ),
                          const SizedBox(width: 4),
                          Container(
                            width: 30,
                            height: 10,
                            color: commonColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                width: 55,
                height: 21,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: commonColor,
                ),
              ),
            ],
          ),
          Container(
            width: 300,
            height: 12,
            margin: const EdgeInsets.only(top: 12, bottom: 3),
            color: commonColor,
          ),
        ],
      ),
    );
    // );
  }

  Widget emptyData() {
    return const Center(
      child: Text('没有数据，看看其他节点吧'),
    );
  }
}
