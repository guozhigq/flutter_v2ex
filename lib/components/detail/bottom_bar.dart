import 'package:flutter/material.dart';

class DetailBottomBar extends StatefulWidget {
  final VoidCallback? onRefresh;
  final VoidCallback? onLoad;
  final bool? isVisible;

  const DetailBottomBar({
    this.onRefresh,
    this.onLoad,
    this.isVisible,
    super.key,
  });
  @override
  State<DetailBottomBar> createState() => _DetailBottomBarState();
}

class _DetailBottomBarState extends State<DetailBottomBar> {
  @override
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      height: widget.isVisible! ? 96.0 : 0,
      child: BottomAppBar(
        elevation: 1,
        child: Row(
          children: <Widget>[
            IconButton(
              tooltip: 'Open navigation menu',
              icon: const Icon(Icons.thumb_up_outlined),
              onPressed: () {},
            ),
            IconButton(
              tooltip: 'Search',
              icon: const Icon(Icons.mood),
              onPressed: () {},
            ),
            IconButton(
              tooltip: 'Favorite',
              icon: const Icon(Icons.refresh),
              onPressed: widget.onRefresh,
            ),
            IconButton(
              tooltip: 'Favorite',
              icon: const Icon(Icons.share_outlined),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
