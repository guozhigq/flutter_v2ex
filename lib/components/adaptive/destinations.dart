import 'package:flutter/material.dart';

// These are the destinations used within the AdaptiveScaffold navigation
// builders.
const List<NavigationDestination> destinationsLarge = <NavigationDestination>[
  NavigationDestination(
    label: '主题列表',
    icon: Icon(Icons.home_outlined),
  ),
  NavigationDestination(
    label: '今日热议',
    icon: Icon(Icons.whatshot_outlined),
  ),
  NavigationDestination(
    label: '最近浏览',
    icon: Icon(Icons.history_outlined),
  ),
  NavigationDestination(
    label: '我的关注',
    icon: Icon(Icons.favorite_outline),
  ),
  NavigationDestination(
    label: '我的收藏',
    icon: Icon(Icons.star_border_rounded),
  ),
];


NavigationRailDestination slideInNavigationItem({
  required double begin,
  required AnimationController controller,
  required IconData icon,
  required String label,
}) {
  return NavigationRailDestination(
    icon: SlideTransition(
      position: Tween<Offset>(
        begin: Offset(begin, 0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      ),
      child: Icon(icon),
    ),
    label: Text(label),
  );
}