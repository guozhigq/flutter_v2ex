import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:flutter_v2ex/components/adaptive/destinations.dart';
import 'package:flutter_v2ex/components/adaptive/trailing.dart';
import 'package:flutter_v2ex/pages/page_home.dart';
import 'package:flutter_v2ex/pages/page_hot.dart';
import 'package:flutter_v2ex/pages/t/:topicId.dart';

class CAdaptiveLayout extends StatefulWidget {
  Widget? child;

  CAdaptiveLayout({this.child, super.key});

  @override
  State<CAdaptiveLayout> createState() => _CAdaptiveLayoutState();
}

class _CAdaptiveLayoutState extends State<CAdaptiveLayout>
    with TickerProviderStateMixin, ChangeNotifier {
  ValueNotifier<bool?> showGridView = ValueNotifier<bool?>(false);

  // The index of the navigation screen. Only impacts body/secondaryBody
  int _navigationIndex = 0;

  // The controllers used for the staggered animation of the navigation elements.
  late AnimationController _homeIconSlideController;
  late AnimationController _inboxIconSlideController;
  late AnimationController _articleIconSlideController;
  late AnimationController _chatIconSlideController;
  late AnimationController _videoIconSlideController;

  @override
  void initState() {
    showGridView.addListener(() {
      // Navigator.popUntil(
      //     context, (Route<dynamic> route) => route.settings.name == '/');
      _homeIconSlideController
        ..reset()
        ..forward();
      _inboxIconSlideController
        ..reset()
        ..forward();
      _articleIconSlideController
        ..reset()
        ..forward();
      _chatIconSlideController
        ..reset()
        ..forward();
      _videoIconSlideController
        ..reset()
        ..forward();
    });
    _homeIconSlideController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    )..forward();
    _inboxIconSlideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..forward();
    _articleIconSlideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    )..forward();
    _chatIconSlideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();
    _videoIconSlideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
    // TODO: implement initState
    print(widget.child);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Updating the listener value.
    showGridView.value = Breakpoints.mediumAndUp.isActive(context);

    return Scaffold(
      body: AdaptiveLayout(
        internalAnimations: false,
        bodyRatio: Breakpoints.medium.isActive(context) ? 0.52 : 0.45,
        primaryNavigation: SlotLayout(
          config: <Breakpoint, SlotLayoutConfig?>{
            Breakpoints.medium: SlotLayout.from(
              // Every SlotLayoutConfig takes a key and a builder. The builder
              // is to save memory that would be spent on initialization.
              key: const Key('primaryNavigation'),
              builder: (_) {
                return AdaptiveScaffold.standardNavigationRail(
                  // Usually it would be easier to use a builder from
                  // AdaptiveScaffold for these types of navigation but this
                  // navigation has custom staggered item animations.
                  onDestinationSelected: (int index) {
                    setState(() {
                      _navigationIndex = index;
                    });
                  },
                  selectedIndex: _navigationIndex,
                  backgroundColor: const Color.fromARGB(0, 255, 255, 255),
                  destinations: <NavigationRailDestination>[
                    slideInNavigationItem(
                      begin: -1,
                      controller: _homeIconSlideController,
                      icon: Icons.home_outlined,
                      label: '主题列表',
                    ),
                    slideInNavigationItem(
                      begin: -1,
                      controller: _inboxIconSlideController,
                      icon: Icons.whatshot_outlined,
                      label: '今日热议',
                    ),
                    slideInNavigationItem(
                      begin: -2,
                      controller: _articleIconSlideController,
                      icon: Icons.history_outlined,
                      label: '最近浏览',
                    ),
                    slideInNavigationItem(
                      begin: -3,
                      controller: _chatIconSlideController,
                      icon: Icons.favorite_outline,
                      label: '我的关注',
                    ),
                    slideInNavigationItem(
                      begin: -4,
                      controller: _videoIconSlideController,
                      icon: Icons.star_border_rounded,
                      label: '我的收藏',
                    ),
                  ],
                  trailing: const TrailingNavRail(),
                );
              },
            ),
            Breakpoints.large: SlotLayout.from(
              key: const Key('Large primaryNavigation'),
              // The AdaptiveScaffold builder here greatly simplifies
              // navigational elements.
              builder: (_) => AdaptiveScaffold.standardNavigationRail(
                // leading: const _LargeComposeIcon(),
                width: 160,
                onDestinationSelected: (int index) {
                  setState(() {
                    _navigationIndex = index;
                  });
                },
                selectedIndex: _navigationIndex,
                trailing: const TrailingNavRail(),
                extended: true,
                destinations: destinationsLarge.map((_) {
                  return AdaptiveScaffold.toRailDestination(_);
                }).toList(),
              ),
            ),
          },
        ),
        // main screen
        body: SlotLayout(
          config: <Breakpoint, SlotLayoutConfig?>{
            Breakpoints.standard: SlotLayout.from(
              key: const Key('body'),
              builder: (_) => widget.child ?? const _ExamplePage(),
            ),
          },
        ),
        // second screen
        secondaryBody: _navigationIndex >= 0
            ? SlotLayout(
                config: <Breakpoint, SlotLayoutConfig?>{
                  Breakpoints.large: SlotLayout.from(
                    // This overrides the default behavior of the secondaryBody
                    // disappearing as it is animating out.
                    outAnimation: AdaptiveScaffold.stayOnScreen,
                    key: const Key('Secondary Body'),
                    builder: (_) => SafeArea(
                      bottom: false,
                        child: Container(
                      margin: const EdgeInsets.only(right: 10, top: 10),
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color:
                              Theme.of(context).colorScheme.onInverseSurface),
                      child: const TopicDetail(),
                    )),
                  )
                },
              )
            : null,
      ),
    );
  }
}

class _ExamplePage extends StatelessWidget {
  const _ExamplePage();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(),
        color: Theme.of(context).colorScheme.background,
      ),
    );
  }
}
