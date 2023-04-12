import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_v2ex/utils/string.dart';
import 'package:flutter_v2ex/utils/storage.dart';

class FontSizeController extends GetxController {
  static FontSizeController to = Get.find();
  var globalFs = GStorage().getGlobalFs().obs;
  late TextTheme textTheme;

  @override
  void onInit() {
    super.onInit();
    // 获取字体大小
    textTheme = customFsTheme(fontSize: globalFs.value, type: 'init');
  }

  TextTheme customFsTheme({double fontSize = 14, required String type}) {
    double scale =
        fontSize / (type == 'init' ? baseFontSize : GStorage().getTempFs());
    if (Get.context != null) {
      var _textTheme = Theme.of(Get.context!).textTheme;
      GStorage().setTempFs(fontSize);
      return TextTheme(
        displayLarge: updateFontSize(_textTheme.displayLarge!, scale),
        displayMedium: updateFontSize(_textTheme.displayMedium!, scale),
        displaySmall: updateFontSize(_textTheme.displaySmall!, scale),
        headlineLarge: updateFontSize(_textTheme.headlineLarge!, scale),
        headlineMedium: updateFontSize(_textTheme.headlineMedium!, scale),
        headlineSmall: updateFontSize(_textTheme.headlineSmall!, scale),
        titleLarge: updateFontSize(_textTheme.titleLarge!, scale),
        titleMedium: updateFontSize(_textTheme.titleMedium!, scale),
        titleSmall: updateFontSize(_textTheme.titleSmall!, scale),
        labelLarge: updateFontSize(_textTheme.labelLarge!, scale),
        labelMedium: updateFontSize(_textTheme.labelMedium!, scale),
        labelSmall: updateFontSize(_textTheme.labelSmall!, scale),
        bodyLarge: updateFontSize(_textTheme.bodyLarge!, scale),
        bodyMedium: updateFontSize(_textTheme.bodyMedium!, scale),
        bodySmall: updateFontSize(_textTheme.bodySmall!, scale),
      );
    } else {
      return const TextTheme();
    }
  }

  TextStyle updateFontSize(TextStyle textStyle, double scale) {
    return TextStyle(fontSize: textStyle.fontSize! * scale);
  }

  TextTheme get getFontSize =>
      customFsTheme(fontSize: globalFs.value, type: 'init');

  void setFontSize({fontSize}) {
    globalFs.value = fontSize;
    textTheme = customFsTheme(fontSize: fontSize, type: 'set');
    Get.changeTheme(ThemeData(
        textTheme: textTheme,
        useMaterial3: true,
        colorSchemeSeed: const Color.fromRGBO(32, 82, 67, 1)));
    // Get.forceAppUpdate();
    // update();
  }
}
