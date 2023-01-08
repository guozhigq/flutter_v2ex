import 'package:flutter/material.dart';
import 'package:flutter_v2ex/http/dio_web.dart';

import 'package:flutter_v2ex/models/web/item_tab_topic.dart';
import 'package:flutter_v2ex/components/home/list_item.dart';

class TabBarList extends StatefulWidget {
  const TabBarList(this.tabItem, {super.key});
  final Map<dynamic, dynamic> tabItem;

  @override
  State<TabBarList> createState() => _TabBarListState();
}

class _TabBarListState extends State<TabBarList>
    with AutomaticKeepAliveClientMixin {
  late Future<List<TabTopicItem>> topicListFuture;
  late final ScrollController _controller;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    topicListFuture = getTopics();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<List<TabTopicItem>> getTopics() async {
    var id = widget.tabItem['id'] ?? 'all';
    return await DioRequestWeb.getTopicsByTabKey(id, 0);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder<List<TabTopicItem>>(
      future: topicListFuture,
      builder: (context, snapshot) {
        Widget widget;
        if (snapshot.hasError) {
          widget = const Icon(
            Icons.error,
            color: Colors.red,
            size: 48,
          );
        }
        if (snapshot.hasData) {
          widget = showRes(snapshot);
        } else {
          widget = showLoading();
        }
        return widget;
      },
    );
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
            topicListFuture = getTopics();
          });
          return topicListFuture;
        },
        child: ListView.builder(
          padding: const EdgeInsets.only(top: 1, bottom: 0),
          physics: const ClampingScrollPhysics(), //重要
          itemCount: snapshot.data?.length,
          itemBuilder: (BuildContext context, int index) {
            return ListItem(topic: snapshot.data![index]);
          },
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
