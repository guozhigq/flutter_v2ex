import 'package:flutter/material.dart';
import 'package:easy_refresh/easy_refresh.dart';

// onChildLoad 中传入_currentPage < _totalPage，开启PullRefresh 【没有更多内容了】的提示
//
class PullRefresh extends StatefulWidget {
  // final EasyRefreshController? ctr; // 控制器
  final Widget? child;
  final onChildRefresh;
  final onChildLoad;
  final int? currentPage;
  final int? totalPage;

  const PullRefresh({
    // this.ctr,
    this.child,
    this.onChildRefresh,
    this.onChildLoad,
    this.currentPage,
    this.totalPage,
    super.key,
  });

  @override
  State<PullRefresh> createState() => _PullRefreshState();
}

class _PullRefreshState extends State<PullRefresh> {
  // late EasyRefreshController _controller;

  final EasyRefreshController _controller = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );

  final _MIProperties _headerProperties = _MIProperties(name: 'Header');
  final _CIProperties _footerProperties = _CIProperties(
    name: 'Footer',
    disable: true,
    alignment: MainAxisAlignment.start,
    infinite: true,
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EasyRefresh(
      clipBehavior: Clip.none,
      controller: _controller,
      header: MaterialHeader(
        backgroundColor: ThemeData().canvasColor,
        clamping: _headerProperties.clamping,
        showBezierBackground: _headerProperties.background,
        bezierBackgroundAnimation: _headerProperties.animation,
        bezierBackgroundBounce: _headerProperties.bounce,
        infiniteOffset: _headerProperties.infinite ? 100 : null,
        springRebound: _headerProperties.listSpring,
      ),
      footer: ClassicFooter(
        clamping: _footerProperties.clamping,
        backgroundColor: _footerProperties.background
            ? Theme.of(context).colorScheme.surfaceVariant
            : null,
        mainAxisAlignment: _footerProperties.alignment,
        showMessage: _footerProperties.message,
        showText: _footerProperties.text,
        infiniteOffset: _footerProperties.infinite ? 70 : null,
        triggerWhenReach: _footerProperties.immediately,
        hapticFeedback: true,
        dragText: 'Pull to load',
        armedText: 'Release ready',
        readyText: 'Loading...',
        processingText: '加载中...',
        succeededIcon: const Icon(Icons.auto_awesome),
        processedText: '加载完成',
        textStyle: const TextStyle(fontSize: 14),
        noMoreText: '加载完成',
        noMoreIcon: const Icon(Icons.auto_awesome),
        failedText: '加载失败',
        messageText: '上次更新 %T',
        triggerOffset: 100,
        // position: IndicatorPosition.locator,
      ),
      onRefresh: widget.onChildRefresh != null
          ? () async {
              await widget.onChildRefresh();
              // ignore: avoid_print
              print('onRefresh Finish');
              _controller.finishRefresh();
              _controller.resetFooter();
            }
          : null,
      // 下拉
      onLoad: widget.onChildLoad != null
          ? () async {
              if (widget.currentPage == widget.totalPage!) {
                _controller.finishLoad();
                _controller.resetFooter();
                return IndicatorResult.noMore;
              }
              await widget.onChildLoad!();
              // ignore: avoid_print
              print('onLoad Finish');
              print('widget.currentPage: ${widget.currentPage}');
              print('widget.totalPage: ${widget.totalPage}');
              _controller.finishLoad();
              _controller.resetFooter();
            }
          : null,
      child: widget.child,
    );
  }
}

class _MIProperties {
  final String name;
  bool clamping = true;
  bool background = false;
  bool animation = false;
  bool bounce = false;
  bool infinite = false;
  bool listSpring = false;

  _MIProperties({
    required this.name,
  });
}

class _CIProperties {
  final String name;
  bool disable = false;
  bool clamping = false;
  bool background = false;
  MainAxisAlignment alignment;
  bool message = true;
  bool text = true;
  bool infinite;
  bool immediately = false;

  _CIProperties({
    required this.name,
    required this.alignment,
    required this.infinite,
    required disable,
  });
}
