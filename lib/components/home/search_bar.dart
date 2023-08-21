import 'package:flutter_v2ex/service/i18n_keyword.dart';
import 'package:flutter_v2ex/utils/login.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
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
      if (arg != null) {
        if (arg == 'success') {
          readUserInfo();
        }
        if (arg == 'fail' || arg == 'loginOut') {
          // GStorage().setLoginStatus(false);
          // GStorage().setUserInfo({});
          setState(() {
            loginStatus = false;
            userInfo = {};
          });
        }
        if (arg == 'fail') {
          Login.loginDialog('登录状态失效，请重新登录');
        }
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
      child: SizedBox(
        width: double.infinity,
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
                        tooltip: I18nKeyword.drawer.tr,
                        onPressed: () => Scaffold.of(context).openDrawer(),
                        icon: const Icon(Icons.menu),
                      ),
                      Center(
                        child: Text(I18nKeyword.search.tr,
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
                            if (res != null) {
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
                          }
                        },
                        child: loginStatus && userInfo.isNotEmpty
                            ? Hero(
                                tag: userInfo['userName'],
                                child: CAvatar(
                                  url: userInfo['avatar'],
                                  size: 37,
                                  fadeInDuration:
                                      const Duration(milliseconds: 0),
                                  fadeOutDuration:
                                      const Duration(milliseconds: 0),
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
                  Visibility(
                    visible: loginStatus,
                    child: Positioned(
                      right: 38,
                      top: 0,
                      child: IconButton(
                          tooltip: I18nKeyword.notice.tr,
                          onPressed: () {
                            setState(() {
                              unRead = false;
                            });
                            Get.toNamed('/notifications');
                          },
                          icon: Icon(Icons.notifications_none_rounded,
                              color: !unRead
                                  ? Theme.of(context).colorScheme.onSurface
                                  : Theme.of(context).colorScheme.primary)),
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }
}
