import 'package:flutter/material.dart';
import 'package:flutter_v2ex/http/dio_web.dart';

import 'package:flutter_v2ex/components/home/search_bar.dart';
import 'package:flutter_v2ex/components/home/sticky_bar.dart';
import 'package:flutter_v2ex/components/home/tabbar_list.dart';
import 'package:flutter_v2ex/models/web/item_tab_topic.dart';

class MinePage extends StatefulWidget {
  const MinePage({super.key});

  @override
  State<MinePage> createState() => _MinePageState();
}

class _MinePageState extends State<MinePage> {
  // 自定义、 缓存 、 api获取
  List<Map<dynamic, dynamic>> tabs = [
    {'name': '全部', 'id': 'all'},
    {'name': '最热', 'id': 'hot'},
    {'name': '技术', 'id': 'tech'},
    {'name': '创意', 'id': 'creative'},
    {'name': '好玩', 'id': 'play'},
    {'name': 'APPLE', 'id': 'apple'},
    {'name': '酷工作', 'id': 'jobs'},
    {'name': '交易', 'id': 'deals'},
    {'name': '城市', 'id': 'city'},
    {'name': '问与答', 'id': 'qna'},
    {'name': 'R2', 'id': 'r2'},
  ];
  late Future<List<TabTopicItem>> topicListFuture;

  @override
  void initState() {
    super.initState();
    topicListFuture = getTopics();
  }

  Future<List<TabTopicItem>> getTopics() async {
    return await DioRequestWeb.getTopicsByTabKey('all', 0);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
        body: Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          child: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                const SliverToBoxAdapter(
                  child: HomeSearchBar(),
                ),
                HomeStickyBar(tabs: tabs),
              ];
            },
            body: TabBarView(
              children: tabs.map((e) {
                return TabBarList(e);
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
