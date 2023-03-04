import 'package:flutter_v2ex/utils/login.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_v2ex/utils/utils.dart';
import 'package:flutter_v2ex/utils/storage.dart';
import 'package:flutter_v2ex/utils/event_bus.dart';
import 'package:flutter_v2ex/components/common/avatar.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class HomeSearchBar extends StatefulWidget {
  final userInfo;

  const HomeSearchBar({this.userInfo, super.key});

  @override
  State<HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends State<HomeSearchBar> {
  bool loginStatus = false;
  Map userInfo = {};
  bool unRead = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // 初始化时读取用户信息
    if (GStorage().getLoginStatus()) {
      loginStatus = true;
      readUserInfo();
    }

    eventBus.on('login', (arg) {
      if (arg == 'success') {
        readUserInfo();
      }
      if (arg == 'fail' || arg == 'loginOut') {
        GStorage().setLoginStatus(false);
        GStorage().setUserInfo({});
        setState(() {
          loginStatus = false;
          userInfo = {};
        });
      }
      if (arg == 'fail') {
        Login.loginDialog('登录状态失效，请重新登录');
      }
    });

    eventBus.on('unRead', (arg) {
      setState(() {
        unRead = arg > 0;
      });
    });
  }

  void readUserInfo() {
    if (GStorage().getUserInfo() != {}) {
      // DioRequestWeb.dailyMission();
      Map userInfoStorage = GStorage().getUserInfo();
      setState(() {
        userInfo = userInfoStorage;
        loginStatus = true;
      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    // eventBus.off('login');
    eventBus.off('unRead');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed('/search'),
      child: Container(
        width: double.infinity,
        height: 115,
        padding: const EdgeInsets.only(top: 33, right: 0, left: 0, bottom: 33),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: Container(
              width: double.infinity,
              color: Theme.of(context).colorScheme.onInverseSurface,
              padding: const EdgeInsets.only(right: 8, left: 4),
              child: Stack(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Scaffold.of(context).openDrawer(),
                        icon: const Icon(Icons.menu),
                      ),
                      Center(
                        child: Text('搜索',
                            style: Theme.of(context).textTheme.bodyMedium),
                      ),
                      GestureDetector(
                        onTap: () async {
                          if (userInfo.isNotEmpty) {
                            Get.toNamed('/member/${userInfo['userName']}',
                                parameters: {
                                  'memberAvatar': userInfo['avatar'],
                                  'heroTag': userInfo['userName'],
                                });
                          } else {
                            var res = await Get.toNamed('/login');
                            print('search_bar: $res');
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
                          }
                        },
                        child: loginStatus && userInfo.isNotEmpty
                            ? Hero(
                                tag: userInfo['userName'],
                                child: CAvatar(
                                  url: userInfo['avatar'],
                                  size: 37,
                                ),
                              )
                            // ?  Text(userInfo['userName'])
                            : Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceVariant,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                clipBehavior: Clip.antiAlias,
                                width: 37,
                                height: 37,
                                child: Center(
                                  child: Icon(
                                    Icons.person_rounded,
                                    size: 22,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                  Positioned(
                    right: 38,
                    top: 0,
                    child: IconButton(
                        onPressed: () {
                          setState(() {
                            unRead = false;
                          });
                            Get.toNamed('/notifications');
                        },
                        icon: Icon(Icons.notifications_none_rounded,
                            color: !unRead ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.primary)),
                  )
                ],
              )),
        ),
      ),
    );
  }
}
