import 'package:appscheme/appscheme.dart';
import 'package:get/get.dart';

class VvexScheme {
  static AppScheme appScheme = AppSchemeImpl.getInstance()!;
  static Future<void> init() async {
    ///
    final SchemeEntity? value = await appScheme.getInitScheme();
    if (value != null) {
      print('SchemeEntity:${value.host}');
    }

    /// 完整链接进入
    appScheme.getLatestScheme().then((SchemeEntity? value) {
      if (value != null) {
        print('getLatestScheme: ${value.host}');
      }
    });

    /// 注册从外部打开的Scheme监听信息 #
    appScheme.registerSchemeListener().listen((SchemeEntity? event) {
      if (event != null) {
        print('registerSchemeListener: ${event.host}');
        print('registerSchemeListener: ${event.path}');
        print('registerSchemeListener: ${event.query}');
        Get.toNamed(event.path!, arguments: null);
      }
    });
  }
}
