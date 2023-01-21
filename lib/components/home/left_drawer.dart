import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_v2ex/components/common/avatar.dart';
import 'package:flutter_v2ex/http/dio_web.dart';
// import 'package:flutter_v2ex/components/home/list_item.dart';

class HomeLeftDrawer extends StatefulWidget {
  const HomeLeftDrawer({super.key});

  @override
  State<HomeLeftDrawer> createState() => _HomeLeftDrawerState();
}

class _HomeLeftDrawerState extends State<HomeLeftDrawer> {
  String selectedId = '1';
  int selectedIndex = 99;
  Map<dynamic, dynamic>? signDetail;

  void onDestinationSelected(int index) {
    setState(() {
      selectedIndex = index;
    });
    if (selectedIndex == 1) {
      Navigator.pushNamed(context, '/fav');
    }
  }

  @override
  void initState() {
    super.initState();
    queryDaily();
  }

  // 查询签到状态
  Future queryDaily() async {
    var res = await DioRequestWeb.queryDaily();
    setState(() {
      signDetail = res;
    });
  }

  List<Map<dynamic, dynamic>> listTitleMap = [
    {
      'id': '1',
      'leading': const Icon(Icons.favorite_outline),
      'title': '我的关注',
      'route': '',
      'trailing': null
    },
    {
      'id': '2',
      'leading': const Icon(Icons.star_border_rounded, size: 27),
      'title': '我的收藏',
      'route': '/fav',
      'trailing': null
    },
    {
      'id': '3',
      'leading': const Icon(Icons.messenger_outline),
      'title': '消息提醒',
      'route': '/message',
      'trailing': const Icon(Icons.notifications_none)
    },
    {
      'id': '4',
      'leading': const Icon(Icons.edit_note_outlined, size: 27),
      'title': '发布主题',
      'route': '',
      'trailing': null
    },
    {
      'id': '5',
      'leading': const Icon(Icons.history_outlined),
      'title': '最近浏览',
      'route': '',
      'trailing': null
    },
  ];

  List<Map<dynamic, dynamic>> listTitleMap_2 = [
    {
      'id': '6',
      'leading': const Icon(Icons.settings),
      'title': '设置',
      'route': '',
      'trailing': null
    },
    {
      'id': '7',
      'leading': const Icon(Icons.help_outline_outlined),
      'title': '帮助',
      'route': '',
      'trailing': null
    },
  ];

  @override
  Widget build(BuildContext context) {
    // return Material(
    //   clipBehavior: Clip.hardEdge,
    //   elevation: 1,
    //   borderRadius: const BorderRadius.only(
    //     topLeft: Radius.circular(0),
    //     topRight: Radius.circular(16),
    //     bottomRight: Radius.circular(16),
    //     bottomLeft: Radius.circular(0),
    //   ),
    //   // color: Theme.of(context).colorScheme.surface,
    //   child: Drawer(
    //     width: MediaQuery.of(context).size.width * 0.75,
    //     child: ListView(
    //       children: [
    //         header(),
    //         const SizedBox(height: 5),
    //         RawChip(
    //           labelPadding: const EdgeInsets.only(left: 1, right: 10),
    //           padding: const EdgeInsets.only(left: 3),
    //           label: Text(
    //             '有新回复',
    //             style: Theme.of(context)
    //                 .textTheme
    //                 .titleSmall!
    //                 .copyWith(color: Theme.of(context).colorScheme.primary),
    //           ),
    //           avatar: Icon(
    //             Icons.notifications_none,
    //             color: Theme.of(context).colorScheme.primary,
    //             size: 19,
    //           ),
    //           onPressed: () => setState(() {}),
    //           shape: StadiumBorder(
    //               side: BorderSide(
    //                   color: Theme.of(context).colorScheme.surfaceVariant)),
    //           selectedColor: Theme.of(context).colorScheme.onInverseSurface,
    //           showCheckmark: false,
    //         ),
    //         buildActionOne(),
    //         Divider(
    //           indent: 20,
    //           endIndent: 20,
    //           color: Theme.of(context).dividerColor.withOpacity(0.15),
    //         ),
    //         buildActionTwo(),
    //       ],
    //     ),
    //   ),
    // );
    return NavigationDrawer(
      onDestinationSelected: onDestinationSelected,
      selectedIndex: selectedIndex,
      children: [
        // SizedBox(height: MediaQuery.of(context).padding.top + 20),
        Container(
          padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 10,
              left: 25,
              bottom: 20),
          child: Text(
            'VVex',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.favorite_border),
          label: Text('我的关注'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.star_border_rounded),
          label: Text('我的收藏'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.messenger_outline),
          label: Text('消息提醒'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.edit_note_outlined),
          label: Text('发布主题'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.history_outlined),
          label: Text('最近浏览'),
        ),
        Divider(),
        const NavigationDrawerDestination(
          icon: Icon(Icons.brightness_medium_rounded),
          label: Text('选择主题'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.edit_note_outlined),
          label: Text('设置'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.help_outline_outlined),
          label: Text('帮助'),
        ),
      ],
    );
  }

  Widget header() {
    return DrawerHeader(
      curve: Curves.bounceInOut,
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => {Navigator.of(context).pushNamed('/login')},
                child: const CAvatar(
                  size: 65,
                  url:
                      'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fc-ssl.duitang.com%2Fuploads%2Fblog%2F202106%2F05%2F20210605015054_1afb0.thumb.1000_0.jpeg&refer=http%3A%2F%2Fc-ssl.duitang.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=auto?sec=1676034634&t=a66f33b968f7f967882d40e0a3bc3055',
                ),
              ),
              // const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'guozhigq',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  // Row(
                  //   children: [
                  //     Icon(
                  //       Icons.auto_fix_high,
                  //       size: 18,
                  //       color: Theme.of(context).colorScheme.primary,
                  //     ),
                  //     const SizedBox(width: 5),
                  //     Text(
                  //       '领取登陆奖励',
                  //       style: Theme.of(context)
                  //           .textTheme
                  //           .labelMedium!
                  //           .copyWith(
                  //               color: Theme.of(context).colorScheme.primary),
                  //     ),
                  //   ],
                  // )
                  if (signDetail != null) ...[
                    TextButton(
                      onPressed: () => {
                        if (!signDetail!['signStatus'])
                          {
                            // 签到
                            DioRequestWeb.dailyMission()
                          }
                      },
                      child: Row(
                        children: [
                          Icon(
                            !signDetail!['signStatus']
                                ? Icons.auto_fix_high
                                : Icons.done_all,
                            size: 18,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            !signDetail!['signStatus']
                                ? '领取登陆奖励'
                                : signDetail!['signDays'],
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium!
                                .copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary),
                          ),
                        ],
                      ),
                    )
                  ] else ...[
                    TextButton(
                      onPressed: () => {},
                      child: Row(
                        children: [
                          Icon(
                            Icons.cached_sharp,
                            size: 18,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '稍等',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium!
                                .copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary),
                          ),
                        ],
                      ),
                    )
                  ]
                ],
              ),
              // const SizedBox(height: 8),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              onPressed: (() => {
                    // ignore: avoid_print
                    print('夜间模式切换按钮')
                  }),
              icon: const Icon(Icons.brightness_medium_rounded),
            ),
          )
        ],
      ),
    );
  }

  Widget buildActionOne() {
    List<Widget> tiles = []; //先建一个数组用于存放循环生成的widget
    Widget content; //单独一个widget组件，用于返回需要生成的内容widget
    for (var item in listTitleMap) {
      tiles.add(
        ListTile(
          leading: item['leading'],
          title: Text(item['title']),
          selected: selectedId == item['id'],
          // trailing: item['trailing'],
          // dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
          onTap: () => {
            setState(
              () => {
                selectedId = item['id'],
                Navigator.pushNamed(context, item['route'])
                // Timer(
                //   const Duration(milliseconds: 150),
                //   (() => {Scaffold.of(context).closeDrawer()}),
                // ),
              },
            ),
          },
        ),
      );
    }
    content = Column(children: tiles);
    return content;
  }

  Widget buildActionTwo() {
    List<Widget> tiles = []; //先建一个数组用于存放循环生成的widget
    Widget content; //单独一个widget组件，用于返回需要生成的内容widget
    for (var item in listTitleMap_2) {
      tiles.add(
        ListTile(
          leading: item['leading'],
          title: Text(item['title']),
          selected: selectedId == item['id'],
          contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
          onTap: () => {
            setState(
              () => {
                selectedId = item['id'],
                Timer(
                  const Duration(milliseconds: 150),
                  (() => {Scaffold.of(context).closeDrawer()}),
                ),
              },
            ),
          },
        ),
      );
    }
    content = Column(children: tiles);
    return content;
  }
}
