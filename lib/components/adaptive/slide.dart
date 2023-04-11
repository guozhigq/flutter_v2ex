import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_v2ex/components/common/avatar.dart';
import 'package:flutter_v2ex/components/topic/html_render.dart';
import 'package:flutter_v2ex/pages/home/controller.dart';
import 'package:flutter_v2ex/utils/event_bus.dart';
import 'package:flutter_v2ex/utils/global.dart';
import 'package:flutter_v2ex/utils/login.dart';
import 'package:flutter_v2ex/utils/storage.dart';
import 'package:flutter_v2ex/utils/utils.dart';
import 'package:get/get.dart';
import 'package:sticky_headers/sticky_headers.dart';

class AdaptSlide extends StatefulWidget {
  const AdaptSlide({Key? key}) : super(key: key);

  @override
  State<AdaptSlide> createState() => _AdaptSlideState();
}

class _AdaptSlideState extends State<AdaptSlide> {
  final TabStateController _tabStateController = Get.put(TabStateController());
  bool loginStatus = false;
  Map userInfo = {};
  List actionCounts = [];
  String balance = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _tabStateController.actionCounts.listen((value) {
      actionCounts = value;
    });
    _tabStateController.balance.listen((value) {
      balance = value;
    });

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
    _tabStateController.removeListener(() {});
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: getBackground(context, 'listItem'),
              borderRadius: BorderRadius.circular(10),
            ),
            child: StickyHeader(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                        CAvatar(
                            url: loginStatus ? userInfo['avatar'] : '',
                            size: 30),
                        const SizedBox(width: 10),
                        Text(loginStatus ? userInfo['userName'] : '未登录')
                      ],
                    ),
                  ),

                  // 登录后显示余额
                  if (loginStatus)
                    Expanded(
                      flex: 2,
                      child: Align(
                        widthFactor: double.infinity,
                        alignment: Alignment.centerRight,
                        child: Obx(
                          () =>
                              // HtmlRender(htmlContent: _tabStateController.balance.value,)
                              Html(
                            data: _tabStateController.balance.value,
                            customRenders: {
                              tagMatcher("img"): CustomRender.widget(
                                widget: (htmlContext, buildChildren) {
                                  String? imgUrl = htmlContext
                                      .tree.element!.attributes['src'];
                                  imgUrl = Utils().imageUrl(imgUrl!);
                                  return CachedNetworkImage(
                                    imageUrl: imgUrl,
                                    height: 15,
                                    fadeOutDuration:
                                        const Duration(milliseconds: 100),
                                    placeholder: (context, url) => Image.asset(
                                      'assets/images/avatar.png',
                                      width: 15,
                                      height: 15,
                                    ),
                                  );
                                },
                              ),
                            },
                            style: {
                              'a': Style(
                                color:
                                    Theme.of(context).colorScheme.onBackground,
                                textDecoration: TextDecoration.none,
                                margin: Margins.only(right: 2),
                              ),
                            },
                          ),
                        ),
                      ),
                    )
                ],
              ),
              content: Container(
                width: double.infinity,
                padding: Breakpoints.medium.isActive(context)
                    ? const EdgeInsets.fromLTRB(15, 0, 15, 25)
                    : const EdgeInsets.fromLTRB(25, 0, 25, 25),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Obx(() => ActionGrid(
                              count: _tabStateController.actionCounts[0]
                                      .toString() ??
                                  '-',
                              title: '节点收藏',
                              onTap: () => Get.toNamed('/nodes'),
                            )),
                        Obx(() => ActionGrid(
                            count: _tabStateController.actionCounts[1]
                                    .toString() ??
                                '-',
                            title: '主题收藏',
                            onTap: () => Get.toNamed('/my/topics'))),
                        Obx(() => ActionGrid(
                            count: _tabStateController.actionCounts[2]
                                    .toString() ??
                                '-',
                            title: '特别关注',
                            onTap: () => Get.toNamed('/my/following'))),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (!loginStatus)
                      ElevatedButton(
                        onPressed: () async {
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
                        },
                        child: const Text('去登录'),
                      ),
                    if (loginStatus)
                      const ElevatedButton(
                        onPressed: null,
                        child: Text('发布新主题'),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: getBackground(context, 'listItem'),
              borderRadius: BorderRadius.circular(10),
            ),
            child: StickyHeader(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '🔥 今日热议主题',
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      '更多',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.outline),
                    ),
                  )
                  // IconButton(
                  //   onPressed: () {},
                  //   icon: Icon(
                  //       Icons.refresh,
                  //       size: 20,
                  //       color: Theme.of(context).colorScheme.outline),
                  // ),
                ],
              ),
              content: const HotList(),
            ),
          ),
        ],
      ),
    );
  }
}

class HotList extends StatelessWidget {
  const HotList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 30,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
        return Material(
          color: getBackground(context, 'listItem'),
          child: InkWell(
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Text(
                '$index」 求推荐一些高质量的系统地介绍 ChatGPT 及相关技术的视频、文章或者书',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall!
                    .copyWith(height: 1.6),
              ),
            ),
          ),
        );
      },
    );
  }
}

class StickyHeader extends StatelessWidget {
  final Widget title;
  final Widget content;

  const StickyHeader({Key? key, required this.title, required this.content})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StickyHeaderBuilder(
        builder: (BuildContext context, double stuckAmount) {
          stuckAmount = 0.4 - stuckAmount.clamp(0.0, 1.0);
          return Container(
            width: double.infinity,
            height: 60,
            color: getBackground(context, 'listItem'),
            padding: const EdgeInsets.only(left: 20, right: 0),
            child: Stack(
              children: [
                SizedBox(height: 60, child: title),
                Positioned(
                    bottom: 1,
                    left: 0,
                    right: 18,
                    child: Divider(
                      height: 1,
                      color: Theme.of(context).dividerColor.withOpacity(0.1),
                    )),
              ],
            ),
          );
        },
        content: Column(
          children: [const SizedBox(height: 12), content],
        ));
  }
}

class ActionGrid extends StatelessWidget {
  final String? count;
  final String? title;
  var onTap;

  ActionGrid(
      {Key? key, required this.count, required this.title, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: getBackground(context, 'listItem'),
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () => onTap(),
        child: Padding(
          padding: Breakpoints.medium.isActive(context)
              ? const EdgeInsets.symmetric(vertical: 10, horizontal: 4)
              : const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                count!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 18,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(title!),
            ],
          ),
        ),
      ),
    );
  }
}
