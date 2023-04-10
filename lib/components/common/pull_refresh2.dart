import 'package:flutter/material.dart';

class PullRefresh extends StatefulWidget {
  final Widget? child;
  final onChildRefresh;
  final onChildLoad;
  final int? currentPage;
  final int? totalPage;
  final ScrollController? ctr;

  const PullRefresh({
    // this.ctr,
    this.child,
    this.onChildRefresh,
    this.onChildLoad,
    this.currentPage,
    this.totalPage,
    this.ctr,
    super.key,
  });

  @override
  State<PullRefresh> createState() => _PullRefreshState();
}

class _PullRefreshState extends State<PullRefresh> {
  late ScrollController _controller = ScrollController();
  bool _isLoadingMore = false;
  bool showBackTopBtn = false;

  @override
  void initState() {
    _controller = widget.ctr!;
    onLoad();
    // TODO: implement initState
    super.initState();
  }

  // 上拉
  void onLoad() {
    _controller.addListener(
          () {
        if (_controller.position.pixels >=
            _controller.position.maxScrollExtent - 100) {
          if (!_isLoadingMore) {
            _isLoadingMore = true;
            widget.onChildLoad();
          }
        }

        var screenHeight = MediaQuery.of(context).size.height;
        if (_controller.offset >= screenHeight && showBackTopBtn == false) {
          setState(() {
            showBackTopBtn = true;
          });
        } else if (_controller.offset < screenHeight && showBackTopBtn) {
          setState(() {
            showBackTopBtn = false;
          });
        }
      },
    );
  }

  void animateToTop() async {
    await _controller.animateTo(0,
        duration: const Duration(milliseconds: 500), curve: Curves.ease);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scrollbar(
          controller: _controller,
          child: RefreshIndicator(
            // 下拉
            onRefresh: () async {
              await widget.onChildRefresh();
            },
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                scrollbars: false,
              ),
              child: Expanded(
                child:  Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    widget.child!,
                    if(widget.currentPage! < widget.totalPage!)
                      Text('加载更多')
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          right: 20,
          bottom: 20,
          child: AnimatedScale(
            scale: showBackTopBtn ? 1 : 0,
            curve: Curves.easeInOut,
            duration: const Duration(milliseconds: 300),
            child: GestureDetector(
              child: FloatingActionButton(
                heroTag: null,
                child: const Icon(Icons.refresh_rounded),
                onPressed: () => animateToTop(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
