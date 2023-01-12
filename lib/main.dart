import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:dynamic_color/dynamic_color.dart';

import 'package:flutter_v2ex/pages/app_tab.dart';
import 'package:flutter_v2ex/pages/list_detail.dart';
import 'package:flutter_v2ex/pages/webview_page.dart';
import 'package:flutter_v2ex/pages/go_page.dart';
import 'package:flutter_v2ex/pages/fav_page.dart';
import 'package:flutter_v2ex/pages/profile_page.dart';

dynamic _parseAndDecode(String response) {
  return jsonDecode(response);
}

Future parseJson(String text) {
  return compute(_parseAndDecode, text);
}

void main() async {
  runApp(const MyApp());
}

Color brandColor = const Color.fromRGBO(139, 196, 74, 100);

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
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
          colorScheme: lightColorScheme,
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: darkColorScheme,
        ),
        home: const AppTab(),
        // initialRoute: '/listdetail',
        initialRoute: '/',
        routes: {
          '/listdetail': (context) => const ListDetail(topicId: '1'),
          '/webview': (context) => WebView(aUrl: ''),
          '/go': (context) => GoPage(nodeKey: ''),
          '/fav': (context) => const FavPage(),
          '/profile': (context) => ScaleAnimationRoute()
        },
      );
    });
  }
}
