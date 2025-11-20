import 'package:appscheme/appscheme.dart';
import 'package:get/get.dart';
import 'package:flutter_v2ex/utils/logger.dart';

class VvexScheme {
  static AppScheme appScheme = AppSchemeImpl.getInstance();
  static Future<void> init() async {
    ///
    final SchemeEntity? value = await appScheme.getInitScheme();
    if (value != null) {
      logDebug('SchemeEntity:${value.host}');
    }

    /// 完整链接进入
    appScheme.getLatestScheme().then((SchemeEntity? value) {
      if (value != null) {
        logDebug('getLatestScheme: ${value.host}');
      }
    });

    /// 注册从外部打开的Scheme监听信息 #
    appScheme.registerSchemeListener().listen((SchemeEntity? event) {
      if (event != null) {
        logDebug('registerSchemeListener: ${event.host}');
        logDebug('registerSchemeListener: ${event.path}');
        logDebug('registerSchemeListener: ${event.query}');
        Get.toNamed(event.path!, arguments: null);
      }
    });
  }
}
