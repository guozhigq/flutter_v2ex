import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';

class SetDiaplayMode extends StatefulWidget {
  const SetDiaplayMode({super.key});

  @override
  State<SetDiaplayMode> createState() => _SetDiaplayModeState();
}

class _SetDiaplayModeState extends State<SetDiaplayMode> {
  List<DisplayMode> modes = <DisplayMode>[];
  DisplayMode? active;
  DisplayMode? preferred;

  final ValueNotifier<int> page = ValueNotifier<int>(0);
  late final PageController controller = PageController()
    ..addListener(() {
      page.value = controller.page!.round();
    });
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      fetchAll();
    });
  }

  Future<void> fetchAll() async {
    try {
      modes = await FlutterDisplayMode.supported;
      modes.forEach(print);

      /// On OnePlus 7 Pro:
      /// #1 1080x2340 @ 60Hz
      /// #2 1080x2340 @ 90Hz
      /// #3 1440x3120 @ 90Hz
      /// #4 1440x3120 @ 60Hz

      /// On OnePlus 8 Pro:
      /// #1 1080x2376 @ 60Hz
      /// #2 1440x3168 @ 120Hz
      /// #3 1440x3168 @ 60Hz
      /// #4 1080x2376 @ 120Hz
    } on PlatformException catch (e) {
      print(e);

      /// e.code =>
      /// noAPI - No API support. Only Marshmallow and above.
      /// noActivity - Activity is not available. Probably app is in background
    }

    preferred = await FlutterDisplayMode.preferred;

    active = await FlutterDisplayMode.active;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('屏幕帧率设置')),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 15),
              child: Row(
                children: <Widget>[
                  Text(
                    '可用模式',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(width: 10),
                  TextButton.icon(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      fetchAll();
                    },
                    label: const Text('刷新'),
                  ),
                ],
              ),
            ),
            if (modes.isEmpty) const Text('Nothing here'),
            Expanded(
              child: ListView.builder(
                itemCount: modes.length,
                itemBuilder: (_, int i) {
                  final DisplayMode mode = modes[i];
                  return RadioListTile<DisplayMode>(
                    value: mode,
                    title: mode == DisplayMode.auto
                        ? const Text('自动')
                        : Text(mode.toString()),
                    groupValue: preferred,
                    onChanged: (DisplayMode? newMode) async {
                      await FlutterDisplayMode.setPreferredMode(newMode!);
                      await Future<dynamic>.delayed(
                        const Duration(milliseconds: 100),
                      );
                      await fetchAll();
                      setState(() {});
                    },
                  );
                },
              ),
            ),
            if (modes.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () async {
                      await FlutterDisplayMode.setHighRefreshRate();
                      await Future<dynamic>.delayed(
                        const Duration(milliseconds: 100),
                      );
                      await fetchAll();
                      setState(() {});
                    },
                    child: const Text('高刷新率'),
                  ),
                  const SizedBox(width: 18),
                  ElevatedButton(
                    onPressed: () async {
                      await FlutterDisplayMode.setLowRefreshRate();
                      await Future<dynamic>.delayed(
                        const Duration(milliseconds: 100),
                      );
                      await fetchAll();
                      setState(() {});
                    },
                    child: const Text('低刷新率'),
                  ),
                ],
              ),
            // const Divider(),
          ],
        ),
      ),
    );
  }
}
