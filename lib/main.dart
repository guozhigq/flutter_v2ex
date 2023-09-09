// ignore_for_file: avoid_print

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_v2ex/http/github.dart';

import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import 'package:flutter_v2ex/pages/page_home.dart';
import 'package:flutter_v2ex/utils/hive.dart';
import 'package:flutter_v2ex/utils/global.dart';
import 'package:flutter_v2ex/utils/string.dart';
import 'package:flutter_v2ex/utils/storage.dart';
import 'package:flutter_v2ex/utils/event_bus.dart';
import 'package:flutter_v2ex/router/app_pages.dart';
import 'package:flutter_v2ex/service/translation.dart';
import 'package:flutter_v2ex/service/local_notice.dart';
import 'package:flutter_v2ex/components/adaptive/main.dart';
import 'package:flutter_v2ex/components/common/custom_loading.dart';

void main() async {
  // 初始化配置
  await Global.init();
  // 入口
  runApp(const MyApp());
  // 配置状态栏
  if (Platform.isAndroid) {
    SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge); // Enable Edge-to-Edge on Android 10+
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      // Setting a transparent navigation bar color
      systemNavigationBarContrastEnforced: true,
      // Default
      statusBarBrightness: Brightness.light,
      // statusBarIconBrightness: Brightness.dark,
      systemNavigationBarIconBrightness:
          Brightness.dark, // This defines the color of the scrim
    ));
  }
}

// 主题色
Color brandColor = const Color.fromRGBO(32, 82, 67, 1);

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final SystemUiOverlayStyle kDark = SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent /*Android=27*/,
    systemNavigationBarDividerColor:
        Colors.transparent.withAlpha(1) /*Android=28,不能用全透明 */,
    systemNavigationBarIconBrightness: Brightness.dark /*Android=27*/,
    systemNavigationBarContrastEnforced: false /*Android=29*/,
  );

  final SystemUiOverlayStyle kLight = SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent /*Android=27*/,
    systemNavigationBarDividerColor:
        Colors.transparent.withAlpha(1) /*Android=28,不能用全透明 */,
    systemNavigationBarIconBrightness: Brightness.dark /*Android=27*/,
    systemNavigationBarContrastEnforced: false /*Android=29*/,
  );
  ThemeType currentThemeValue = ThemeType.system;
  EventBus eventBus = EventBus();
  DateTime? lastPopTime; //上次点击时间
  double globalFs = GStorage().getGlobalFs();

  @override
  void initState() {
    super.initState();

    // 读取默认主题配置
    setState(() {
      currentThemeValue = GStorage().getSystemType();
    });
    // 监听主题更改
    eventBus.on('themeChange', (arg) {
      GStorage().setSystemType(arg);
      setState(() {
        currentThemeValue = arg;
      });
    });
    // 未读消息
    eventBus.on('unRead', (arg) {
      LocalNoticeService().show(arg);
    });

    // 检查更新
    if (GStorage().getAutoUpdate()) {
      GithubApi.checkUpdate();
    }
  }

  @override
  void dispose() {
    eventBus.off('login');
    eventBus.off('topicReply');
    eventBus.off('ignoreTopic');
    eventBus.off('unRead');
    eventBus.off('themeChange');
    eventBus.off('editTabs');
    closeHive();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        ColorScheme? lightColorScheme;
        ColorScheme? darkColorScheme;
        if (lightDynamic != null && darkDynamic != null) {
          // dynamic取色成功
          lightColorScheme = lightDynamic.harmonized();
          darkColorScheme = darkDynamic.harmonized();
        } else {
          // dynamic取色失败，采用品牌色
          lightColorScheme = ColorScheme.fromSeed(seedColor: brandColor);
          darkColorScheme = ColorScheme.fromSeed(
            seedColor: brandColor,
            brightness: Brightness.dark,
          );
        }
        return GetMaterialApp(
          title: 'VVEX',
          debugShowCheckedModeBanner: false,
          initialRoute: '/',
          getPages: AppPages.getPages,
          theme: ThemeData(
            fontFamily: 'NotoSansSC',
            useMaterial3: true,
            colorScheme: currentThemeValue == ThemeType.dark
                ? darkColorScheme
                : lightColorScheme,
          ),
          darkTheme: ThemeData(
            fontFamily: 'NotoSansSC',
            useMaterial3: true,
            colorScheme: currentThemeValue == ThemeType.light
                ? lightColorScheme
                : darkColorScheme,
          ),
          translations: Translation(),
          localizationsDelegates: const [
            GlobalCupertinoLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          locale: const Locale("zh", "CN"),
          supportedLocales: const [Locale("zh", "CN"), Locale("en", "US")],
          fallbackLocale: const Locale("zh", "CN"),
          home: const HomePage(),
          navigatorKey: Routes.navigatorKey,
          routingCallback: (routing) {
            if (routing!.previous == '/login') {
              return;
            }
          },
          navigatorObservers: [FlutterSmartDialog.observer],
          builder: (BuildContext context, Widget? child) {
            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: currentThemeValue == ThemeType.dark ? kDark : kLight,
              child: FlutterSmartDialog(
                loadingBuilder: (String msg) => CustomLoading(msg: msg),
                toastBuilder: (String msg) => CustomToast(msg: msg),

                /// 设置文字大小不跟随系统更改
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                      textScaleFactor: GStorage().getGlobalFs() / 14.0),
                  // 适配 pad 布局
                  child: CAdaptiveLayout(child: child),
                  // mob布局
                  // child: child!,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
