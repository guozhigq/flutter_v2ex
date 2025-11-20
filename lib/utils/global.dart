import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:flutter_v2ex/http/dio_web.dart';
import 'package:flutter_v2ex/http/init.dart';
import 'package:flutter_v2ex/service/local_notice.dart';
import 'package:flutter_v2ex/utils/hive.dart';
import 'package:flutter_v2ex/utils/proxy.dart';
import 'package:flutter_v2ex/utils/storage.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_v2ex/utils/logger.dart';

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
      return Theme.of(context).colorScheme.surface;
    }else{
      return Theme.of(context).colorScheme.onInverseSurface;
    }
  } else {
    if(case_1.contains(tag)){
      return Theme.of(context).colorScheme.surface;
    }else if(case_2.contains(tag)){
      return Theme.of(context).colorScheme.onInverseSurface;
    }else{
      return Theme.of(context).colorScheme.onInverseSurface;
    }
  }
}

class Global {
  static Future init() async {
    WidgetsFlutterBinding.ensureInitialized();
    // 消息通知初始化
    try {
      await LocalNoticeService().init();
    } catch (err) {
      logDebug('LocalNoticeService err: ${err.toString()}');
    }
    // 配置代理
    CustomProxy().init();
    // 本地存储初始化
    try {
      await GetStorage.init();
    } catch (err) {
      logDebug('GetStorage err: ${err.toString()}');
    }
    // Hive初始化 历史浏览box
    await initHive();
    // Dio 初始化
    await Request().setCookie();
    // 自动签到
    var userInfo = GStorage().getUserInfo();
    if (userInfo.isNotEmpty && GStorage().getAutoSign()) {
      DioRequestWeb.dailyMission();
    }
    // 高帧率滚动性能优化
    // GestureBinding.instance.resamplingEnabled = true;
  }
}