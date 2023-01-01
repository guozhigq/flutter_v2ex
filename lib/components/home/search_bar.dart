import 'package:flutter/material.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 58,
      padding: const EdgeInsets.only(top: 10, right: 10, left: 10),
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: Container(
          width: 200,
          height: 48,
          color: Theme.of(context).colorScheme.onInverseSurface,
          padding: const EdgeInsets.only(right: 11, left: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                const Icon(Icons.search_outlined),
                const SizedBox(width: 12),
                Text(
                  '搜索...',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ]),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  'assets/images/avatar.png',
                  fit: BoxFit.cover,
                  width: 35,
                  height: 35,
                ),
              ),
            ],
          ),
        ),
      ),
      // height: 50,
      // decoration: BoxDecoration(
      //   color: Theme.of(context).colorScheme.surface,
      //   borderRadius: BorderRadius.circular(50),
      // ),
      // margin: const EdgeInsets.only(top: 10, right: 10, bottom: 0, left: 10),
      // padding: const EdgeInsets.only(right: 11, left: 18),
      // child: Row(
      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //   children: [
      //     Row(children: [
      //       const Icon(Icons.search_outlined),
      //       const SizedBox(width: 12),
      //       Text(
      //         '搜索...',
      //         style: Theme.of(context).textTheme.bodyMedium,
      //       ),
      //     ]),
      //     Container(
      //       decoration: BoxDecoration(
      //         color: Colors.white,
      //         borderRadius: BorderRadius.circular(50),
      //       ),
      //       clipBehavior: Clip.antiAlias,
      //       // child: Image.network(
      //       //   "https://desk-fd.zol-img.com.cn/t_s960x600c5/g6/M00/03/0E/ChMkKWDZLXSICljFAC1U9uUHfekAARQfgG_oL0ALVUO515.jpg",
      //       //   fit: BoxFit.cover,
      //       //   width: 35,
      //       //   height: 35,
      //       // ),
      //       child: Image.asset(
      //         'assets/avatar.png',
      //         fit: BoxFit.cover,
      //         width: 35,
      //         height: 35,
      //       ),
      //     ),
      //   ],
      // ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight > minHeight ? maxHeight : minHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
