import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_v2ex/components/common/avatar.dart';
// import 'package:flutter_v2ex/components/home/list_item.dart';

class HomeLeftDrawer extends StatefulWidget {
  const HomeLeftDrawer({super.key});

  @override
  State<HomeLeftDrawer> createState() => _HomeLeftDrawerState();
}

class _HomeLeftDrawerState extends State<HomeLeftDrawer> {
  String selectedId = '';
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
      'route': '',
      'trailing': null
    },
    {
      'id': '3',
      'leading': const Icon(Icons.messenger_outline),
      'title': '未读消息',
      'route': '',
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
    // {
    //   'id': '5',
    //   'leading': const Icon(Icons.computer),
    //   'title': 'Github',
    //   'route': ''
    // },
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
    return Material(
      child: Drawer(
        backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
        // width: 280,
        width: MediaQuery.of(context).size.width * 0.75,
        child: ListView(
          children: [
            header(),
            const SizedBox(height: 5),
            RawChip(
              labelPadding: const EdgeInsets.only(left: 1, right: 10),
              padding: const EdgeInsets.only(left: 3),
              label: Text(
                '有新回复',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall!
                    .copyWith(color: Theme.of(context).colorScheme.primary),
              ),
              avatar: Icon(
                Icons.notifications_none,
                color: Theme.of(context).colorScheme.primary,
                size: 19,
              ),
              onPressed: () => setState(() {}),
              shape: StadiumBorder(
                  side: BorderSide(
                      color: Theme.of(context).colorScheme.surfaceVariant)),
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              selectedColor: Theme.of(context).colorScheme.onInverseSurface,
              showCheckmark: false,
            ),
            buildActionOne(),
            const Divider(),
            buildActionTwo(),
          ],
        ),
      ),
    );
  }

  Widget header() {
    return DrawerHeader(
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const CAvatar(
                size: 65,
                url: '',
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'guozhigq',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.auto_fix_high,
                        size: 18,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '累计签到999天',
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium!
                            .copyWith(
                                color: Theme.of(context).colorScheme.primary),
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 8),
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
