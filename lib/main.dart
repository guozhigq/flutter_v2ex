import 'dart:io';
import 'package:get/get.dart';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dynamic_color/dynamic_color.dart';

import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_v2ex/components/common/custom_loading.dart';
import 'package:flutter_v2ex/utils/global.dart';
import 'package:flutter_v2ex/utils/string.dart';
import 'package:flutter_v2ex/utils/event_bus.dart';
import 'package:flutter_v2ex/utils/storage.dart';

import 'router/app_pages.dart';
import 'package:flutter_v2ex/pages/page_home.dart';
import 'package:flutter_v2ex/service/local_notice.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:system_proxy/system_proxy.dart';

class ProxiedHttpOverrides extends HttpOverrides {
  String _port;
  String _host;
  ProxiedHttpOverrides(this._host, this._port);

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      // set proxy
      ..findProxy = (uri) {
        return "PROXY $_host:$_port;";
      };
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 消息通知初始化
  await LocalNoticeService().init();

  Map<String, String>? proxy = await SystemProxy.getProxySettings();
  if (proxy != null) {
    HttpOverrides.global = ProxiedHttpOverrides(proxy['host']!, proxy['port']!);
  }

  // 本地存储初始化
  await GetStorage.init();
  runApp(const MyApp());

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
Color brandColor = const Color.fromRGBO(58, 105, 154, 100);

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeType currentThemeValue = ThemeType.system;
  EventBus eventBus = EventBus();
  DateTime? lastPopTime; //上次点击时间

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
  }

  @override
  void dispose() {
    EventBus().offAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        ColorScheme? lightColorScheme;
        ColorScheme? darkColorScheme;
        print('dynamic取色失败，采用品牌色');
        if (lightDynamic != null && darkDynamic != null) {
          print('dynamic取色成功');
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
          debugShowCheckedModeBanner: true,
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
          home: WillPopScope(
            onWillPop: () async {
              SmartDialog.showToast('再次返回退出vvex',
                  displayTime: const Duration(seconds: 1));
              // 点击返回键的操作
              if (lastPopTime == null ||
                  DateTime.now().difference(lastPopTime!) >
                      const Duration(seconds: 1)) {
                // 1秒内连续按两次返回键退出
                // 两次点击间隔超过1秒则重新计时
                lastPopTime = DateTime.now();
                return false;
              }
              return true;
              // 退出app
            },
            child: const HomePage(),
          ),
          navigatorKey: Routes.navigatorKey,
          routingCallback: (routing) {
            if (routing!.previous == '/login') {
              return;
            }
          },
          // here
          navigatorObservers: [FlutterSmartDialog.observer],
          // here
          builder: FlutterSmartDialog.init(
            //default loading widget
            loadingBuilder: (String msg) => CustomLoading(msg: msg),
            toastBuilder: (String msg) => CustomToast(msg: msg),
          ),
        );
      },
    );
  }
}
