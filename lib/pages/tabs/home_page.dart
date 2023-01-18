import 'package:flutter/material.dart';
import 'package:flutter_v2ex/components/home/search_bar.dart';
// import 'package:flutter_v2ex/http/dio_web.dart';

// import 'package:flutter_v2ex/components/home/search_bar.dart';
import 'package:flutter_v2ex/components/home/sticky_bar.dart';
import 'package:flutter_v2ex/components/home/tabbar_list.dart';
import 'package:flutter_v2ex/components/home/left_drawer.dart';

// import 'package:flutter_v2ex/models/web/item_tab_topic.dart';

// plugin fix https://github.com/flutter/flutter/issues/36419
// import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  // 自定义、 缓存 、 api获取
  List<Map<dynamic, dynamic>> tabs = [
    {'name': '全部', 'id': 'all', 'type': 'tab'},
    {'name': '职场话题', 'id': 'career', 'type': 'go'},
    {'name': '最近', 'id': 'recent', 'type': 'recent'},
    {'name': '🔥最热', 'id': 'hot', 'type': 'tab'},
    {'name': '技术', 'id': 'tech', 'type': 'tab'},
    {'name': '创意', 'id': 'creative', 'type': 'tab'},
    {'name': '好玩', 'id': 'play', 'type': 'tab'},
    {'name': 'APPLE', 'id': 'apple', 'type': 'tab'},
    {'name': '酷工作', 'id': 'jobs', 'type': 'tab'},
    {'name': '交易', 'id': 'deals', 'type': 'tab'},
    {'name': '城市', 'id': 'city', 'type': 'tab'},
    {'name': '问与答', 'id': 'qna', 'type': 'tab'},
    {'name': 'R2', 'id': 'r2', 'type': 'tab'},
  ];

  // 页面缓存
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        // backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
        drawer: const HomeLeftDrawer(),
        body: Column(
          children: <Widget>[
            Container(
              // color: Theme.of(context).colorScheme.surfaceVariant,
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              child: const HomeSearchBar(),
            ),
            HomeStickyBar(tabs: tabs),
            Expanded(
              child: TabBarView(
                children: tabs.map((e) {
                  return TabBarList(e);
                }).toList(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
