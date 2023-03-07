import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_v2ex/http/dio_web.dart';
import 'package:flutter_v2ex/utils/string.dart';
import 'package:flutter_v2ex/utils/utils.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  HelpPageState createState() => HelpPageState();
}

class HelpPageState extends State<HelpPage> with TickerProviderStateMixin {
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
            onTap: () =>
                Utils.openURL(Strings.remoteUrl),
            onLongPress: () {
              Clipboard.setData( ClipboardData(text: Strings.remoteUrl));
              SmartDialog.showToast('已复制内容');
            },
            leading: Icon(Icons.settings_ethernet, color: iconStyle,),
            title: const Text('Github 仓库'),
            subtitle: Text('欢迎 star', style: subTitleStyle),
          ),
          ListTile(
            onTap: () => Utils.openURL('${Strings.remoteUrl}/issues/new'),
            onLongPress: () {
              Clipboard.setData( ClipboardData(text:'${Strings.remoteUrl}/issues/new'));
              SmartDialog.showToast('已复制内容');
            },
            leading: Icon(Icons.feedback_outlined, color: iconStyle),
            title: const Text('意见反馈'),
            subtitle: Text('issues', style: subTitleStyle),
          ),
          ListTile(
            onTap: () async {
              SmartDialog.showLoading(msg: '正在检查更新');
              Map update = await DioRequestWeb.checkUpdate();
              SmartDialog.dismiss();
              var needUpdate = Utils.needUpdate(Strings.currentVersion, update['lastVersion']);
              if(needUpdate && context.mounted) {
                showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('提示'),
                    content: Text('检测到有新版本 ${update['lastVersion']}，是否更新？'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(context, 'Cancel'),
                        child: const Text('稍后'),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          Utils.openURL(Strings.remoteUrl);
                        },
                        child: const Text('前往更新'),
                      ),
                    ],
                  ),
                );
              }else {
                SmartDialog.showToast('已经是最新版了 😊');
              }
            },
            leading: Icon(Icons.info_outline, color: iconStyle),
            title: const Text('版本'),
            subtitle: Text(Strings.currentVersion, style: subTitleStyle),
          )
        ],
      ),
    );
  }
}
