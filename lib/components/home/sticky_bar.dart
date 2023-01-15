import 'package:flutter/material.dart';
// import 'package:flutter_v2ex/components/home/search_bar.dart';

class HomeStickyBar extends StatelessWidget {
  const HomeStickyBar({super.key, required this.tabs});
  final List<Map<dynamic, dynamic>> tabs;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 42,
      child: Row(
        children: [
          Expanded(
            child: TabBar(
              // controller: _tabController,
              onTap: (index) {},
              isScrollable: true,
              enableFeedback: true,
              indicatorSize: TabBarIndicatorSize.label,
              indicatorColor: Theme.of(context).colorScheme.primary,
              labelStyle: Theme.of(context).textTheme.titleSmall,
              // label active颜色
              labelColor: Theme.of(context).colorScheme.primary,
              // label 默认颜色
              unselectedLabelColor:
                  Theme.of(context).colorScheme.inverseSurface,
              padding: const EdgeInsets.only(bottom: 3),
              splashBorderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
                bottomLeft: Radius.circular(14),
                bottomRight: Radius.circular(14),
              ),
              tabs: tabs.map((item) {
                return Tab(text: item['name']);
              }).toList(),
            ),
          ),
          // const SizedBox(width: 5),
          SizedBox(
            height: 50,
            child: Center(
              child: IconButton(
                onPressed: () => {Navigator.pushNamed(context, '/nodes')},
                icon: const Icon(Icons.segment),
              ),
            ),
          ),
        ],
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
