import 'package:flutter/material.dart';

// class HomeStickyBar extends StatefulWidget {
//   HomeStickyBar({super.key, required this.tabs});
//   List<Map<dynamic, dynamic>> tabs;
//   @override
//   State<HomeStickyBar> createState() => _HomeStickyBarState();
// }

// class _HomeStickyBarState extends State<HomeStickyBar> {
//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SliverPersistentHeader(
//       pinned: true, //是否固定在顶部
//       floating: true,
//       delegate: _SliverAppBarDelegate(
//         minHeight: 50, //收起的高度
//         maxHeight: 50, //展开的最大高度
//         child: Column(
//           children: [
//             Container(
//               width: double.infinity,
//               height: 50,
//               decoration: BoxDecoration(
//                 color: Theme.of(context).colorScheme.surfaceVariant,
//                 border: Border(
//                   bottom: BorderSide(
//                     width: 0.5,
//                     color: Theme.of(context).colorScheme.onInverseSurface,
//                   ),
//                 ),
//               ),
//               padding: const EdgeInsets.only(top: 5),
//               child: TabBar(
//                 // controller: _tabController,
//                 onTap: (index) {},
//                 isScrollable: true,
//                 indicatorSize: TabBarIndicatorSize.label,
//                 indicatorColor: Theme.of(context).colorScheme.primary,
//                 labelStyle: Theme.of(context).textTheme.titleSmall,
//                 // label active颜色
//                 labelColor: Theme.of(context).colorScheme.primary,
//                 // label 默认颜色
//                 unselectedLabelColor:
//                     Theme.of(context).colorScheme.inverseSurface,
//                 enableFeedback: true,
//                 // overlayColor: ,
//                 tabs: widget.tabs.map((f) {
//                   return Tab(text: f['name']);
//                 }).toList(),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class HomeStickyBar extends StatelessWidget {
  const HomeStickyBar({super.key, required this.tabs});
  final List<Map<dynamic, dynamic>> tabs;
  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true, //是否固定在顶部
      floating: true,
      delegate: _SliverAppBarDelegate(
        minHeight: 45, //收起的高度
        maxHeight: 45, //展开的最大高度
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 45,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                border: Border(
                  bottom: BorderSide(
                    width: 0.5,
                    color: Theme.of(context).colorScheme.onInverseSurface,
                  ),
                ),
              ),
              padding: const EdgeInsets.only(top: 5),
              child: TabBar(
                // controller: _tabController,
                onTap: (index) {},
                isScrollable: true,
                indicatorSize: TabBarIndicatorSize.label,
                indicatorColor: Theme.of(context).colorScheme.primary,
                labelStyle: Theme.of(context).textTheme.titleSmall,
                // label active颜色
                labelColor: Theme.of(context).colorScheme.primary,
                // label 默认颜色
                unselectedLabelColor:
                    Theme.of(context).colorScheme.inverseSurface,
                enableFeedback: true,
                // overlayColor: ,
                tabs: tabs.map((f) {
                  return Tab(text: f['name']);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
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
