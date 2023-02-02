import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_v2ex/utils/event_bus.dart';


import 'package:flutter_v2ex/pages/app_tab.dart';
import 'package:flutter_v2ex/pages/help_page.dart';
import 'package:flutter_v2ex/pages/list_detail.dart';
import 'package:flutter_v2ex/pages/login_page.dart';
import 'package:flutter_v2ex/pages/message_page.dart';
import 'package:flutter_v2ex/pages/nodes_page.dart';
import 'package:flutter_v2ex/pages/tabs/mine_page.dart';
import 'package:flutter_v2ex/pages/webview_page.dart';
import 'package:flutter_v2ex/pages/go_page.dart';
import 'package:flutter_v2ex/pages/fav_page.dart';
import 'package:flutter_v2ex/pages/profile_page.dart';
import 'package:flutter_v2ex/components/common/custom_loading.dart';
import 'package:flutter_v2ex/utils/global.dart';
import 'package:flutter_v2ex/utils/string.dart';


dynamic _parseAndDecode(String response) {
  return jsonDecode(response);
}

Future parseJson(String text) {
  return compute(_parseAndDecode, text);
}

void main() async {
  runApp(const MyApp());
}

Color brandColor = const Color.fromRGBO(39, 82, 67, 100);

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

      return MaterialApp(
        title: 'vvex',
        theme: ThemeData(
          fontFamily: 'NotoSansSC',
          useMaterial3: true,
          colorScheme: currentThemeValue == ThemeType.dark ? darkColorScheme : lightColorScheme,
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: currentThemeValue == ThemeType.light  ? lightColorScheme : darkColorScheme,
        ),
        home: const AppTab(),
        navigatorKey: Routes.navigatorKey,
        // initialRoute: '/listdetail',
        initialRoute: '/',
        routes: {
          '/listDetail': (context) => const ListDetail(topicId: '1'),
          '/webView': (context) => WebView(aUrl: ''),
          '/go': (context) => GoPage(nodeKey: ''),
          '/fav': (context) => const FavPage(),
          '/profile': (context) => ProfilePage(memberId: '',),
          '/nodes': (context) => const NodesPage(),
          '/help': (context) => const HelpPage(),
          '/mine': (context) => MinePage(memberId: ''),
          '/login': (context) => const LoginPage(),
          '/message': (context) => const MessagePage(),
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
