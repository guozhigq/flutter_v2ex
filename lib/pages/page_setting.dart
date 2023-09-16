import 'dart:io';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:flutter_v2ex/pages/page_home.dart';
import 'package:flutter_v2ex/utils/login.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_v2ex/utils/cache.dart';
import 'package:flutter_v2ex/utils/storage.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  late bool autoSign = GStorage().getAutoSign(); // 自动签到
  late bool materialColor = true; // 动态去色
  late bool linkOpenInApp = GStorage().getLinkOpenInApp();
  late bool loginStatus = GStorage().getLoginStatus();
  late String cacheSize = '';
  late bool expendAppBar = GStorage().getExpendAppBar();
  late bool noticeOn = GStorage().getNoticeOn();
  late bool highlightOp = GStorage().getHighlightOp();
  late bool sideslip = GStorage().getSideslip();
  // 平台
  String platform = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // 读取缓存占用
    getCacheSize();

    if (Platform.isAndroid || Platform.isIOS || Platform.isFuchsia) {
      platform = 'mob';
    }
    if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      platform = 'desktop';
    }
  }

  Future<void> getCacheSize() async {
    final res = await CacheManage().loadApplicationCache();
    setState(() => cacheSize = res);
  }

  void onLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('该操作将退出您的账号及相关信息，请确定'),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('取消')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              /// 删除cookie目录
              try {
                await Login.signOut();
                SmartDialog.showToast('已退出登录 ✅');
                Get.offAll(const HomePage());
              } catch (err) {
                SmartDialog.showToast(err.toString());
              }
            },
            child: const Text('确定'),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle titleStyle = Theme.of(context).textTheme.titleLarge!;
    TextStyle subTitleStyle = Theme.of(context).textTheme.labelMedium!;
    Color iconStyle = Theme.of(context).colorScheme.onBackground;
    TextStyle groupTitleStyle = Theme.of(context)
        .textTheme
        .titleSmall!
        .copyWith(color: Theme.of(context).colorScheme.primary);
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 25, 20, 5),
            child: Text('常规设置', style: groupTitleStyle),
          ),
          ListTile(
            onTap: () => Get.toNamed('/nodesSort'),
            // leading: Icon(Icons.drag_indicator_rounded, color: iconStyle),
            title: const Text('节点设置'),
            subtitle: Text('调整节点顺序', style: subTitleStyle),
          ),
          ListTile(
            enableFeedback: true,
            onTap: () {
              setState(() {
                autoSign = !autoSign;
                GStorage().setAutoSign(autoSign);
              });
            },
            // leading: Icon(Icons.task_alt, color: iconStyle),
            title: const Text('自动签到'),
            subtitle: Text('自动领取每日登陆奖励', style: subTitleStyle),
            trailing: Transform.scale(
              scale: 0.8,
              child: Switch(
                  thumbIcon: MaterialStateProperty.resolveWith<Icon?>(
                      (Set<MaterialState> states) {
                    if (states.isNotEmpty &&
                        states.first == MaterialState.selected) {
                      return const Icon(Icons.done);
                    }
                    return null; // All other states will use the default thumbIcon.
                  }),
                  value: autoSign,
                  onChanged: (value) {
                    setState(() {
                      autoSign = !autoSign;
                      GStorage().setAutoSign(autoSign);
                    });
                  }),
            ),
          ),
          ListTile(
            onTap: () {
              setState(() {
                linkOpenInApp = !linkOpenInApp;
                GStorage().setLinkOpenInApp(linkOpenInApp);
              });
            },
            // leading: Icon(Icons.open_in_new_rounded, color: iconStyle),
            title: const Text('使用应用内浏览器'),
            subtitle: Text('在应用内查看外部链接', style: subTitleStyle),
            trailing: Transform.scale(
              scale: 0.8,
              child: Switch(
                  thumbIcon: MaterialStateProperty.resolveWith<Icon?>(
                      (Set<MaterialState> states) {
                    if (states.isNotEmpty &&
                        states.first == MaterialState.selected) {
                      return const Icon(Icons.done);
                    }
                    return null; // All other states will use the default thumbIcon.
                  }),
                  value: linkOpenInApp,
                  onChanged: (value) {
                    setState(() {
                      linkOpenInApp = !linkOpenInApp;
                      GStorage().setLinkOpenInApp(linkOpenInApp);
                    });
                  }),
            ),
          ),
          ListTile(
            onTap: () {
              setState(() {
                noticeOn = !noticeOn;
                GStorage().setNoticeOn(noticeOn);
              });
            },
            // leading: Icon(Icons.notifications_none, color: iconStyle),
            title: const Text('接收消息通知'),
            subtitle: Text('关闭后收到通知将不再提醒', style: subTitleStyle),
            trailing: Transform.scale(
              scale: 0.8,
              child: Switch(
                  thumbIcon: MaterialStateProperty.resolveWith<Icon?>(
                      (Set<MaterialState> states) {
                    if (states.isNotEmpty &&
                        states.first == MaterialState.selected) {
                      return const Icon(Icons.done);
                    }
                    return null; // All other states will use the default thumbIcon.
                  }),
                  value: noticeOn,
                  onChanged: (value) {
                    setState(() {
                      noticeOn = !noticeOn;
                      GStorage().setNoticeOn(noticeOn);
                    });
                  }),
            ),
          ),
          if (Breakpoints.small.isActive(context))
            ListTile(
              onTap: () {
                setState(() {
                  noticeOn = !noticeOn;
                  GStorage().setNoticeOn(noticeOn);
                });
              },
              // leading: Icon(Icons.notifications_none, color: iconStyle),
              title: const Text('侧滑返回（重启生效）'),
              subtitle: Text('页面任意位置右滑返回上一页', style: subTitleStyle),
              trailing: Transform.scale(
                scale: 0.8,
                child: Switch(
                    thumbIcon: MaterialStateProperty.resolveWith<Icon?>(
                        (Set<MaterialState> states) {
                      if (states.isNotEmpty &&
                          states.first == MaterialState.selected) {
                        return const Icon(Icons.done);
                      }
                      return null; // All other states will use the default thumbIcon.
                    }),
                    value: sideslip,
                    onChanged: (value) {
                      setState(() {
                        sideslip = !sideslip;
                        GStorage().setSideslip(sideslip);
                      });
                    }),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 25, 20, 15),
            child: Text('显示设置', style: groupTitleStyle),
          ),
          ListTile(
            dense: false,
            onTap: () => Get.toNamed('/setFont'),
            title: const Text('字体设置'),
          ),
          if (Platform.isAndroid)
            ListTile(
              dense: false,
              onTap: () => Get.toNamed('/setDisplayMode'),
              title: const Text('屏幕帧率设置'),
            ),
          if (platform == 'mob')
            ListTile(
              onTap: () {
                setState(() {
                  expendAppBar = !expendAppBar;
                  GStorage().setExpendAppBar(expendAppBar);
                });
              },
              // leading: Icon(Icons.expand, color: iconStyle),
              title: const Text('滑动时收起AppBar'),
              subtitle: Text('在详情页收起顶部信息栏', style: subTitleStyle),
              trailing: Transform.scale(
                scale: 0.8,
                child: Switch(
                    thumbIcon: MaterialStateProperty.resolveWith<Icon?>(
                        (Set<MaterialState> states) {
                      if (states.isNotEmpty &&
                          states.first == MaterialState.selected) {
                        return const Icon(Icons.done);
                      }
                      return null; // All other states will use the default thumbIcon.
                    }),
                    value: expendAppBar,
                    onChanged: (value) {
                      setState(() {
                        expendAppBar = !expendAppBar;
                        GStorage().setExpendAppBar(expendAppBar);
                      });
                    }),
              ),
            ),
          ListTile(
            onTap: () {
              setState(() {
                highlightOp = !highlightOp;
                GStorage().setHighlightOp(noticeOn);
              });
            },
            // leading: Icon(Icons.notifications_none, color: iconStyle),
            title: const Text('高亮OP回复'),
            subtitle: Text('开启后突出显示OP回复', style: subTitleStyle),
            trailing: Transform.scale(
              scale: 0.8,
              child: Switch(
                  thumbIcon: MaterialStateProperty.resolveWith<Icon?>(
                      (Set<MaterialState> states) {
                    if (states.isNotEmpty &&
                        states.first == MaterialState.selected) {
                      return const Icon(Icons.done);
                    }
                    return null; // All other states will use the default thumbIcon.
                  }),
                  value: highlightOp,
                  onChanged: (value) {
                    setState(() {
                      highlightOp = !highlightOp;
                      GStorage().setHighlightOp(highlightOp);
                    });
                  }),
            ),
          ),
          ListTile(
            onTap: () async {
              var cleanStatus = await CacheManage().clearCacheAll();
              if (cleanStatus) {
                getCacheSize();
              }
            },
            // leading: Icon(Icons.cleaning_services_outlined, color: iconStyle),
            title: const Text('清除缓存'),
            subtitle: Text('图片及网络缓存 $cacheSize', style: subTitleStyle),
          ),
          if (loginStatus) ...[
            const SizedBox(height: 10),
            ListTile(
              onTap: onLogout,
              title: Center(
                child: Text('退出登录',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(color: Theme.of(context).colorScheme.error)),
              ),
              // subtitle: Text('清除当前登录信息', style: subTitleStyle),
            ),
          ],
        ],
      ),
    );
  }
}
