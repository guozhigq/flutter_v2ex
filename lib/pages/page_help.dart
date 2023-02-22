import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animations/animations.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_v2ex/utils/utils.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  HelpPageState createState() => HelpPageState();
}

class HelpPageState extends State<HelpPage> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
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
            subtitle: const Text('欢迎 star'),
          ),
          ListTile(
            onTap: () => Utils.openURL('https://github.com/guozhigq/flutter_v2ex/issues/new'),
            onLongPress: () {
              Clipboard.setData( const ClipboardData(text:'https://github.com/guozhigq/flutter_v2ex/issues/new'));
              SmartDialog.showToast('已复制内容');
            },
            leading: Icon(Icons.feedback_outlined, color: iconStyle),
            title: const Text('意见反馈'),
            subtitle: const Text('issues'),
          ),
          ListTile(
            onTap: () {
              final url = Uri.parse('mailto:guozhigq@outlook.com');
              Utils.launchURL(url);
            },
            onLongPress: () {
              Clipboard.setData( const ClipboardData(text:'guozhigq@outlook.com'));
              SmartDialog.showToast('已复制内容');
            },
            leading: Icon(Icons.email_outlined, color: iconStyle),
            title: const Text('邮箱联系'),
          ),
          ListTile(
            onTap: () async {
              final url = Uri.parse('mailto:5550101234');
              Utils.launchURL(url);
            },
            leading: Icon(Icons.info_outline, color: iconStyle),
            title: const Text('当前版本 v0.0.1'),
            subtitle: const Text('检查更新'),
          )
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      floatingActionButton: const _ReplyFab(),
    );
  }
}

class _ReplyFab extends StatefulWidget {
  const _ReplyFab();

  @override
  _ReplyFabState createState() => _ReplyFabState();
}

class _ReplyFabState extends State<_ReplyFab>
    with SingleTickerProviderStateMixin {
  // static final fabKey = UniqueKey();
  static const double _mobileFabDimension = 56;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const circleFabBorder = CircleBorder();

    return OpenContainer(
      openBuilder: (context, closedContainer) {
        return const Text('123');
      },
      transitionDuration: const Duration(milliseconds: 350),
      openColor: theme.cardColor,
      // openColor: Theme.of(context).colorScheme.background,
      closedShape: circleFabBorder,
      closedColor: theme.colorScheme.secondary,
      closedElevation: 6,
      openElevation: 4,
      closedBuilder: (context, openContainer) {
        return Tooltip(
          message: 'tooltip',
          child: InkWell(
            key: const ValueKey('ReplyFab'),
            customBorder: circleFabBorder,
            onTap: openContainer,
            child: Ink(
              height: _mobileFabDimension,
              width: _mobileFabDimension,
              child: const Center(
                // child: fabSwitcher,
                child: Icon(Icons.percent),
              ),
            ),
          ),
        );
      },
    );
  }
}
