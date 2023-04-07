import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';

class Routes {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey();
  static const String toHomePage = '/';
  static const String toLoginPage = '/login';
}

Color getBackground(BuildContext context, tag) {
  List case_1 = ['secondBody', 'homePage', 'adaptMain'];
  List case_2 = ['searchBar', 'listItem'];

  // ipad 横屏
  bool isiPadHorizontal = Breakpoints.large.isActive(context);
  if (isiPadHorizontal) {
    if(case_1.contains(tag)){
      return Theme.of(context).colorScheme.onInverseSurface;
    }else if(case_2.contains(tag)){
      return Theme.of(context).colorScheme.background;
    }else{
      return Theme.of(context).colorScheme.onInverseSurface;
    }
  } else {
    if(case_1.contains(tag)){
      return Theme.of(context).colorScheme.background;
    }else if(case_2.contains(tag)){
      return Theme.of(context).colorScheme.onInverseSurface;
    }else{
      return Theme.of(context).colorScheme.onInverseSurface;
    }
  }
}
