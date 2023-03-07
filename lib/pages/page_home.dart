import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_v2ex/http/dio_web.dart';
import 'package:flutter_v2ex/utils/storage.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:flutter_v2ex/components/home/search_bar.dart';
import 'package:flutter_v2ex/components/home/sticky_bar.dart';
import 'package:flutter_v2ex/components/home/tabbar_list.dart';
import 'package:flutter_v2ex/components/home/left_drawer.dart';
import 'package:flutter_v2ex/models/tabs.dart';
import 'package:flutter_v2ex/utils/event_bus.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  // 自定义、 缓存 、 api获取
  List<TabModel> tabs = GStorage()
      .getTabs()
      .where((item) => item.checked)
      .toList();
  String shortcut = 'no action set';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    eventBus.on('editTabs', (args) {
      setState(() {
        tabs = GStorage()
            .getTabs()
            .where((item) => item.checked)
            .toList();
      });
    });
    const QuickActions quickActions = QuickActions();
    quickActions.initialize((String shortcutType) {
      switch (shortcutType) {
        case 'hot':
          // 今日热议
          Get.toNamed('/hot');
          return;
        case 'sign':
          // 签到
          DioRequestWeb.dailyMission();
          return;
        case 'search':
          // 搜索
          Get.toNamed('/search');
      }
    });

    quickActions.setShortcutItems(<ShortcutItem>[
      // NOTE: This first action icon will only work on iOS.
      // In a real world project keep the same file name for both platforms.
      const ShortcutItem(
        type: 'hot',
        localizedTitle: '今日热门',
        icon: 'icon_hot',
      ),
      const ShortcutItem(
        type: 'sign',
        localizedTitle: '签到',
        icon: 'icon_sign',
      ),
      // NOTE: This second action icon will only work on Android.
      // In a real world project keep the same file name for both platforms.
      const ShortcutItem(
          type: 'search', localizedTitle: '搜索', icon: 'icon_search'),
    ]).then((void _) {
      setState(() {
        if (shortcut == 'no action set') {
          shortcut = 'actions ready';
        }
      });
    });
  }

  // 页面缓存
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    num height = MediaQuery.of(context).padding.top;
    GStorage().setStatusBarHeight(height);
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const HomeSearchBar(),
        ),
        drawer: const HomeLeftDrawer(),
        body: Column(
          children: <Widget>[
            HomeStickyBar(tabs: tabs),
            const SizedBox(height: 3),
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
