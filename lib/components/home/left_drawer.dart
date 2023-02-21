import 'dart:math';
import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_v2ex/http/dio_web.dart';
import 'package:flutter_v2ex/utils/string.dart';
import 'package:flutter_v2ex/utils/storage.dart';
import 'package:flutter_v2ex/utils/event_bus.dart';
import 'package:flutter_v2ex/components/common/avatar.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class HomeLeftDrawer extends StatefulWidget {
  const HomeLeftDrawer({super.key});

  @override
  State<HomeLeftDrawer> createState() => _HomeLeftDrawerState();
}

class _HomeLeftDrawerState extends State<HomeLeftDrawer> {
  bool loginStatus = false;
  Map userInfo = {};
  int selectedIndex = 99;
  Map<dynamic, dynamic>? signDetail;
  ThemeType? tempThemeValue = ThemeType.system;
  ThemeType? currentThemeValue = ThemeType.system;

  void onDestinationSelected(int index) {
    if (index == 0) {
      // 热议主题
      Get.toNamed('/hot');
    }
    if (index == 1) {
      // 我的关注
      Get.toNamed('/my/following');
    }
    if (index == 2) {
      // 我的收藏
      Get.toNamed('/my/topics');
    }
    if (index == 3) {
      // 消息提醒
      Get.toNamed('/notifications');
    }
    if (index == 4) {
      // 发布主题
      print('_character: $tempThemeValue');
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
    if (GStorage().getLoginStatus()) {
      setState(() {
        loginStatus = true;
      });
      readUserInfo();
      queryDaily();
    } else {
      EventBus().on('login', (arg) {
        if (arg == 'success') {
          readUserInfo();
          EventBus().off('login');
        }
      });
    }
    // 读取默认主题配置
    setState(() {
      currentThemeValue = GStorage().getSystemType();
    });
  }

  void readUserInfo() {
    if (GStorage().getUserInfo().isNotEmpty) {
      Map userInfoStorage = GStorage().getUserInfo();
      setState(() {
        userInfo = userInfoStorage;
      });
    }
  }

  // 查询签到状态
  Future queryDaily() async {
    var res = await DioRequestWeb.queryDaily();
    setState(() {
      signDetail = res;
    });
  }

  List<Map<dynamic, dynamic>> listTitleMap = [
    {'leading': const Icon(Icons.favorite_outline), 'title': '今日热议'},
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
        // Container(
        //   padding: EdgeInsets.only(
        //     top: MediaQuery.of(context).padding.top,
        //     left: 25,
        //     bottom: 20,
        //   ),
        //   child: Text('VVex', style: Theme.of(context).textTheme.titleLarge),
        // ),
        header(),
        if(loginStatus) ... [
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
        ],
        for (var i in listTitleMap_2)
          NavigationDrawerDestination(
            icon: i['leading'],
            label: Text(i['title']),
          ),
      ],
    );
  }

  Widget header() {
    var herotag = '';
    if (userInfo.isNotEmpty) {
      herotag = userInfo['userName'] + Random().nextInt(999).toString();
    }
    return DrawerHeader(
      curve: Curves.bounceInOut,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                    onTap: () {
                      if (userInfo.isNotEmpty) {
                        Get.toNamed('/member/${userInfo['userName']}',
                            parameters: {
                              'memberAvatar': userInfo['avatar'],
                              'heroTag': herotag,
                            });
                      } else {
                        Get.toNamed('/login')!.then((res) {
                          if (res['loginStatus'] == 'cancel') {
                            SmartDialog.showToast('取消登录');
                          } else {
                            SmartDialog.showToast('登录成功');
                            if (GStorage().getLoginStatus()) {
                              setState(() {
                                loginStatus = true;
                              });
                              readUserInfo();
                            }
                          }
                        });
                      }
                    },
                    child: Hero(
                      tag: herotag,
                      // tag: userInfo.isNotEmpty ? herotag : null,
                      child: CAvatar(
                        size: 80,
                        url: userInfo.isNotEmpty
                            ? '${userInfo['avatar']}'
                            : '',
                      ),
                    )),
                // const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      userInfo.isNotEmpty
                          ? '${userInfo['userName']}'
                          : '点击头像登录',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
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
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
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
                                  .titleSmall!
                                  .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                            ),
                          ],
                        ),
                      )
                    ]
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            // child: Column(
            //   mainAxisAlignment: MainAxisAlignment.end,
            //   crossAxisAlignment: CrossAxisAlignment.end,
            //   children: [
            //     Text('2023-02-10', style: Theme.of(context).textTheme.titleMedium),
            //     const SizedBox(height: 3),
            //     Text('星期三', style: Theme.of(context).textTheme.titleSmall)
            //   ],
            // ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          )
        ],
      ),
    );
  }
}
