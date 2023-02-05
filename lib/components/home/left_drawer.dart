import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_v2ex/components/common/avatar.dart';
import 'package:flutter_v2ex/http/dio_web.dart';
import 'package:flutter_v2ex/utils/event_bus.dart';
import 'package:flutter_v2ex/utils/string.dart';

class HomeLeftDrawer extends StatefulWidget {
  const HomeLeftDrawer({super.key});

  @override
  State<HomeLeftDrawer> createState() => _HomeLeftDrawerState();
}

class _HomeLeftDrawerState extends State<HomeLeftDrawer> {
  String selectedId = '1';
  int selectedIndex = 99;
  Map<dynamic, dynamic>? signDetail;
  ThemeType? tempThemeValue = ThemeType.system;
  ThemeType? currentThemeValue = ThemeType.system;

  void onDestinationSelected(int index) {
    if (index == 1) {
      Navigator.pushNamed(context, '/fav');
    }
    if (index == 2) {
      Navigator.pushNamed(context, '/message');
    }
    if (index == 3) {
      print('_character: $tempThemeValue');
    }
    if (index == 5) {
      setState(() {
        tempThemeValue = currentThemeValue;
      });
      themeDialog();
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
    // queryDaily();
  }

  // 查询签到状态
  Future queryDaily() async {
    var res = await DioRequestWeb.queryDaily();
    setState(() {
      signDetail = res;
    });
  }

  List<Map<dynamic, dynamic>> listTitleMap = [
    {'leading': const Icon(Icons.favorite_outline), 'title': '我的关注'},
    {'leading': const Icon(Icons.star_border_rounded), 'title': '我的收藏'},
    {'leading': const Icon(Icons.notifications_none), 'title': '消息提醒'},
    {'leading': const Icon(Icons.edit_note_outlined), 'title': '发布主题'},
    {'leading': const Icon(Icons.history_outlined), 'title': '最近浏览'},
  ];

  List<Map<dynamic, dynamic>> listTitleMap_2 = [
    {'leading': const Icon(Icons.brightness_medium_rounded), 'title': '选择主题'},
    {'leading': const Icon(Icons.tune_outlined), 'title': '设置'},
    {'leading': const Icon(Icons.help_outline_outlined), 'title': '帮助'},
  ];

  @override
  Widget build(BuildContext context) {
    return NavigationDrawer(
      onDestinationSelected: onDestinationSelected,
      selectedIndex: selectedIndex,
      children: [
        Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 10,
            left: 25,
            bottom: 20,
          ),
          child: Text('VVex', style: Theme.of(context).textTheme.titleLarge),
        ),
        for (var i in listTitleMap)
          NavigationDrawerDestination(
            icon: i['leading'],
            label: Text(i['title']),
          ),
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

// Widget header() {
//   return DrawerHeader(
//     curve: Curves.bounceInOut,
//     child: Stack(
//       children: [
//         Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 20),
//             GestureDetector(
//               onTap: () => {Navigator.of(context).pushNamed('/login')},
//               child: const CAvatar(
//                 size: 65,
//                 url:
//                     'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fc-ssl.duitang.com%2Fuploads%2Fblog%2F202106%2F05%2F20210605015054_1afb0.thumb.1000_0.jpeg&refer=http%3A%2F%2Fc-ssl.duitang.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=auto?sec=1676034634&t=a66f33b968f7f967882d40e0a3bc3055',
//               ),
//             ),
//             // const SizedBox(height: 10),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Text(
//                   'guozhigq',
//                   style: Theme.of(context).textTheme.titleMedium,
//                 ),
//                 // Row(
//                 //   children: [
//                 //     Icon(
//                 //       Icons.auto_fix_high,
//                 //       size: 18,
//                 //       color: Theme.of(context).colorScheme.primary,
//                 //     ),
//                 //     const SizedBox(width: 5),
//                 //     Text(
//                 //       '领取登陆奖励',
//                 //       style: Theme.of(context)
//                 //           .textTheme
//                 //           .labelMedium!
//                 //           .copyWith(
//                 //               color: Theme.of(context).colorScheme.primary),
//                 //     ),
//                 //   ],
//                 // )
//                 if (signDetail != null) ...[
//                   TextButton(
//                     onPressed: () => {
//                       if (!signDetail!['signStatus'])
//                         {
//                           // 签到
//                           DioRequestWeb.dailyMission()
//                         }
//                     },
//                     child: Row(
//                       children: [
//                         Icon(
//                           !signDetail!['signStatus']
//                               ? Icons.auto_fix_high
//                               : Icons.done_all,
//                           size: 18,
//                           color: Theme.of(context).colorScheme.primary,
//                         ),
//                         const SizedBox(width: 5),
//                         Text(
//                           !signDetail!['signStatus']
//                               ? '领取登陆奖励'
//                               : signDetail!['signDays'],
//                           style: Theme.of(context)
//                               .textTheme
//                               .labelMedium!
//                               .copyWith(
//                                   color:
//                                       Theme.of(context).colorScheme.primary),
//                         ),
//                       ],
//                     ),
//                   )
//                 ] else ...[
//                   TextButton(
//                     onPressed: () => {},
//                     child: Row(
//                       children: [
//                         Icon(
//                           Icons.cached_sharp,
//                           size: 18,
//                           color: Theme.of(context).colorScheme.primary,
//                         ),
//                         const SizedBox(width: 5),
//                         Text(
//                           '稍等',
//                           style: Theme.of(context)
//                               .textTheme
//                               .labelMedium!
//                               .copyWith(
//                                   color:
//                                       Theme.of(context).colorScheme.primary),
//                         ),
//                       ],
//                     ),
//                   )
//                 ]
//               ],
//             ),
//             // const SizedBox(height: 8),
//           ],
//         ),
//         Positioned(
//           top: 0,
//           right: 0,
//           child: IconButton(
//             onPressed: (() => {
//                   // ignore: avoid_print
//                   print('夜间模式切换按钮')
//                 }),
//             icon: const Icon(Icons.brightness_medium_rounded),
//           ),
//         )
//       ],
//     ),
//   );
// }
}
