import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:dynamic_color/dynamic_color.dart';
// import 'package:cookie_jar/cookie_jar.dart';
// import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:dio/dio.dart';
import 'package:dio/adapter.dart';
// import 'package:dio_http_cache/dio_http_cache.dart';

// import 'utils/utils.dart';
import 'utils/string.dart';
import 'package:flutter_v2ex/http/init.dart';
// import 'package:flutter_v2ex/http/dio_web.dart';

import 'package:flutter_v2ex/pages/app_tab.dart';
import 'package:flutter_v2ex/pages/list_detail.dart';
import 'package:flutter_v2ex/pages/webview_page.dart';

dynamic _parseAndDecode(String response) {
  return jsonDecode(response);
}

Future parseJson(String text) {
  return compute(_parseAndDecode, text);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 配置 dio
  // add interceptors
  // var cookiePath = await Utils.getCookiePath();
  // var cookieJar = PersistCookieJar(
  //   ignoreExpires: true,
  //   storage: FileStorage(cookiePath),
  // ); // 持久化 cookie
  // dio.interceptors
  //   ..add(CookieManager(cookieJar))
  //   ..add(LogInterceptor())
  //   ..add(DioCacheManager(CacheConfig(baseUrl: Strings.v2exHost)).interceptor);

  (dio.transformer as DefaultTransformer).jsonDecodeCallback = parseJson;
  dio.options.connectTimeout = 12000;
  dio.options.receiveTimeout = 12000;
  dio.options.baseUrl = Strings.v2exHost;
  dio.options.headers = {
    'user-agent': Platform.isIOS
        ? 'Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.0 Mobile/14E304 Safari/602.1'
        : 'Mozilla/5.0 (Linux; Android 4.4.2; Nexus 4 Build/KOT49H) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/73.0.3683.75 Mobile Safari/537.36'
  };

  dio.options.validateStatus = (status) {
    return status! >= 200 && status < 300 || status == 304 || status == 302;
  };

  (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
      (client) {
    // config the http client
    client.findProxy = (uri) {
      // proxy all request to localhost:8888
      return 'PROXY 192.168.1.60: 7890';
      // return 'PROXY 172.16.32.186:7890';
      // return 'PROXY localhost:7890';
      // 不设置代理 TODO 打包前关闭代理
      // return 'DIRECT';
    };
    return null;
    // you can also create a HttpClient to dio
    // return HttpClient();
  };

  runApp(const MyApp());
}

Color brandColor = const Color.fromARGB(41, 64, 118, 193);

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
          fontFamily: "font",
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
          '/listdetail': (context) => const ListDetail(),
          '/webview': (context) => const WebView(),
        },
      );
    });
  }
}
