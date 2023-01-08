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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('123'),
      ),
    );
  }
}
