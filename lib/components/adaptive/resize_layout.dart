import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:flutter_v2ex/pages/t/:topicId.dart';

class ResizeLayout extends StatefulWidget {
  Widget leftLayout;
  Widget? rightLayout;

  ResizeLayout({
    Key? key,
    required this.leftLayout,
    this.rightLayout,
  }) : super(key: key);

  @override
  State<ResizeLayout> createState() => _ResizeLayoutState();
}

class _ResizeLayoutState extends State<ResizeLayout> {
  double _offset = 0.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double maxWidth = constraints.maxWidth;
        double dividerWidth = 16;
        double rightSafeOffest = 12;
        // 左右比例
        double lfScale = 0.4;
        double rgScale = 1 - lfScale;
        double minScale = 0.35;
        final lfWidth = (maxWidth - 28) * lfScale;
        final rgWidth = (maxWidth - 28) * rgScale;
        final minWidth = (maxWidth - 28) * minScale;

        if (lfWidth + _offset < minWidth) {
          _offset = minWidth - lfWidth;
        }
        if (rgWidth - _offset < minWidth) {
          _offset = rgWidth - minWidth;
        }

        bool isiPadHorizontal = Breakpoints.large.isActive(context);
        return Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(
              // 非ipad横屏 使用屏幕宽度
              width: isiPadHorizontal ? lfWidth + _offset : maxWidth,
              child: SafeArea(
                bottom: false,
                child: widget.leftLayout,
              ),
            ),
            if (isiPadHorizontal) ...[
              SizedBox(
                width: dividerWidth,
                child: DragDivider(
                  onSize: (double delta) => setState(() {
                    _offset = _offset += delta;
                  }),
                ),
              ),
              SizedBox(
                width: rgWidth - _offset,
                child: DynamicColorBuilder(
                  builder:
                      (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
                    ColorScheme? lightColorScheme;
                    ColorScheme? darkColorScheme;
                    Color brandColor = const Color.fromRGBO(32, 82, 67, 1);
                    if (lightDynamic != null && darkDynamic != null) {
                      print('dynamic取色成功');
                      // dynamic取色成功
                      lightColorScheme = lightDynamic.harmonized();
                      darkColorScheme = darkDynamic.harmonized();
                    } else {
                      // dynamic取色失败，采用品牌色
                      lightColorScheme =
                          ColorScheme.fromSeed(seedColor: brandColor);
                      darkColorScheme = ColorScheme.fromSeed(
                        seedColor: brandColor,
                        brightness: Brightness.dark,
                      );
                    }
                    return MaterialApp(
                      useInheritedMediaQuery: true,
                      debugShowCheckedModeBanner: false,
                      theme: ThemeData(
                        fontFamily: 'NotoSansSC',
                        useMaterial3: true,
                        colorScheme: lightColorScheme,
                      ),
                      darkTheme: ThemeData(
                        colorScheme: darkColorScheme,
                      ),
                      home: SafeArea(
                        top: true,
                        bottom: false,
                        child: Container(
                          clipBehavior: Clip.hardEdge,
                          margin: const EdgeInsets.only(top: 10, bottom: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: widget.rightLayout ?? TopicDetail(),
                        ),
                      ),
                    );
                  },
                ),
                // child: SafeArea(
                //   child: Container(
                //     margin: const EdgeInsets.only(top: 4),
                //     clipBehavior: Clip.hardEdge,
                //     decoration:
                //         BoxDecoration(borderRadius: BorderRadius.circular(12)),
                //     child: widget.rightLayout ?? TopicDetail(),
                //   ),
                // ),
              ),
              SizedBox(width: rightSafeOffest),
            ]
          ],
        );
      },
    );
  }
}

class DragDivider extends StatelessWidget {
  final Function(double delta) onSize;

  const DragDivider({Key? key, required this.onSize}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        onSize(details.delta.dx);
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.alias,
        child: Center(
          child: Container(
            width: 4,
            height: 30,
            margin: const EdgeInsets.only(left: 3, right: 3),
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
    );
  }
}
