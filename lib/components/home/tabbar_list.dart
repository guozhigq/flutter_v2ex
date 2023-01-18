import 'package:flutter/material.dart';
import 'package:flutter_v2ex/http/dio_web.dart';

import 'package:flutter_v2ex/models/web/item_tab_topic.dart';
import 'package:flutter_v2ex/components/home/list_item.dart';
import 'package:flutter_v2ex/components/common/skeleton.dart';

class TabBarList extends StatefulWidget {
  const TabBarList(this.tabItem, {super.key});
  final Map<dynamic, dynamic> tabItem;

  @override
  State<TabBarList> createState() => _TabBarListState();
}

class _TabBarListState extends State<TabBarList>
    with AutomaticKeepAliveClientMixin {
  late final ScrollController _controller;
  List<TabTopicItem>? topicList;
  bool isLoading = true; // 请求状态

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    getTopics();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future getTopics() async {
    var id = widget.tabItem['id'] ?? 'all';
    var type = widget.tabItem['type'] ?? 'all';
    var res = await DioRequestWeb.getTopicsByTabKey(type, id, 1);
    setState(() {
      topicList = res;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return isLoading
        ? Skeleton(
            isLoading: true,
            child: buildSkeleton(),
          )
        : topicList != null && topicList!.isNotEmpty
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
          return getTopics();
        },
        child: ListView.builder(
          padding: const EdgeInsets.only(top: 1, bottom: 0),
          physics: const AlwaysScrollableScrollPhysics(), //重要
          itemCount: snapshot.length + 1,
          // prototypeItem: ListItem(topic: snapshot[0]),
          itemBuilder: (BuildContext context, int index) {
            if (index == snapshot.length) {
              return moreTopic();
            } else {
              return ListItem(topic: snapshot[index]);
            }
          },
        ),
      ),
    );
  }

  Widget moreTopic() {
    return Container(
      width: double.infinity,
      height: 80 + MediaQuery.of(context).padding.bottom,
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 10),
      child: const Center(
          // child: ElevatedButton(
          //   onPressed: () => {},
          //   child: const Text('更多相关主题'),
          // ),
          child: Text('全部加载完成')),
    );
  }

  Widget buildSkeleton() {
    List<Widget> list = [];
    int count = MediaQuery.of(context).size.height ~/ 110;
    var arr = List.filled(count, 1, growable: false);

    Widget content;
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
