import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_v2ex/http/init.dart';
import 'package:flutter_v2ex/utils/utils.dart';
import 'package:flutter_v2ex/utils/cache.dart';
import 'package:flutter_v2ex/http/dio_web.dart';
import 'package:flutter_v2ex/utils/storage.dart';
import 'package:flutter_v2ex/utils/event_bus.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get_storage/get_storage.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool autoSign = GStorage().getAutoSign(); // 自动签到
  bool materialColor = true; // 动态去色
  bool linkOpenInApp = GStorage().getLinkOpenInApp();
  bool loginStatus = GStorage().getLoginStatus();
  String cacheSize = '';
  bool expendAppBar = GStorage().getExpendAppBar();
  bool noticeOn = GStorage().getNoticeOn();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // 读取缓存占用
    getCacheSize();
  }

  void getCacheSize() async {
    var res = await CacheManage().loadApplicationCache();
    setState(() {
      cacheSize = res;
    });
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
                  Directory directory = Directory(await Utils.getCookiePath());
                  await CacheManage().deleteDirectory(directory);
                  GStorage().setLoginStatus(false);
                  GStorage().setUserInfo({});
                  GStorage().setSignStatus('');
                  eventBus.emit('login', 'loginOut');
                  await DioRequestWeb.loginOut();
                  SmartDialog.showToast('已退出登录 ✅');
                  Request().get('/');
                } catch (err) {
                  SmartDialog.showToast(err.toString());
                }
              },
              child: const Text('确定'))
        ],
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle titleStyle = Theme.of(context).textTheme.titleLarge!;
    TextStyle subTitleStyle = Theme.of(context).textTheme.labelMedium!;
    Color iconStyle = Theme.of(context).colorScheme.onBackground;
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        children: [
          ListTile(
            onTap: () {
              setState(() {
                autoSign = !autoSign;
              });
            },
            leading: Icon(Icons.task_alt, color: iconStyle),
            title: const Text('自动签到'),
            subtitle: Text('北京时间8点', style: subTitleStyle),
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
          // ListTile(
          //   onTap: () {
          //     setState(() {
          //       materialColor = !materialColor;
          //     });
          //   },
          //   leading: Icon(Icons.color_lens_outlined, color: iconStyle),
          //   title: const Text('动态色彩'),
          //   subtitle: Text('将壁纸颜色应用于主题色', style: subTitleStyle),
          //   trailing: Transform.scale(
          //     scale: 0.9,
          //     child: Switch(
          //         value: materialColor,
          //         onChanged: (value) {
          //           setState(() {
          //             materialColor = value;
          //           });
          //         }),
          //   ),
          // ),
          // ListTile(
          //   onTap: () {},
          //   leading: Icon(Icons.workspaces_outlined, color: iconStyle),
          //   title: const Text('主题风格'),
          //   subtitle: Text('选择应用主题色', style: subTitleStyle),
          // ),
          ListTile(
            onTap: () {},
            leading: Icon(Icons.open_in_new_rounded, color: iconStyle),
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
            onTap: () {},
            leading: Icon(Icons.expand, color: iconStyle),
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
            onTap: () {},
            leading: Icon(Icons.notifications_none, color: iconStyle),
            title: const Text('接收消息通知'),
            subtitle: Text('关闭后将不再接收回复、感谢、收藏\n等通知', style: subTitleStyle),
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
          ListTile(
            onTap: () async {
              var cleanStatus = await CacheManage().clearCacheAll();
              if (cleanStatus) {
                getCacheSize();
              }
            },
            leading: Icon(Icons.cleaning_services_outlined, color: iconStyle),
            title: const Text('清除缓存'),
            subtitle: Text('图片及网络缓存 $cacheSize', style: subTitleStyle),
          ),
          if (loginStatus) ...[
            ListTile(
              onTap: onLogout,
              leading: Icon(Icons.logout_rounded, color: iconStyle),
              title: const Text('退出登录'),
              subtitle: Text('清除当前登录信息', style: subTitleStyle),
            ),
          ],
          ListTile(
            onTap: () async {
              Get.toNamed('/help');
            },
            leading: Icon(Icons.info_outline, color: iconStyle),
            title: const Text('关于'),
            subtitle: Text('意见反馈、版本说明', style: subTitleStyle),
          )
        ],
      ),
    );
  }
}
