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
        // ipad 竖屏
        bool isiPadHorizontal = Breakpoints.large.isActive(context);
        // ipad 横屏
        bool isiPadVertical = Breakpoints.medium.isActive(context);
        double maxWidth = constraints.maxWidth;
        double dividerWidth = isiPadVertical ? 8 : 16;
        double rightSafeOffest = 12;
        // 左右比例
        double lfScale = 0.75;
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
              // 横屏状态可拖拽
              SizedBox(
                width: dividerWidth,
                child: isiPadHorizontal ? DragDivider(
                  onSize: (double delta) => setState(() {
                    _offset = _offset += delta;
                  }),
                ) : null,
              ),
              SizedBox(
                width: rgWidth - _offset,
                child: SafeArea(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10),
                    clipBehavior: Clip.hardEdge,
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(10)),
                    child: widget.rightLayout ?? TopicDetail(),
                  ),
                ),
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
