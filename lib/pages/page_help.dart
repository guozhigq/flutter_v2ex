import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
                Utils.openURL('https://github.com/guozhigq/flutter_v2ex'),
            onLongPress: () {
              Clipboard.setData( const ClipboardData(text:'https://github.com/guozhigq/flutter_v2ex'));
              SmartDialog.showToast('已复制内容');
            },
            leading: Icon(Icons.settings_ethernet, color: iconStyle,),
            title: const Text('Github 仓库'),
            subtitle: Text('欢迎 star', style: subTitleStyle),
          ),
          ListTile(
            onTap: () => Utils.openURL('https://github.com/guozhigq/flutter_v2ex/issues/new'),
            onLongPress: () {
              Clipboard.setData( const ClipboardData(text:'https://github.com/guozhigq/flutter_v2ex/issues/new'));
              SmartDialog.showToast('已复制内容');
            },
            leading: Icon(Icons.feedback_outlined, color: iconStyle),
            title: const Text('意见反馈'),
            subtitle: Text('issues', style: subTitleStyle),
          ),
          ListTile(
            onTap: () async {
              // final url = Uri.parse('mailto:5550101234');
              // Utils.launchURL(url);
            },
            leading: Icon(Icons.info_outline, color: iconStyle),
            title: const Text('版本'),
            subtitle: Text('v1.0.0', style: subTitleStyle),
          )
        ],
      ),
    );
  }
}
