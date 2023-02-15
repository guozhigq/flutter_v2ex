import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_v2ex/utils/utils.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  HelpPageState createState() => HelpPageState();
}

class HelpPageState extends State<HelpPage> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('帮助'),
      ),
      body: ListView(
        children: [
          ListTile(
            onTap: () =>
                Utils.launchURL('https://github.com/guozhigq/flutter_v2ex'),
            leading: const Icon(Icons.settings_ethernet),
            title: const Text('Github 仓库'),
            subtitle: const Text('欢迎 star'),
          ),
          ListTile(
            onTap: () {
              final Uri smsLaunchUri = Uri(
                scheme: 'sms',
                path: '0118 999 881 999 119 7253',
                queryParameters: <String, String>{
                  'body': Uri.encodeComponent(
                      'Example Subject & Symbols are allowed!'),
                },
              );
              Utils.launchURL(smsLaunchUri, scheme: 'sms');
            },
            leading: const Icon(Icons.feedback_outlined),
            title: const Text('意见反馈'),
            subtitle: const Text('issues'),
          ),
          ListTile(
            onTap: () async {
              final url = Uri.parse('mailto:5550101234');
              Utils.launchURL(url, scheme: 'sms');
            },
            leading: const Icon(Icons.info_outline),
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
