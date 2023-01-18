import 'package:flutter/material.dart';
// import 'package:flutter_v2ex/http/dio_web.dart';

// import 'package:flutter_v2ex/models/web/item_tab_topic.dart';
// import 'package:flutter_v2ex/models/web/model_topic_fav.dart';
// import 'package:flutter_v2ex/models/web/model_node_fav.dart';
// import 'package:flutter_v2ex/components/home/list_item.dart';

import 'package:flutter_v2ex/components/fav/node_list.dart';
import 'package:flutter_v2ex/components/fav/topic_list.dart';

class FavPage extends StatefulWidget {
  const FavPage({super.key});

  @override
  State<FavPage> createState() => _FavPageState();
}

class _FavPageState extends State<FavPage> with AutomaticKeepAliveClientMixin {
  final List<Map<dynamic, dynamic>> tabsList = [
    {'name': '节点'},
    {'name': '主题'}
  ];

  // 页面缓存
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return DefaultTabController(
      length: tabsList.length,
      child: Scaffold(
        appBar: AppBar(title: const Text('我的收藏')),
        body: Column(
          children: [
            TabBar(
              onTap: (index) {},
              enableFeedback: true,
              splashBorderRadius: BorderRadius.circular(6),
              tabs: tabsList.map((item) {
                return Tab(text: item['name']);
              }).toList(),
            ),
            const Expanded(
              child: TabBarView(
                children: [FavNodeList(), FavTopicList()],
              ),
            )
          ],
        ),
      ),
    );
  }
}
