import 'package:flutter/material.dart';

class DetailBottomBar extends StatefulWidget {
  final VoidCallback? onRefresh;
  final VoidCallback? onLoad;

  DetailBottomBar({
    this.onRefresh,
    this.onLoad,
    super.key,
  });
  @override
  State<DetailBottomBar> createState() => _DetailBottomBarState();
}

class _DetailBottomBarState extends State<DetailBottomBar> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        height: MediaQuery.of(context).padding.bottom + 80,
        width: double.infinity,
        padding: const EdgeInsets.only(top: 12, right: 16, bottom: 16, left: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onInverseSurface,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withAlpha(100),
              offset: const Offset(44, 4),
              blurRadius: 4,
              blurStyle: BlurStyle.outer,
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          // mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              icon: const Icon(Icons.thumb_up_outlined),
              onPressed: () {},
              color: Theme.of(context).colorScheme.primary,
            ),
            IconButton(
              icon: const Icon(Icons.mood),
              onPressed: () {},
              color: Theme.of(context).colorScheme.primary,
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: widget.onRefresh,
              color: Theme.of(context).colorScheme.primary,
            ),
            IconButton(
              icon: const Icon(Icons.share_outlined),
              onPressed: () {},
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}
