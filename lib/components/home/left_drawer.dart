import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_v2ex/utils/string.dart';
import 'package:flutter_v2ex/utils/storage.dart';
import 'package:flutter_v2ex/utils/event_bus.dart';

class HomeLeftDrawer extends StatefulWidget {
  const HomeLeftDrawer({super.key});

  @override
  State<HomeLeftDrawer> createState() => _HomeLeftDrawerState();
}

class _HomeLeftDrawerState extends State<HomeLeftDrawer> {
  bool loginStatus = false;
  int selectedIndex = 99;
  ThemeType? tempThemeValue = ThemeType.system;
  ThemeType? currentThemeValue = ThemeType.system;

  void onDestinationSelected(int index) async{
    if (!loginStatus) {
      if (index == 0) {
        // 热议
        Get.toNamed(listTitleMap_0[0]['path']);
      }
      if (index == 1) {
        // 选择主题
        setState(() {
          tempThemeValue = currentThemeValue;
        });
        themeDialog();
      }
      if (index == 2) {
        // 设置
        Get.toNamed('/setting');
      }
      if (index == 3) {
        // 帮助
        Get.toNamed('/help');
      }
    } else {
      if(index == 0) {
        Get.toNamed(listTitleMap_0[0]['path']);
      }else
      if (index < 6 ) {
        // 用户权限
        Get.toNamed(listTitleMap[index-1]['path']);
      }
      if (index == 6) {
        // 选择主题
        setState(() {
          tempThemeValue = currentThemeValue;
        });
        themeDialog();
      }
      if (index == 7) {
        // 设置
        Get.toNamed('/setting');
      }
      if (index == 8) {
        // 帮助
        Get.toNamed('/help');
      }
    }
  }

  void themeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('选择主题'),
          contentPadding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
          content: StatefulBuilder(builder: (context, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile(
                  value: ThemeType.light,
                  title: Text('浅色',
                      style: Theme.of(context).textTheme.titleMedium),
                  groupValue: tempThemeValue,
                  onChanged: (ThemeType? value) {
                    setState(() {
                      tempThemeValue = value;
                    });
                  },
                ),
                RadioListTile(
                  value: ThemeType.dark,
                  title: Text('深色',
                      style: Theme.of(context).textTheme.titleMedium),
                  groupValue: tempThemeValue,
                  onChanged: (ThemeType? value) {
                    setState(() {
                      tempThemeValue = value;
                    });
                  },
                ),
                RadioListTile(
                  value: ThemeType.system,
                  title: Text('系统默认设置',
                      style: Theme.of(context).textTheme.titleMedium),
                  groupValue: tempThemeValue,
                  onChanged: (ThemeType? value) {
                    setState(() {
                      tempThemeValue = value;
                    });
                  },
                ),
              ],
            );
          }),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('取消')),
            TextButton(
                onPressed: () {
                  setState(() {
                    currentThemeValue = tempThemeValue;
                  });
                  eventBus.emit('themeChange', currentThemeValue);
                  Navigator.pop(context);
                },
                child: const Text('确定'))
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    // 获取登录状态
    loginStatus = GStorage().getLoginStatus();
    eventBus.on('login', (arg) {
      if (arg != null && arg != 'success') {
        GStorage().setLoginStatus(false);
        setState(() {
          loginStatus = false;
        });
      }
    });
    // 读取默认主题配置
    currentThemeValue = GStorage().getSystemType();
  }

  List<Map<dynamic, dynamic>> listTitleMap_0 = [
    {
      'leading': const Icon(Icons.whatshot_outlined),
      'title': '今日热议',
      'path': '/hot'
    },
  ];
  List<Map<dynamic, dynamic>> listTitleMap = [
    {
      'leading': const Icon(Icons.favorite_outline),
      'title': '我的关注',
      'path': '/my/following'
    },
    {
      'leading': const Icon(Icons.star_border_rounded),
      'title': '我的收藏',
      'path': '/my/topics'
    },
    {
      'leading': const Icon(Icons.notifications_none),
      'title': '消息提醒',
      'path': '/notifications'
    },
    {
      'leading': const Icon(Icons.edit_note_outlined),
      'title': '发布主题',
      'path': '/write'
    },
    {
      'leading': const Icon(Icons.history_outlined),
      'title': '最近浏览',
      'path': '/history'
    },
  ];

  List<Map<dynamic, dynamic>> listTitleMap_2 = [
    {'leading': const Icon(Icons.brightness_medium_rounded), 'title': '选择主题'},
    {
      'leading': const Icon(Icons.tune_outlined),
      'title': '设置',
      'path': '/setting'
    },
    {
      'leading': const Icon(Icons.help_outline_outlined),
      'title': '帮助',
      'path': '/help'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return NavigationDrawer(
      onDestinationSelected: onDestinationSelected,
      selectedIndex: selectedIndex,
      children: [
        Container(
          padding: const EdgeInsets.only(
            top: 10,
            left: 35,
            bottom: 20,
          ),
          child: Text('VVEX', style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        ),
        for (var i in listTitleMap_0)
          NavigationDrawerDestination(
            icon: i['leading'],
            label: Text(i['title']),
          ),
        if (loginStatus) ...[
          for (var i in listTitleMap)
            NavigationDrawerDestination(
              icon: i['leading'],
              label: Text(i['title']),
            ),
        ],
        Divider(
          color: Theme.of(context).dividerColor.withOpacity(0.15),
          indent: 20,
          endIndent: 12,
        ),
        for (var i in listTitleMap_2)
          NavigationDrawerDestination(
            icon: i['leading'],
            label: Text(i['title']),
          ),
      ],
    );
  }
}
