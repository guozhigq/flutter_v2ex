import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_v2ex/http/dio_web.dart';
import 'package:flutter_v2ex/http/github.dart';
import 'package:flutter_v2ex/utils/storage.dart';
import 'package:flutter_v2ex/utils/string.dart';
import 'package:flutter_v2ex/utils/utils.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  HelpPageState createState() => HelpPageState();
}

class HelpPageState extends State<HelpPage> with TickerProviderStateMixin {
  bool autoUpdate = GStorage().getAutoUpdate();

  @override
  Widget build(BuildContext context) {
    TextStyle subTitleStyle = Theme.of(context).textTheme.labelMedium!;
    Color iconStyle = Theme.of(context).colorScheme.onBackground;
    return Scaffold(
      appBar: AppBar(
        title: const Text('帮助'),
      ),
      body: ListView(
        children: [
          ListTile(
            onTap: () {
              setState(() {
                autoUpdate = !autoUpdate;
                GStorage().setAutoSign(autoUpdate);
              });
            },
            // leading: Icon(Icons.update, color: iconStyle),
            title: const Text('自动检查更新'),
            subtitle: Text('打开app时检查更新', style: subTitleStyle),
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
                  value: autoUpdate,
                  onChanged: (value) {
                    setState(() {
                      autoUpdate = !autoUpdate;
                      GStorage().setAutoUpdate(autoUpdate);
                    });
                  }),
            ),
          ),
          // ListTile(
          //   onTap: () =>
          //       Get.toNamed('/agreement', parameters: {'source': 'privacy'}),
          //   leading: Icon(Icons.collections_bookmark_outlined, color: iconStyle,),
          //   title: const Text('隐私政策'),
          // ),
          // ListTile(
          //   onTap: () =>
          //       Get.toNamed('/agreement', parameters: {'source': 'user'}),
          //   leading: Icon(Icons.collections_bookmark_outlined, color: iconStyle,),
          //   title: const Text('用户协议'),
          // ),
          ListTile(
            onTap: () =>
                Utils.openURL('https://t.me/+lm_oOVmF0RJiODk1'),
            title: const Text('加入讨论'),
            subtitle: Text('来TG跟开发者面对面', style: subTitleStyle),
          ),
          ListTile(
            onTap: () =>
                Utils.openURL(Strings.remoteUrl),
            onLongPress: () {
              Clipboard.setData( ClipboardData(text: Strings.remoteUrl));
              SmartDialog.showToast('已复制内容');
            },
            title: const Text('Github 仓库'),
            subtitle: Text('欢迎 star & pr', style: subTitleStyle),
          ),
          ListTile(
            onTap: () => Get.toNamed('/networkCheck'),
            title: const Text('网络检测'),
          ),
          ListTile(
            onTap: () => Get.toNamed('/changeLog'),
            title: const Text('更新日志'),
          ),
          ListTile(
            onTap: () async{
              final deviceInfoPlugin = DeviceInfoPlugin();
              final deviceInfo = await deviceInfoPlugin.deviceInfo;
              final allInfo = deviceInfo.data;
              Clipboard.setData( ClipboardData(text: allInfo.toString()));
              SmartDialog.showToast('已复制');
            },
            title: const Text('设备信息'),
            subtitle: Text('点击复制到粘贴板', style: subTitleStyle),
          ),
          ListTile(
            onTap: () => Utils.openURL('${Strings.remoteUrl}/issues/new'),
            onLongPress: () {
              Clipboard.setData( ClipboardData(text:'${Strings.remoteUrl}/issues/new'));
              SmartDialog.showToast('已复制内容');
            },
            title: const Text('意见反馈'),
            subtitle: Text('issues', style: subTitleStyle),
          ),
          ListTile(
            onTap: () async {
              SmartDialog.showLoading(msg: '正在检查更新');
              Map update = await GithubApi.checkUpdate();
              SmartDialog.dismiss();
              if(!update['needUpdate'] && context.mounted) {
                SmartDialog.showToast('已经是最新版了 😊');
              }
            },
            title: const Text('版本'),
            subtitle: Text(Strings.currentVersion, style: subTitleStyle),
          )
        ],
      ),
    );
  }
}
