import 'package:flutter/material.dart';
import 'package:flutter_v2ex/utils/event_bus.dart';
import 'package:flutter_v2ex/utils/string.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:get/get.dart';

class TrailingNavRail extends StatefulWidget {
  const TrailingNavRail({Key? key}) : super(key: key);

  @override
  State<TrailingNavRail> createState() => _TrailingNavRailState();
}

class _TrailingNavRailState extends State<TrailingNavRail> {
  ThemeType? _tempThemeValue = ThemeType.system;
  ThemeType? _currentThemeValue = ThemeType.system;

  void _showThemeDialog() {
    TextStyle textStyle = Theme.of(context).textTheme.titleMedium!;
    showDialog(
      context: Get.context!,
      builder: (context) {
        return AlertDialog(
          title: const Text('选择主题'),
          contentPadding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
          content: StatefulBuilder(builder: (context, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile(
                  value: ThemeType.light,
                  title: Text('浅色', style: textStyle),
                  groupValue: _tempThemeValue,
                  onChanged: (ThemeType? value) {
                    setState(() {
                      _tempThemeValue = value;
                    });
                  },
                ),
                RadioListTile(
                  value: ThemeType.dark,
                  title: Text('深色', style: textStyle),
                  groupValue: _tempThemeValue,
                  onChanged: (ThemeType? value) {
                    setState(() {
                      _tempThemeValue = value;
                    });
                  },
                ),
                RadioListTile(
                  value: ThemeType.system,
                  title: Text('系统默认设置', style: textStyle),
                  groupValue: _tempThemeValue,
                  onChanged: (ThemeType? value) {
                    setState(() {
                      _tempThemeValue = value;
                    });
                  },
                ),
              ],
            );
          }),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('取消')),
            TextButton(
                onPressed: () {
                  setState(() => _currentThemeValue = _tempThemeValue);
                  eventBus.emit('themeChange', _currentThemeValue);
                  Navigator.pop(context);
                },
                child: const Text('确定'))
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: Breakpoints.large.isActive(context)
                ? [
                    Row(
                      children: <Widget>[
                        IconButton(
                          onPressed: () => _showThemeDialog(),
                          icon: const Icon(Icons.brightness_medium_rounded),
                          iconSize: 19,
                        ),
                        const SizedBox(width: 11),
                        Text('选择主题',
                            style: Theme.of(context).textTheme.labelSmall),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        IconButton(
                          onPressed: () => Get.toNamed('/setting'),
                          icon: const Icon(Icons.tune_outlined),
                          iconSize: 19,
                        ),
                        const SizedBox(width: 11),
                        Text('设置',
                            style: Theme.of(context).textTheme.labelSmall),
                      ],
                    ),
                    // const SizedBox(height: 16),
                    Row(
                      children: <Widget>[
                        IconButton(
                          onPressed: () => Get.toNamed('/help'),
                          icon: const Icon(Icons.help_outline_outlined),
                          iconSize: 19,
                        ),
                        const SizedBox(width: 11),
                        Text('帮助',
                            style: Theme.of(context).textTheme.labelSmall),
                      ],
                    ),
                  ]
                : [
                    IconButton(
                      onPressed: () => _showThemeDialog(),
                      icon: const Icon(Icons.brightness_medium_rounded),
                      iconSize: 19,
                    ),
                    IconButton(
                      onPressed: () => Get.toNamed('/setting'),
                      icon: const Icon(Icons.tune_outlined),
                      iconSize: 19,
                    ),
                    IconButton(
                      onPressed: () => Get.toNamed('/help'),
                      icon: const Icon(Icons.help_outline_outlined),
                      iconSize: 19,
                    ),
                  ],
          )),
    );
  }
}
