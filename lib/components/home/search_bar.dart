import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_v2ex/service/local_notice.dart';
import 'package:flutter_v2ex/utils/utils.dart';

// import 'package:flutter_v2ex/http/dio_web.dart';
import 'package:flutter_v2ex/utils/storage.dart';
import 'package:flutter_v2ex/utils/event_bus.dart';
import 'package:flutter_v2ex/components/common/avatar.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class HomeSearchBar extends StatefulWidget {
  final userInfo;

  const HomeSearchBar({this.userInfo, super.key});

  @override
  State<HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends State<HomeSearchBar> {
  bool loginStatus = false;
  Map userInfo = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // 启动式读取用户信息
    if (Storage().getLoginStatus()) {
      setState(() {
        loginStatus = true;
      });
      readUserInfo();
    }
    {
      EventBus().on('login', (arg) {
        if (arg == 'success') {
          readUserInfo();
        }
        if (arg == 'fail') {
          Utils.loginDialog('登录状态失效，请重新登录');
          Storage().setLoginStatus(false);
          Storage().setUserInfo({});
          setState(() {
            loginStatus = false;
            userInfo = {};
          });
        }
      });
    }
  }

  void readUserInfo() {
    if (Storage().getUserInfo() != {}) {
      // DioRequestWeb.dailyMission();
      Map userInfoStorage = Storage().getUserInfo();
      setState(() {
        userInfo = userInfoStorage;
      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    EventBus().off('login');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                GestureDetector(
                  onTap: () => Get.toNamed('/search'),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: (() => {Scaffold.of(context).openDrawer()}),
                        icon: const Icon(Icons.menu),
                      ),
                      Expanded(
                        child: SizedBox(
                            child: Center(
                          child: Text('搜索',
                              style: Theme.of(context).textTheme.bodyMedium),
                        )),
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
                            if (res['loginStatus'] == 'cancel') {
                              SmartDialog.showToast('取消登录');
                            } else {
                              SmartDialog.showToast('登录成功');
                              if (Storage().getLoginStatus()) {
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
                ),
                Positioned(
                  right: 38,
                  top: 0,
                  child: IconButton(
                      onPressed: () async{
                        LocalNoticeService().send(
                          '您有新的消息提醒',
                          "点击查看",
                          channel: 'work-end',
                        );
                      },
                      icon: const Icon(Icons.notifications_none_rounded)),
                )
              ],
            )),
      ),
    );
  }
}
