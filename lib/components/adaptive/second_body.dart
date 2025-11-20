import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_v2ex/models/web/item_tab_topic.dart';
import 'package:flutter_v2ex/pages/t/topic_id.dart';
import 'package:flutter_v2ex/utils/event_bus.dart';
import 'package:flutter_v2ex/utils/logger.dart';

class SecondBody extends StatefulWidget {
  const SecondBody({Key? key}) : super(key: key);

  @override
  State<SecondBody> createState() => _SecondBodyState();
}

class _SecondBodyState extends State<SecondBody> {
  TabTopicItem? topic;

  @override
  void initState() {
    eventBus.on('topicDetail', (e) {
      setState(() {
        topic = e;
      });
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return
      DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        ColorScheme? lightColorScheme;
        ColorScheme? darkColorScheme;
        Color brandColor = const Color.fromRGBO(32, 82, 67, 1);
        if (lightDynamic != null && darkDynamic != null) {
          logDebug('dynamic取色成功');
          // dynamic取色成功
          lightColorScheme = lightDynamic.harmonized();
          darkColorScheme = darkDynamic.harmonized();
        } else {
          // dynamic取色失败，采用品牌色
          lightColorScheme = ColorScheme.fromSeed(seedColor: brandColor);
          darkColorScheme = ColorScheme.fromSeed(
            seedColor: brandColor,
            brightness: Brightness.dark,
          );
        }
        return
          MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              fontFamily: 'NotoSansSC',
              // fontFamily: GoogleFonts.getFont('Noto Sans').fontFamily,
              useMaterial3: true,
              colorScheme: lightColorScheme,
            ),
            darkTheme: ThemeData(
              fontFamily: 'NotoSansSC',
              // fontFamily: GoogleFonts.getFont('Noto Sans').fontFamily,
              useMaterial3: true,
              colorScheme: darkColorScheme,
            ),

            home: Scaffold(
              backgroundColor: Colors.transparent,
              body:  SafeArea(
                child: Container(
                  margin: const EdgeInsets.only(right: 10, top: 10),
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: Theme.of(context).colorScheme.surface,
                    // color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  ),
                  child: Center(
                    child: topic != null ? TopicDetail(topicDetail: topic) : Text('VVEX', style: TextStyle(
                      fontSize: 40,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary
                    )),
                    // child: topic != null ? Text(topic!.topicTitle) : const Text('VVEX'),
                  ),
                ),
              ),
            )
        );
      },
    );
  }
}
