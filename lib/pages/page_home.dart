import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_v2ex/components/adaptive/resize_layout.dart';
import 'package:flutter_v2ex/components/adaptive/slide.dart';
import 'package:flutter_v2ex/models/web/item_tab_topic.dart';
import 'package:flutter_v2ex/pages/home/controller.dart';
import 'package:flutter_v2ex/pages/t/:topicId.dart';
import 'package:flutter_v2ex/pages/t/controller.dart';
import 'package:flutter_v2ex/utils/global.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_v2ex/http/dio_web.dart';
import 'package:flutter_v2ex/utils/storage.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:flutter_v2ex/components/home/search_bar.dart';
import 'package:flutter_v2ex/components/home/sticky_bar.dart';
import 'package:flutter_v2ex/components/home/tabBar_list.dart';
import 'package:flutter_v2ex/components/home/left_drawer.dart';
import 'package:flutter_v2ex/models/tabs.dart';
import 'package:flutter_v2ex/utils/event_bus.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  // 自定义、 缓存 、 api获取
  List<TabModel> tabs =
      GStorage().getTabs().where((item) => item.checked).toList();
  String shortcut = 'no action set';
  late TabController _tabController =
      TabController(vsync: this, length: tabs.length);
  final TopicController _topicController = Get.put(TopicController());
  String topicId = '';
  TabTopicItem _topicDetail = TabTopicItem();
  late final HomeController _homeController = Get.put(HomeController());
  late Stream<bool> stream;

  @override
  void initState() {
    super.initState();
    eventBus.on('editTabs', (args) {
      _loadCustomTabs();
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
        type: 'search',
        localizedTitle: '搜索',
        icon: 'icon_search',
      ),
    ]).then((void _) {
      setState(() {
        if (shortcut == 'no action set') {
          shortcut = 'actions ready';
        }
      });
    });
    // showPrivacyDialog();

    _topicController.topicId.listen((value) {
      if (mounted) {
        setState(() {
          topicId = value;
          _topicDetail = _topicController.topic.value;
        });
      }
    });

    stream = _homeController.searchBarStream.stream;
  }

  void _loadCustomTabs() {
    var customTabs =
        GStorage().getTabs().where((item) => item.checked).toList();

    setState(() {
      tabs.clear();
      tabs.addAll(customTabs);
      _tabController = TabController(length: tabs.length, vsync: this);
    });
  }

  showPrivacyDialog() async {
    await Future.delayed(const Duration(milliseconds: 200));
    SmartDialog.show(builder: (context) {
      TextStyle style = Theme.of(context).textTheme.titleMedium!;
      return AlertDialog(
        title: const Text('欢迎使用VVEX'),
        content: Text.rich(
          TextSpan(children: [
            TextSpan(
                text: '我们非常重视您的个人信息及隐私保护！ 在您使用我们的产品前，请务必认真阅读', style: style),
            // TextSpan(
            //   text: '《用户协议》',
            //   style: style.copyWith(
            //     color: Theme.of(context).colorScheme.primary,
            //   ),
            //   recognizer: TapGestureRecognizer()..onTap = onClickUser,
            // ),
            // TextSpan(text: '、', style: style),
            TextSpan(
              text: '《隐私政策》',
              style: style.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
              recognizer: TapGestureRecognizer()..onTap = onClickPrivacy,
            ),
            TextSpan(text: '相关内容。 \n', style: style),
            TextSpan(text: '如您同意以上协议内容，请点击“同意”，开始使用我们的产品和服务。', style: style),
          ]),
        ),
        actions: [
          TextButton(
              onPressed: () => SystemNavigator.pop(),
              child: const Text('不同意并退出')),
          TextButton(
              onPressed: () => SmartDialog.dismiss(), child: const Text('同意')),
        ],
      );
    });
  }

  onClickUser() {
    Get.toNamed('/agreement', parameters: {'source': 'user'});
  }

  onClickPrivacy() {
    Get.toNamed('/agreement', parameters: {'source': 'privacy'});
  }

  // 页面缓存
  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _topicController.removeListener(() {});
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    num height = MediaQuery.of(context).padding.top;
    GStorage().setStatusBarHeight(height);

    return Scaffold(
      backgroundColor: getBackground(context, 'homePage'),
      // appBar: Breakpoints.mediumAndUp.isActive(context)
      //     ? null
      //     : AppBar(
      //         automaticallyImplyLeading: false,
      //         title: const HomeSearchBar(),
      //       ),
      appBar: AppBar(toolbarHeight: 0, elevation: 0),
      drawer: Breakpoints.mediumAndUp.isActive(context)
          ? null
          : const HomeLeftDrawer(),
      body: ResizeLayout(
        leftLayout: Column(
          children: <Widget>[
            CustomAppBar(stream: stream),
            if (Breakpoints.mediumAndUp.isActive(context))
              const SizedBox(height: 13),
            HomeStickyBar(tabs: tabs, ctr: _tabController),
            const SizedBox(height: 3),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: tabs.map((e) {
                  return TabBarList(tabItem: e, tabIndex: tabs.indexOf(e));
                }).toList(),
              ),
            ),
          ],
        ),
        rightLayout: topicId == ''
            ? const AdaptSlide()
            : TopicDetail(topicDetail: _topicDetail),
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;
  final Stream<bool>? stream;

  const CustomAppBar({
    super.key,
    this.height = kToolbarHeight,
    this.stream,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: stream,
      initialData: true,
      builder: (context, AsyncSnapshot snapshot) {
        return AnimatedOpacity(
          opacity: snapshot.data ? 1 : 0,
          duration: const Duration(milliseconds: 300),
          child: AnimatedContainer(
            curve: Curves.easeInOutCubicEmphasized,
            duration: const Duration(milliseconds: 500),
            height: snapshot.data
                ? MediaQuery.of(context).padding.top + 52
                : MediaQuery.of(context).padding.top,
            child: Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: 2,
                top: MediaQuery.of(context).padding.top + 5,
              ),
              child: const HomeSearchBar(),
            ),
          ),
        );
      },
    );
  }
}

class HomeController extends GetxController {
  final StreamController<bool> searchBarStream =
      StreamController<bool>.broadcast();
}
