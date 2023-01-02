import 'package:flutter/material.dart';
import 'package:flutter_v2ex/pages/tabs/home_page.dart';
import 'package:flutter_v2ex/pages/tabs/fav_page.dart';
import 'package:flutter_v2ex/pages/tabs/mine_page.dart';

class AppTab extends StatefulWidget {
  const AppTab({super.key});

  @override
  State<AppTab> createState() => _AppTabState();
}

class _AppTabState extends State<AppTab> {
  int screenIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: screenIndex,
        children: [
          // createScreenFor(screenIndex),
          HomePage(),
          FavPage(),
          MinePage()
        ],
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: handleScreenChanged,
        selectedIndex: screenIndex,
        animationDuration: const Duration(milliseconds: 300),
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(
              Icons.lens_outlined,
              size: 19,
            ),
            label: "首页",
          ),
          NavigationDestination(
            icon: Icon(
              Icons.favorite_border,
              size: 19,
            ),
            label: "收藏",
          ),
          NavigationDestination(
            icon: Icon(
              Icons.check_box_outline_blank,
              size: 19,
            ),
            label: "我的",
          ),
        ],
      ),
    );
  }

  void handleScreenChanged(int selectedScreen) {
    setState(() {
      screenIndex = selectedScreen;
    });
  }

  Widget createScreenFor(int screenIndex) {
    switch (screenIndex) {
      case 0:
        return const HomePage();
      case 1:
        return const FavPage();
      case 2:
        return const MinePage();
      default:
        return const HomePage();
    }
  }
}
