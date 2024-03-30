import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:flutter_v2ex/models/tabs.dart';
import 'package:container_tab_indicator/container_tab_indicator.dart';
import 'package:flutter_v2ex/pages/home/controller.dart';
import 'package:get/get.dart';

class HomeStickyBar extends StatelessWidget {
  const HomeStickyBar({super.key, required this.tabs, required this.ctr});

  final List<TabModel> tabs;
  final TabController ctr;

  @override
  Widget build(BuildContext context) {
    final TabStateController tabStateController = Get.put(TabStateController());
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: Row(
        children: [
          Expanded(
            child: AdpatTabBar(
              controller: ctr,
              tabs: tabs,
              onTap: (index) {
                if (!ctr.indexIsChanging) {
                  // tap(index);
                  tabStateController.setTabIndex(index);
                }
              },
            ),
          ),
          // const SizedBox(width: 5),
          if (!Breakpoints.mediumAndUp.isActive(context))
            SizedBox(
              height: 50,
              child: Center(
                child: IconButton(
                  onPressed: () => {Navigator.pushNamed(context, '/nodes')},
                  icon: const Icon(Icons.segment_rounded, size: 19),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class AdpatTabBar extends StatelessWidget {
  final List tabs;
  final TabController? controller;
  final Function? onTap;

  const AdpatTabBar({
    Key? key,
    required this.tabs,
    this.controller,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isiPad = Breakpoints.mediumAndUp.isActive(context);
    return TabBar(
      controller: controller,
      dividerColor: Colors.transparent,
      tabAlignment: tabs.length > 4 ? TabAlignment.start : TabAlignment.center,
      onTap: (index) => onTap?.call(index),
      isScrollable: true,
      enableFeedback: true,
      splashBorderRadius: BorderRadius.circular(6),
      padding: EdgeInsets.symmetric(horizontal: isiPad ? 10 : 5),
      tabs: tabs.map((item) {
        return Tab(text: item.name);
      }).toList(),
      // iPad
      labelColor: isiPad
          ? Theme.of(context).colorScheme.onBackground
          : Theme.of(context).colorScheme.primary,
      indicator: isiPad
          ? ContainerTabIndicator(
              width: 60,
              height: 36,
              radius: BorderRadius.circular(8.0),
              color: Theme.of(context).colorScheme.surfaceVariant,
            )
          : null,
    );
  }
}
