import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_v2ex/pages/app_tab.dart';

void main() {
  runApp(const MyApp());
}

Color brandColor = const Color.fromARGB(255, 25, 201, 193);

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // static final _defaultLightColorScheme =
  //     ColorScheme.fromSwatch(primarySwatch: Colors.blue);

  // static final _defaultDarkColorScheme = ColorScheme.fromSwatch(
  //     primarySwatch: Colors.blue, brightness: Brightness.dark);
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
        // lightColorScheme = lightColorScheme.copyWith(secondary: brandColor);
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
        initialRoute: '/',
        // routes: {
        //   '/listdetail': (context) => const ListDetail(),
        // },
      );
    });
  }
}
