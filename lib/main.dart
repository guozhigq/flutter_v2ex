import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_v2ex/utils/event_bus.dart';
import 'package:get/get.dart';
import 'router/app_pages.dart';

import 'package:flutter_v2ex/pages/login_page.dart';
import 'package:flutter_v2ex/components/common/custom_loading.dart';
import 'package:flutter_v2ex/utils/global.dart';
import 'package:flutter_v2ex/utils/string.dart';
import 'package:flutter_v2ex/pages/home_page.dart';


dynamic _parseAndDecode(String response) {
  return jsonDecode(response);
}

Future parseJson(String text) {
  return compute(_parseAndDecode, text);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ByteData data =
      await PlatformAssetBundle().load('assets/ca/lets-encrypt-r3.pem');
  SecurityContext.defaultContext
      .setTrustedCertificatesBytes(data.buffer.asUint8List());

  runApp(const MyApp());

  if (Platform.isAndroid) {
    // 以下两行 设置android状态栏为透明的沉浸。写在组件渲染之后，是为了在渲染后进行set赋值，覆盖状态栏，写在渲染之前MaterialApp组件会覆盖掉这个值。
    SystemUiOverlayStyle systemUiOverlayStyle =
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
}

Color brandColor = const Color.fromRGBO(58, 105, 154, 100);

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeType currentThemeValue = ThemeType.system;
  EventBus eventBus = EventBus();

  @override
  void initState() {
    super.initState();
    eventBus.on('themeChange', (arg) {
      setState(() {
        currentThemeValue = arg;
      });
    });
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
        debugShowCheckedModeBanner: false,
        debugShowMaterialGrid: false,
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
        home: const HomePage(),
        navigatorKey: Routes.navigatorKey,
        routes: {
          '/login': (context) => const LoginPage(),
        },
        // here
        navigatorObservers: [FlutterSmartDialog.observer],
        // here
        builder: FlutterSmartDialog.init(
          //default loading widget
          loadingBuilder: (String msg) => SmartLoading(msg: msg),
        ),
      );
    });
  }
}
