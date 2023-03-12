import 'dart:async';
import 'dart:io';
import 'package:get/get.dart';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
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
import 'package:system_proxy/system_proxy.dart';
import 'package:flutter_v2ex/http/dio_web.dart';
import 'package:flutter_v2ex/utils/app_theme.dart';
import 'package:flutter_v2ex/controller/fontsize_controller.dart';

class ProxiedHttpOverrides extends HttpOverrides {
  final String _port;
  final String _host;
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
  try{
    await LocalNoticeService().init();
  }catch(err){
    print('LocalNoticeService err: ${err.toString()}');
  }
  // 代理设置
  Map<String, String>? proxy = await SystemProxy.getProxySettings();
  if (proxy != null) {
    HttpOverrides.global = ProxiedHttpOverrides(proxy['host']!, proxy['port']!);
  }
  // 本地存储初始化
  try{
    await GetStorage.init();
  }catch(err) {
    print('GetStorage err: ${err.toString()}');
  }
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
  ThemeType currentThemeValue = ThemeType.system;
  EventBus eventBus = EventBus();
  DateTime? lastPopTime; //上次点击时间
  double globalFs = GStorage().getGlobalFs();
  var _timer;

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

    // 轮询消息 30分钟
    // if(GStorage().getLoginStatus()){
    //   const timeInterval = Duration(minutes: 30);
    //   _timer = Timer.periodic(timeInterval , (timer){
    //     // 循环一定要记得设置取消条件，手动取消
    //     DioRequestWeb.queryDaily();
    //   });
    // }
    // 检查更新
    if(GStorage().getAutoUpdate()){
      DioRequestWeb.checkUpdate();
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
    // 组件销毁时判断Timer是否仍然处于激活状态，是则取消
    if(_timer.isActive){
      _timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final FontSizeController? fontSizeController
    = Get.put(FontSizeController());
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
        return  GetMaterialApp(
          title: 'VVEX',
          debugShowCheckedModeBanner: false,
          initialRoute: '/',
          getPages: AppPages.getPages,
          theme: ThemeData(
            fontFamily: 'NotoSansSC',
            // textTheme: CustomTheme(Theme.of(context).textTheme).customFsTheme(fontSize: globalFs),
            textTheme: fontSizeController!.getFontSize,
            useMaterial3: true,
            colorScheme: currentThemeValue == ThemeType.dark
                ? darkColorScheme
                : lightColorScheme,
          ),
          darkTheme: ThemeData(
            fontFamily: 'NotoSansSC',
            // textTheme: CustomTheme(Theme.of(context).textTheme).customFsTheme(fontSize: globalFs),
            useMaterial3: true,
            colorScheme: currentThemeValue == ThemeType.light
                ? lightColorScheme
                : darkColorScheme,
          ),
          home: const HomePage(),
          navigatorKey: Routes.navigatorKey,
          routingCallback: (routing) {
            if (routing!.previous == '/login') {
              return;
            }
          },
          navigatorObservers: [FlutterSmartDialog.observer],
          builder: (BuildContext context, Widget? child) {
            return FlutterSmartDialog(
                loadingBuilder: (String msg) => CustomLoading(msg: msg),
                toastBuilder: (String msg) => CustomToast(msg: msg),
                /// 设置文字大小不跟随系统更改
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                  child: child!,
                )
            );
          },
        );
      },
    );
  }
}
