import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_v2ex/components/common/avatar.dart';
import 'package:flutter_v2ex/utils/storage.dart';
import 'package:flutter_v2ex/utils/event_bus.dart';
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (Storage().getLoginStatus()) {
      setState(() {
        loginStatus = true;
      });
      readUserInfo();
    } else {
      EventBus().on('login', (arg) {
        if (arg == 'finish') {
          readUserInfo();
          EventBus().off('login');
        }
      });
    }
  }

  void readUserInfo() {
    if (Storage().getUserInfo() != {}) {
      Map userInfoStorage = Storage().getUserInfo();
      setState(() {
        userInfo = userInfoStorage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 70,
      padding: const EdgeInsets.only(top: 10, right: 8, left: 8, bottom: 10),
      // decoration: BoxDecoration(border: Border.all()),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: Container(
          width: double.infinity,
          color: Theme.of(context).colorScheme.onInverseSurface,
          padding: const EdgeInsets.only(right: 8, left: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                onPressed: (() => {Scaffold.of(context).openDrawer()}),
                icon: const Icon(Icons.menu),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.search_outlined,
                    color: Colors.grey,
                    size: 19,
                  ),
                  const SizedBox(width: 4),
                  Text('搜索', style: Theme.of(context).textTheme.bodyMedium)
                ],
              ),
              GestureDetector(
                onTap: () async {
                  if (userInfo != {}) {
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
                    }
                  }
                },
                child: loginStatus && userInfo != {}
                    ? Hero(
                        tag: userInfo['userName'],
                        child: CAvatar(
                          url: userInfo['avatar'],
                          size: 37,
                          // fadeInDuration: Duration(milliseconds: 0),
                          // fadeOutDuration: Duration(milliseconds: 100),
                        ),
                      )
                    // ?  Text(userInfo['userName'])
                    : Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        clipBehavior: Clip.antiAlias,
                        width: 37,
                        height: 37,
                        child: Center(
                          child: Icon(
                            Icons.person_rounded,
                            size: 22,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
