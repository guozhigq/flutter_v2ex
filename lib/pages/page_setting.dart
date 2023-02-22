import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_v2ex/utils/event_bus.dart';
import 'package:get/get.dart';
import 'package:flutter_v2ex/utils/storage.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter_v2ex/utils/utils.dart';
import 'package:flutter_v2ex/utils/string.dart';
import 'package:flutter_v2ex/http/dio_web.dart';
import 'package:path_provider/path_provider.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool autoSign = true; // 自动签到
  bool materialColor = true; // 动态去色
  bool linkOpenInApp = GStorage().getLinkOpenInApp();
  bool loginStatus = GStorage().getLoginStatus();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
                GStorage().setLoginStatus(false);
                GStorage().setUserInfo({});
                GStorage().setSignStatus('');
                EventBus().emit('login', 'loginOut');
                DioRequestWeb.loginOut();
                SmartDialog.showToast('已退出登录');
                PersistCookieJar().deleteAll();
                PersistCookieJar().delete(Uri.parse(Strings.v2exHost), true);

                /// 删除cookie目录
                String path = await Utils.getCookiePath();
                var cookieJar = PersistCookieJar(storage: FileStorage(path));
                await cookieJar.deleteAll();
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
          // ListTile(
          //   onTap: () {
          //     setState(() {
          //       autoSign = !autoSign;
          //     });
          //   },
          //   leading: Icon(Icons.task_alt, color: iconStyle),
          //   title: const Text('自动签到'),
          //   subtitle: Text('北京时间8点', style: subTitleStyle),
          //   trailing: Transform.scale(
          //     scale: 0.9,
          //     child: Switch(
          //         value: autoSign,
          //         onChanged: (value) {
          //           setState(() {
          //             autoSign = value;
          //           });
          //         }),
          //   ),
          // ),
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
              scale: 0.9,
              child: Switch(
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
            leading: Icon(Icons.cleaning_services_outlined, color: iconStyle),
            title: const Text('清除缓存'),
            subtitle: Text('图片、数据缓存', style: subTitleStyle),
          ),
          if(loginStatus) ... [
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
